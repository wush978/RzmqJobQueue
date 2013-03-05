#'@title do_job
#'@param path example: "tcp://localhost:5555"
#'@export
do_job <- function(path = NULL, shared_secret = "default") {
  if (is.null(path)) stop("\"path\" is required")
  context = init.context()
  socket = init.socket(context,"ZMQ_REQ")
  stopifnot(connect.socket(socket,path))
  send.socket(socket, data=list(worker.id=worker.id, type=dict$type, shared_secret = shared_secret))
  job <- receive.socket(socket)
  job$`function`(job$argv)
}