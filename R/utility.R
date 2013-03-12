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
#'@param RzmqJobQueue.redis.host See \code{\link{redisConnect}} for details.
#'@param RzmqJobQueue.redis.port See \code{\link{redisConnect}} for details.
#'@param RzmqJobQueue.redis.timeout See \code{\link{redisConnect}} for details.
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

#'@export
init_server <- function(redis.host = "localhost", redis.port = 6379, redis.timeout = 2147483647L) {
  tryCatch(redisClose(), error=function(e) {
    error(dict$logger, conditionMessage(e))
  })
  options(RzmqJobQueue.is.server = TRUE)
  check_option("redis.host", "localhost")
  check_option("redis.port", 6379)
  check_option("redis.timeout", 2147483647L)
  redisConnect(host = dict$redis.host, port = dict$redis.port, timeout = dict$redis.timeout)
  check_option("redis.db.index", 1L)
  redisSelect(dict$redis.db.index)
  if (pmatch(readline(prompt="Do you want to flush the redis database?(y/n)"), c("y", "n"), nomatch=2) == 1) {
    redisFlushDB()
  }
}