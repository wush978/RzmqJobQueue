#'@export
push_job_queue <- function(job.list) {
  dict$job.queue <- c(dict$job.queue, job.list)
}

#'@export
pop_job_queue <- function() {
  retval <- dict$job.queue[[1]]
  dict$job.queue[[1]] <- NULL
  return(retval)
}

#'@export
clear_job_queue <- function() {
  dict$job.queue <- list()
}

ignore.error <- c("Error in unserialize(ans) : 'connection' must be a connection\n")

#'@export
wait_worker <- function(path = NULL, shared_secret = "default") {
  if (is.null(path)) stop("\"path\" is required")
  context = init.context()
  socket = init.socket(context,"ZMQ_REP")
  stopifnot(bind.socket(socket, path))
  while(length(dict$job.queue) > 0) {
    worker <- receive.socket(socket)
    if (worker$shared_secret != shared_secret) {
      next
    }
    job <- pop_job_queue()
    if (!send.socket(socket, data=job)) {
      push_job_queue(list(job))
      tryCatch(
        info(dict$logger, sprintf("send job to %s failed", worker$worker.id)), 
        error=function(e) info(dict$logger, geterrmessage())
        )
      next
    }
    tryCatch(
      info(dict$logger, sprintf("send job to %s successful", worker$worker.id)), 
      error=function(e) info(dict$logger, geterrmessage())
    )
  }
}



