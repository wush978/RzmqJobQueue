#'@title do_job
#'@param path example: "tcp://localhost:5555"
#'@export
do_job <- function(path = NULL, shared_secret = "default") {
  if (is.null(path)) stop("\"path\" is required")
  context = init.context()
  socket = init.socket(context,"ZMQ_REQ")
  stopifnot(connect.socket(socket,path))
  send.socket(socket, data=list(request="ask job", worker.id=dict$worker.id, type=dict$type, shared_secret = shared_secret))
  info(dict$logger, sprintf("[id: %s] asking job from %s", dict$worker.id, path))
  job <- receive.socket(socket)
  info(dict$logger, sprintf("[id: %s] receiving job(hash:%s) from %s", dict$worker.id, job$hash, path))
  job$`function`(job$argv)
  info(dict$logger, sprintf("[id: %s] sending finish signal of job(hash:%s) to %s", dict$worker.id, job$hash, path))
  send.socket(socket, data=list(request="finish job", worker.id=dict$worker.id, job.hash = job$hash, shared_secret = shared_secret))
#  res <- receive.socket(socket)
  info(dict$logger, sprintf("[id: %s] finish job(hash:%s)", dict$worker.id, job$hash))
}