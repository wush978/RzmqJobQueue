dump_jobs <- function(key) {
  extractor <- switch(
    key,
    "job.processing" = function(key) rredis:::redisHGetAll(key),
    function(key) rredis:::redisLRange(key, 0, rredis:::redisLLen(key) - 1)
    )
  value.base64 <- extractor(key)
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
  return(value)
}

#'@title query_job_queue
#'
#'Dump the jobs in the job queue for monitoring.
#'This function won't affect the job queue in redis server.
#'
#'@return data.frame includes the information of jobs. The 'title' attribute is used in shiny app
#'@export
query_job_queue <- function() {
  value <- dump_jobs("job.queue")
  value.argv <- sapply(value, function(a) {
    argv <- a["argv"]
    retval <- capture.output(dump("argv", ""))
    return(paste(retval, collapse=""))
  })
  retval <- data.frame(hash = sapply(value, function(a) a["hash"], simplify=TRUE))
  attr(retval, "title") <- value.argv
  return(retval)
}

#'@title query_job_processing
#'
#'Dump the jobs which is under executing for monitoring.
#'This function won't affect the job queue in redis server.
#'
#'@return data.frame includes the information of jobs. The 'title' attribute is used in shiny app
#'@export
query_job_processing <- function() {
  value <- dump_jobs("job.processing")
  get_column <- function(name) {
    force(name)
    return(sapply(value, function(a) a[name]))
  }
  value.argv <- sapply(value, function(a) {
    argv <- a["argv"]
    retval <- capture.output(dump("argv", ""))
    return(paste(retval, collapse=""))
    })
  retval <- data.frame(row.names = get_column("hash"), worker.id = get_column("worker.id"), start.processing = get_column("start.processing"))
  class(retval$start.processing) <- c("POSIXct", "POSIXt")
  retval$start.processing <- format(retval$start.processing)
  attr(retval, "title") <- value.argv
  return(retval)
}

#'@title query_job_finish
#'
#'Dump the jobs which is finished
#'This function won't affect the job queue in redis server.
#'
#'@return data.frame includes the information of jobs. The 'title' attribute is used in shiny app
#'@export
query_job_finish <- function() {
  value <- dump_jobs("job.finish")
  get_column <- function(name) {
    force(name)
    return(sapply(value, function(a) a[name]))
  }
  value.argv <- sapply(value, function(a) {
    argv <- a["argv"]
    retval <- capture.output(dump("argv", ""))
    return(paste(retval, collapse=""))
  })
  retval <- data.frame(row.names = get_column("hash"), worker.id = get_column("worker.id"), start.processing = get_column("start.processing"), processing.time = get_column("processing.time"))
  class(retval$start.processing) <- c("POSIXct", "POSIXt")
  retval$start.processing <- format(retval$start.processing)
  attr(retval, "title") <- value.argv
  return(retval)
}

encode_base64 <- function(value) {
  .Call("base64__encode", serialize(value, connection=NULL))
}

decode_base64 <- function(value.base64) {
  unserialize(.Call("base64__decode", value.base64))
}

redisSet <- function(key, value) {
  rredis:::redisSet(key, encode_base64(value))
}

redisGet <- function(key) {
  decode_base64(rredis:::redisGet(key))
}

redisLPush <- function(key, value) {
  rredis:::redisLPush(key, encode_base64(value))
}

redisRPop <- function(key) {
  decode_base64(rredis:::redisRPop(key))
}

redisHSet <- function(key, field, value, NX=FALSE) {
  rredis:::redisHSet(key, field, encode_base64(value), NX)
}

redisHGet <- function(key, field) {
  decode_base64(rredis:::redisHGet(key, field))
}

#'@title push_job_queue
#'
#'Add job to the job queue in redis
#'
#'@param job an instance of 'job'
#'@export
push_job_queue <- function(job) {
  stopifnot(class(job) == "job")
  redisLPush("job.queue", job)
}

#'@title push_job_processing
#'
#'Add job to hash values in redis
#'
#'@param job an instance of 'job'
#'@export
push_job_processing <- function(job, hash) {
  stopifnot(class(job) == "job")
  job["start.processing"] <- Sys.time()
  redisHSet("job.processing", job["hash"], job)
}

#'@title push_job_finish
#'
#'Add job to the list of finished job in redis
#'
#'@param job an instance of 'job'
#'@export
push_job_finish <- function(job) {
  stopifnot(class(job) == "job")
  job["processing.time"] <- as.numeric(Sys.time() - job["start.processing"])
  redisLPush("job.finish", job)
}

push_job_error <- function(job) {
  stopifnot(class(job) == "job")
  redisLPush("job.error", job)
}

