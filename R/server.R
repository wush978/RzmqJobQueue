#'@export
push_job_queue <- function(job) {
  redisLPush("job.queue", job)
}

#'@export
push_job_processing <- function(job, hash) {
  job["start.processing"] <- Sys.time()
  redisHSet("job.processing", job["hash"], job)
}

#'@export
push_job_finish <- function(job, hash) {
  job["processing.time"] <- as.numeric(Sys.time() - job["start.processing"])
  redisLPush("job.finish", job)
}

#'@export
job_queue_len <- function() redisLLen("job.queue")

#'@export
job_processing_len <- function() redisHLen("job.processing")

#'@export
job_finish_len <- function() redisLLen("job.finish")

#'@export
pop_job_queue <- function() {
  if (job_queue_len() == 0) {
    stop("Logical Error: The empty job queue should be handle in \"ask_job\"")
  }
  job <- redisRPop("job.queue")
  job["type"] <- "normal"
  return(job)
}

#'@export
pop_job_processing <- function(hash) {
  job <- redisHGet("job.processing", field=hash)
  redisHDel("job.processing", field=hash)
  return(job)
}

#'@export
pop_job_finish <- function() {
  job <- redisRPop("job.finish")
  return(job)
}

#'@export
clear_job_queue <- function() {
  redisDelete("job.queue")
}

#'@export
clear_job_processing <- function() {
  redisDelete("job.processing")
}

#'@export
clear_job_finish <- function() {
  redisDelete("job.finish")
}

#'@export
wait_worker <- function(path = NULL, shared_secret = "default", terminate = TRUE) {
  if (is.null(path)) stop("\"path\" is required")
  if (is.null(dict$context)) dict$context = init.context()
  if (is.null(dict$socket[[path]])) {
    dict$socket[[path]] = init.socket(dict$context,"ZMQ_REP")
    stopifnot(bind.socket(dict$socket[[path]], path))
  }
  stopifnot(job_processing_len() == 0)
  clear_job_finish()
  job.total.count <- job_queue_len()
  pb <- txtProgressBar(max = job.total.count)
  while(job_queue_len() + job_processing_len() > 0) {
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

empty_job <- new("job", "empty", Sys.sleep, list(time = 10))

ask_job <- function(socket, worker) {
  if (job_queue_len() == 0) {
    info(dict$logger, sprintf("job queue is empty"))
    send.socket(socket, data=empty_job)
    return(NULL)
  }
  job <- pop_job_queue()
  if (!send.socket(socket, data=job)) {
    tryCatch({
      push_job_queue(list(job))
      info(dict$logger, sprintf("send job %s to %s failed", job["hash"], worker$worker.id))}, 
      error=function(e) info(dict$logger, geterrmessage())
    )
    return(NULL)
  }
  info(dict$logger, sprintf("send job %s to %s successfully", job["hash"], worker$worker.id)) 
  job["worker.id"] <- worker$worker.id
  push_job_processing(job, job.hash)
}
