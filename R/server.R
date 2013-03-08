#'@export
push_job_queue <- function(job.list) {
  dict$job.queue <- c(dict$job.queue, job.list)
}

#'@export
push_job_processing <- function(job, hash) {
  dict$job.processing[[hash]] <- job
}

#'@export
push_job_finish <- function(job, hash) {
  dict$job.finish[[hash]] <- job
}

#'@export
pop_job_queue <- function() {
  if (length(dict$job.queue) == 0) {
    job <- list(type = "empty")
    return(job)
  }
  job <- dict$job.queue[[1]]
  dict$job.queue[[1]] <- NULL
  job$type <- "normal"
  return(job)
}

#'@export
pop_job_processing <- function(hash) {
  retval <- dict$job.processing[[hash]]
  dict$job.processing[[hash]] <- NULL
  return(retval)
}

#'@export
pop_job_finish <- function(hash) {
  retval <- dict$job.finish[[hash]]
  dict$job.finish[[hash]] <- NULL
  return(retval)
}

#'@export
clear_job_queue <- function() {
  dict$job.queue <- list()
}

#'@export
clear_job_processing <- function() {
  dict$job.processing <- list()
}

#'@export
clear_job_finish <- function() {
  dict$job.finish <- list()
}

ignore.error <- c("Error in unserialize(ans) : 'connection' must be a connection\n")

#'@export
wait_worker <- function(path = NULL, shared_secret = "default", terminate = TRUE) {
  if (is.null(path)) stop("\"path\" is required")
  if (is.null(dict$context)) dict$context = init.context()
  if (is.null(dict$socket[[path]])) {
    dict$socket[[path]] = init.socket(dict$context,"ZMQ_REP")
    stopifnot(bind.socket(dict$socket[[path]], path))
  }
#   if (terminate) {
#     on.exit({
#       print(Sys.time())
#       close_worker(socket, shared_secret)
#       })
#   }
  stopifnot(length(dict$job.processing) == 0)
  clear_job_finish()
  stopifnot(length(dict$job.finish) == 0)
  job.total.count <- length(dict$job.queue)
  pb <- txtProgressBar(max = job.total.count)
  while(length(dict$job.queue) + length(dict$job.processing) > 0) {
    worker <- receive.socket(dict$socket[[path]])
    info(dict$logger, sprintf("receive worker %s with request %s and shared secret %s", worker$worker.id, worker$request, worker$shared_secret))
    if (worker$shared_secret != shared_secret) {
      send.null.msg(dict$socket[[path]])
      next
    }
    switch(
      worker$request,
      "finish job" = finish_job(dict$socket[[path]], worker),
      "ask job" = ask_job(dict$socket[[path]], worker)
      )
    setTxtProgressBar(pb, length(dict$job.finish))
    if (length(dict$job.finish) == job.total.count) {
      cat(sprintf("There are %d jobs in job.queue and %d jobs in job.processing...\n", length(dict$job.queue), length(dict$job.processing)))
    }
  }
  close(pb)
}


finish_job <- function(socket, worker) {
  job.hash <- worker$job.hash 
  job <- pop_job_processing(job.hash)
  push_job_finish(job, job.hash)
  info(dict$logger, sprintf("sending null response to %s", worker$worker.id)) 
  send.socket(socket, NULL)
}

ask_job <- function(socket, worker) {
  job <- pop_job_queue()
  if (job$type == "empty") {
    info(dict$logger, sprintf("job queue is empty"))
    send.socket(socket, data=job)
    return(NULL)
  }
  job.hash <- digest(c(job, Sys.time()), "md5")
  job$hash <- job.hash
  if (!send.socket(socket, data=job)) {
    tryCatch({
      push_job_queue(list(job))
      info(dict$logger, sprintf("send job %s to %s failed", job$hash, worker$worker.id))}, 
      error=function(e) info(dict$logger, geterrmessage())
    )
    return(NULL)
  }
  info(dict$logger, sprintf("send job %s to %s successfully", job$hash, worker$worker.id)) 
  job$worker.id <- worker$worker.id
  push_job_processing(job, job.hash)
}

# close_worker <- function(socket, shared_secret) {
#   start.time <- Sys.time()
#   current.time <- Sys.time()
#   while(as.numeric(current.time - start.time) < 10) {
#     worker <- receive.socket(socket)
#     info(dict$logger, sprintf("receive worker %s with request %s and shared secret %s", worker$worker.id, worker$request, worker$shared_secret))
#     if (worker$shared_secret != shared_secret) {
#       send.null.msg(socket)
#       next
#     }
#     info(dict$logger, sprintf("terminating worker %s", worker$worker.id))
#     job.prototype <- list(type="terminate")
#     send.socket(socket, job.prototype)
#     current.time <- Sys.time()
#   }
# }