#'@title job_queue_len
#'@return int the number of jobs in job queue
#'@export
job_queue_len <- function() redisLLen("job.queue")

#'@title job_processing_len
#'@return int the number of jobs under execution
#'@export
job_processing_len <- function() redisHLen("job.processing")

#'@title job_finish_len
#'@return int the number of finished jobs
#'@export
job_finish_len <- function() redisLLen("job.finish")

#'@title pop_job_queue
#'
#'Return the first job in the queue
#'
#'@return an instance of 'job'
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

#'@title pop_job_processing
#'
#'Return the job in the hash values in redis according to the parameter \code{hash}
#'
#'@param hash the hash value of the job
#'@return an instance of 'job'
#'@export
pop_job_processing <- function(hash) {
  job <- redisHGet("job.processing", field=hash)
  stopifnot(class(job) == "job")
  redisHDel("job.processing", field=hash)
  return(job)
}

#'@title pop_job_finish
#'
#'Return the first job in the list of finished job
#'
#'@return an instance of 'job'
#'@export
pop_job_finish <- function() {
  job <- redisRPop("job.finish")
  stopifnot(class(job) == "job")
  return(job)
}

#'@title clear_job_queue
#'
#'Clear the job queue
#'
#'@export
clear_job_queue <- function() {
  redisDelete("job.queue")
}

#'@title clear_job_processing
#'
#'Clear the hash values in redis of jobs under execution 
#'
#'@export
clear_job_processing <- function() {
  redisDelete("job.processing")
}

#'@title clear_job_finish
#'
#'Clear the list of finished job
#'
#'@export
clear_job_finish <- function() {
  redisDelete("job.finish")
}

#'@title wait_worker
#'
#'Listen to a specific port for workers and assign the first job in job queue if the worker asks a job.
#'
#'@param path string, ex: "tcp://*:12345"
#'@param shared_secret string, a secret shares with workers
#'@param terminate logical, whether terminate worker after the job-queue is cleared
#'@param is_start logical, check if the hash value of job under execution is empty or not
#'@param is_clear_job_finish logical, whether clear the list of finished job or not 
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
#   pb <- txtProgressBar(max = job.total.count)
  while(job_queue_len() + job_processing_len() > 0) {
    try.socket <- try(worker <- receive.socket(dict$socket[[path]]))
    if (class(try.socket) == "try-error") next
    info(dict$logger, sprintf("receive worker %s with request %s and shared secret %s", worker$worker.id, worker$request, worker$shared_secret))
    if (worker$shared_secret != shared_secret) {
      send.null.msg(dict$socket[[path]])
      next
    }
    if (worker$request != "finish job") { # check if job error 
      job.processing.list <- dump_jobs("job.processing")
      worker.list <- sapply(job.processing.list, function(job) job["worker.id"])
      browser()
    }
    switch(
      worker$request,
      "init" = init_job(dict$socket[[path]], worker),
      "finish job" = finish_job(dict$socket[[path]], worker),
      "ask job" = ask_job(dict$socket[[path]], worker, terminate)
      )
#     setTxtProgressBar(pb, length(dict$job.finish))
    if (length(dict$job.finish) == job.total.count) {
      cat(sprintf("There are %d jobs in job.queue and %d jobs in job.processing...\n", length(dict$job.queue), length(dict$job.processing)))
    }
  }
#   close(pb)
}

#'set_init_job
#'
#'Ask the worker do the job when it asking how to initialize
#'
#'@param job an instance of 'job'
#'@export
set_init_job <- function(job) {
  if (class(job) != "job") stop("non-job object")
  redisSet("job.init", job)
}

init_job <- function(socket, worker) {
  job <- redisGet("job.init")
  if (is.null(job)) stop("init script has not been set yet!")
  info(dict$logger, sprintf("sending init script to %s", worker$worker.id)) 
  send.socket(socket, job)
}

finish_job <- function(socket, worker) {
  job.hash <- worker$job.hash
  job.result <- worker$job.result
  job <- pop_job_processing(job.hash)
  job["result"] <- job.result
  push_job_finish(job)
  info(dict$logger, sprintf("sending null response to %s", worker$worker.id)) 
  send.socket(socket, NULL)
}

empty_job <- new("job", "empty", Sys.sleep, list(time = 10))
terminate_job <- new("job", "terminate", fun = Sys.sleep, list(time = 1))

ask_job <- function(socket, worker, terminate) {
  if (job_queue_len() == 0) {
    info(dict$logger, sprintf("job queue is empty"))
    if (terminate) {
      info(dict$logger, sprintf("terminating the worker %s", worker$worker.id))
      send.socket(socket, data=terminate_job) 
    } else send.socket(socket, data=empty_job)
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
