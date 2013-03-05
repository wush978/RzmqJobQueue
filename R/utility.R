# constants

worker.id <- paste(Sys.info()["nodename"], Sys.getpid(), sep=":")

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

.onAttach <- function(libname, pkgname) {
  dict$type <- "init"
  check_option("logfile", tempfile(fileext=".log"))
  check_option("level", log4r:::INFO)
  check_option("logformat", NULL)
  dict$logger <- create.logger(logfile=dict$logfile, level=dict$level, logformat=dict$logformat)
  cat(sprintf("log: %s \n", dict$logfile))
  dict$job.queue <- list()
}

