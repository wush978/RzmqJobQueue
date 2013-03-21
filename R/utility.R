# helpers
get_opt_name <- function(s) {
  paste(.packageName, s, sep=".")
}

# variables
dict <- new.env()

# initiate

check_option <- function(key, default = NULL) {
  value <- getOption(get_opt_name(key))
  if (is.null(value)) {
    dict[[key]] <- default
  } else {
    dict[[key]] <- value
  }
}

#'@name RzmqJobQueue
#'@title Configure RzmqJobQueue
#'@docType package
#'@description
#'Use following key of \code{\link{options}} to configure \code{RzmqJobQueue}: 
#'@usage \code{options(arguments = value)}
#'@param RzmqJobQueue.logfile the path of logs. See \code{\link{create.logger}} for details.
#'@param RzmqJobQueue.level the level of logger. See \code{\link{create.logger}} for details.
#'@param RzmqJobQueue.logformat the format of logger. See \code{\link{create.logger}} for details.
#'@examples
#'options(RzmqJobQueue.logfile = "/tmp/test.log")
#'library(RzmqJobQueue)
.onAttach <- function(libname, pkgname) {
  dict$type <- "init"
  # Configure logger
  check_option("logfile", tempfile(fileext=".log"))
  check_option("level", log4r:::INFO)
  check_option("logformat", NULL)
  dict$logger <- create.logger(logfile=dict$logfile, level=dict$level, logformat=dict$logformat)
  cat(sprintf("log: %s \n", dict$logfile))
  # Configure redis
  options(RzmqJobQueue.is.server = FALSE)
  dict$context <- NULL
  dict$socket <- list()
  # constants
  dict$worker.id <- paste(Sys.info()["nodename"], Sys.getpid(), sep=":")
}

#'@export
.Last.lib <- function(libpath) {
}

#'@title init_server
#'
#'Connect to the redis server.
#'
#'@param redis.host string, the location of redis.host
#'@param redis.port int, the port
#'@param redis.timeout int, time(second) of timeout.
#'@param redis.db.index int, the index of redis server used to maintain the job queue
#'@param redis.flush logical, whether clear the index ofredis server or not
#'@export
init_server <- function(redis.host = "localhost", redis.port = 6379, redis.timeout = 2147483647L, redis.db.index = 1L, redis.flush=FALSE) {
  tryCatch(redisClose(), error=function(e) {
    error(dict$logger, conditionMessage(e))
  })
  options(RzmqJobQueue.is.server = TRUE)
  redisConnect(host = redis.host, port = redis.port, timeout = redis.timeout)
  redisSelect(redis.db.index)
  if (redis.flush) {
    redisFlushDB()
  }
}