#'@export
query_job_queue <- function() {
  value.base64 <- rredis:::redisLRange("job.queue", 0, rredis:::redisLLen("job.queue") - 1)
  value <- tryCatch({ 
    sapply(value.base64, function(base64) {
      unserialize(.Call("base64__decode", base64), refhook=FALSE)
    })},
                    error = function(e) {
                      greg.result <- gregexpr("^\\.onLoad failed in loadNamespace\\(\\) for \'(?<pkgname>\\w+)\',.*", text=conditionMessage(e), perl=TRUE)[[1]]
                      if (greg.result == -1) stop(conditionMessage(e))
                      pkgname <- substr(conditionMessage(e), attr(greg.result, "capture.start"), attr(greg.result, "capture.start") + attr(greg.result, "capture.length") - 1)
                      library(pkgname, character.only=TRUE)
                      value <- sapply(value.base64, function(base64) {
                        unserialize(.Call("base64__decode", base64), refhook=FALSE)
                      })
                      return(value)
                    })
  data.frame(hash = sapply(value, function(a) a["hash"], simplify=TRUE))
}

#'@export
query_job_processing <- function() {
  value.base64 <- rredis:::redisHGetAll("job.processing")
  value <- tryCatch({ 
    sapply(value.base64, function(base64) {
      unserialize(.Call("base64__decode", base64), refhook=FALSE)
    })},
    error = function(e) {
      greg.result <- gregexpr("^\\.onLoad failed in loadNamespace\\(\\) for \'(?<pkgname>\\w+)\',.*", text=conditionMessage(e), perl=TRUE)[[1]]
      if (greg.result == -1) stop(conditionMessage(e))
      pkgname <- substr(conditionMessage(e), attr(greg.result, "capture.start"), attr(greg.result, "capture.start") + attr(greg.result, "capture.length") - 1)
      library(pkgname, character.only=TRUE)
      value <- sapply(value.base64, function(base64) {
        unserialize(.Call("base64__decode", base64), refhook=FALSE)
      })
      return(value)
    })
  get_column <- function(name) {
    force(name)
    return(sapply(value, function(a) a[name]))
  }
  retval <- data.frame(row.names = get_column("hash"), worker.id = get_column("worker.id"), start.processing = get_column("start.processing"))
  class(retval$start.processing) <- c("POSIXct", "POSIXt")
  retval$start.processing <- format(retval$start.processing)
  return(retval)
}

#'@export
query_job_finish <- function() {
  value.base64 <- rredis:::redisLRange("job.finish", 0, rredis:::redisLLen("job.finish") - 1)
  value <- tryCatch({ 
    sapply(value.base64, function(base64) {
      unserialize(.Call("base64__decode", base64), refhook=FALSE)
    })},
                    error = function(e) {
                      greg.result <- gregexpr("^\\.onLoad failed in loadNamespace\\(\\) for \'(?<pkgname>\\w+)\',.*", text=conditionMessage(e), perl=TRUE)[[1]]
                      if (greg.result == -1) stop(conditionMessage(e))
                      pkgname <- substr(conditionMessage(e), attr(greg.result, "capture.start"), attr(greg.result, "capture.start") + attr(greg.result, "capture.length") - 1)
                      library(pkgname, character.only=TRUE)
                      value <- sapply(value.base64, function(base64) {
                        unserialize(.Call("base64__decode", base64), refhook=FALSE)
                      })
                      return(value)
                    })
  get_column <- function(name) {
    force(name)
    return(sapply(value, function(a) a[name]))
  }
  retval <- data.frame(row.names = get_column("hash"), worker.id = get_column("worker.id"), start.processing = get_column("start.processing"), processing.time = get_column("processing.time"))
  class(retval$start.processing) <- c("POSIXct", "POSIXt")
  retval$start.processing <- format(retval$start.processing)
  return(retval)
}


redisLPush <- function(key, value) {
  value.raw <- serialize(value, connection=NULL)
  value.base64 <- .Call("base64__encode", value.raw)
  rredis:::redisLPush(key, value.base64)
}

redisRPop <- function(key) {
  value.base64 <- rredis:::redisRPop(key)
  value.raw <- .Call("base64__decode", value.base64)
  value <- unserialize(value.raw)
  return(value)
}

redisHSet <- function(key, field, value, NX=FALSE) {
  value.raw <- serialize(value, connection=NULL)
  value.base64 <- .Call("base64__encode", value.raw)
  rredis:::redisHSet(key, field, value.base64, NX)
}

redisHGet <- function(key, field) {
  value.base64 <- rredis:::redisHGet(key, field)
  value.raw <- .Call("base64__decode", value.base64)
  value <- unserialize(value.raw)
  return(value)
}


#'@export
push_job_queue <- function(job) {
  stopifnot(class(job) == "job")
  redisLPush("job.queue", job)
}

#'@export
push_job_processing <- function(job, hash) {
  stopifnot(class(job) == "job")
  job["start.processing"] <- Sys.time()
  redisHSet("job.processing", job["hash"], job)
}

#'@export
push_job_finish <- function(job, hash) {
  stopifnot(class(job) == "job")
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
  stopifnot(class(job) == "job")
  job["type"] <- "normal"
  return(job)
}

#'@export
pop_job_processing <- function(hash) {
  job <- redisHGet("job.processing", field=hash)
  stopifnot(class(job) == "job")
  redisHDel("job.processing", field=hash)
  return(job)
}

#'@export
pop_job_finish <- function() {
  job <- redisRPop("job.finish")
  stopifnot(class(job) == "job")
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
wait_worker <- function(path = NULL, shared_secret = "default", terminate = TRUE, is_start = FALSE, is_clear_job_finish = FALSE) {
  if (is.null(path)) stop("\"path\" is required")
  if (is.null(dict$context)) dict$context = init.context()
  if (is.null(dict$socket[[path]])) {
    dict$socket[[path]] = init.socket(dict$context,"ZMQ_REP")
    stopifnot(bind.socket(dict$socket[[path]], path))
  }
  if (is_start) stopifnot(job_processing_len() == 0)
  if (is_clear_job_finish) clear_job_finish()
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
