socket.type <- "ZMQ_REQ"

worker.id <- paste(Sys.info()["nodename"], Sys.getpid(), sep=":")

get_opt_name <- function(s) {
  paste(.packageName, s, sep=".")
}

dict <- new.env()

#'@useDynLib RzmqJobQueue
.onLoad <- function(libname, pkgname) {
  dict$type <- "init"
}

