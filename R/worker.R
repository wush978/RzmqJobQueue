init_connection <- function (path) {
  if (is.null(path)) stop("\"path\" is required")
  if (is.null(dict$context)) {
    cat("init context\n")
    dict$context = init.context()
  }
  if (is.null(dict$socket[[path]])) {
    cat("init socket\n")
    dict$socket[[path]] = init.socket(dict$context,"ZMQ_REQ")
    stopifnot(connect.socket(dict$socket[[path]],path))
  }
}

send_server <- function(path, shared_secret, request) {
  send.socket(dict$socket[[path]], data=list(request=request, worker.id=dict$worker.id, type=dict$type, shared_secret = shared_secret))
}

#'@export
init_worker <- function(path = NULL, shared_secret = "default") {
  init_connection(path)
  send_server(path, shared_secret, "init")
  log4r:::debug(dict$logger, sprintf("[id: %s] asking init script from %s", dict$worker.id, path))
  job <- receive.socket(dict$socket[[path]])
  if (class(job) != "job") {
    error(dict$logger, sprintf("Received a non-job object!"))
    return(NULL)
  }
  log4r:::debug(dict$logger, sprintf("[id: %s] receiving job(hash:%s) from %s", dict$worker.id, job["hash"], path))
  log4r:::debug(dict$logger, paste(capture.output(print(job)), collapse="\n"))
  switch(
    job["type"],
    "terminate" = {
      info(dict$logger, sprintf("[id: %s] terminating", dict$worker.id))
      stop("terminate")
    },
    "empty" = {
      log4r:::debug(dict$logger, sprintf("[id: %s] job queue is empty", dict$worker.id))
      do.call(job["fun"], job["argv"])
      return(NULL)
    })
  tryCatch({
    do.call(job["fun"], job["argv"])
#     log4r:::debug(dict$logger, sprintf("[id: %s] sending finish signal of job(hash:%s) to %s", dict$worker.id, job["hash"], path))
#     send.socket(dict$socket[[path]], data=list(request="finish job", worker.id=dict$worker.id, job.hash = job["hash"], shared_secret = shared_secret))
#     res <- receive.socket(dict$socket[[path]])
#     info(dict$logger, sprintf("[id: %s] finish job(hash:%s)", dict$worker.id, job["hash"]))
  }, error = function(e) {
    error(dict$logger, sprintf("Job %s has following error message: %s", job["hash"], conditionMessage(e)))
  })
}

#'@title do_job
#'@param path example: "tcp://localhost:5555"
#'@export
do_job <- function(path = NULL, shared_secret = "default") {
  init_connection(path)
  send_server(path, shared_secret, "ask job")
  log4r:::debug(dict$logger, sprintf("[id: %s] asking job from %s", dict$worker.id, path))
  job <- receive.socket(dict$socket[[path]])
  if (class(job) != "job") {
    error(dict$logger, sprintf("Received a non-job object!"))
    return(NULL)
  }
  log4r:::debug(dict$logger, sprintf("[id: %s] receiving job(hash:%s) from %s", dict$worker.id, job["hash"], path))
  log4r:::debug(dict$logger, paste(capture.output(print(job)), collapse="\n"))
  switch(
    job["type"],
    "terminate" = {
      info(dict$logger, sprintf("[id: %s] terminating", dict$worker.id))
      stop("terminate")
    },
    "empty" = {
      log4r:::debug(dict$logger, sprintf("[id: %s] job queue is empty", dict$worker.id))
      do.call(job["fun"], job["argv"])
      return(NULL)
    })
  tryCatch({
    do.call(job["fun"], job["argv"])
    log4r:::debug(dict$logger, sprintf("[id: %s] sending finish signal of job(hash:%s) to %s", dict$worker.id, job["hash"], path))
    send.socket(dict$socket[[path]], data=list(request="finish job", worker.id=dict$worker.id, job.hash = job["hash"], shared_secret = shared_secret))
    res <- receive.socket(dict$socket[[path]])
    info(dict$logger, sprintf("[id: %s] finish job(hash:%s)", dict$worker.id, job["hash"]))
  }, error = function(e) {
    error(dict$logger, sprintf("Job %s has following error message: %s", job["hash"], conditionMessage(e)))
  })
}