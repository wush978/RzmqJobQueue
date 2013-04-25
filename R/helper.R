#'@title Monitor
#'
#'@description Spawn a process to monitor the state of jobqueue(redis server) through Shiny
#'
#'@export
monitor <- function() {
  stopifnot(require(shiny))
  runApp(system.file("shiny", package="RzmqJobQueue"))
}

#'@title Generate a set of jobs
#'
#'@description A helper function to generate jobs
#'
#'@param fun the function executed on worker
#'@param argv.enumerate a list of varying arguments
#'@param argv.template a list of static arguments
#'@export
gen_job_set <- function(fun = NULL, argv.enumerate = list(), argv.template = list()) {
  stopifnot(length(unique(sapply(argv.enumerate, length))) == 1)
  stopifnot(is.function(fun))
  stopifnot(is.list(argv.enumerate))
  stopifnot(is.list(argv.template))
  n <- length(argv.enumerate[[1]])
  retval <- vector("list", length=n)
  for(i in 1:n) {
    argv <- argv.template
    for(name in names(argv.enumerate)) {
      argv[[name]] <- argv.enumerate[[name]][[i]]
    }
    retval[[i]] <- new("job", fun = fun, argv = argv)
  }
  return(retval)
}

#'@title Commit a list of jobs to redis server
#'
#'@param job.list a list of jobs to be committed
#'@param is.processbar logical, To determine whether a processbar is shown or not
#'@export
commit_job <- function(job.list, is.processbar = TRUE) {
  stopifnot(is.list(job.list))
  stopifnot(all(sapply(job.list, class) == "job"))
  if (is.processbar) {
    i <- 0
    cat("Submitting jobs...\n")
    pb <- txtProgressBar(max = length(job.list), style=3)
  }
  for(job in job.list) {
    push_job_queue(job)
    if (is.processbar) setTxtProgressBar(pb, i <- i + 1)
  }
  if (is.processbar) close(pb)
}

#'@title zmqSapply
#'
#'@description A high level function to parallely execute jobs on multiple machines
#'
#'@param path character, indicate the ip and port of the \code{server}
#'@param X a list of varying arguments. \code{X} is similar to the argument \code{X} of function \code{\link{sapply}}.
#'@param FUN a function executed on workers. \code{FUN} is similar to the argument \code{FUN} of function \code{\link{sapply}}. 
#'This argument is also passed to \code{\link{gen_job_set}} as arugment \code{argv.enumerate}.
#'@param argv.template see \code{\link{gen_job_set}}
#'@param init_fun a function which is executed once after the \code{worker} is registered.
#'@param num_worker a integer to decide how many workers will be spawn on \code{server}. 
#'Note that you may dynamically link and unlink workers to zmqJobQueue.
#'@param shared_secret A tested feature to do a simple authorization between \code{server} and \code{worker}.
#'@param title A title of this series of jobs. Displayed in the monitor.
#'@param redis.host, redis.port, redis.timeout. The parameter of the backend redis server. See \code{\link{init_server}} and \code{\link{redisConnect}}.
#'@param redis.db.index The index used for this series of jobs.
#'@param redis.flush Whether to flush the content of redis server. See \code{\link{init_server}}
#'@export
zmqSapply <- function(
  path, X, FUN, 
  argv.template = list(),
  init_fun = function() {},
  init_argv = list(),
  num_worker = parallel::detectCores(),
  shared_secret = "default", 
  title = "No Title",
  redis.host = "localhost", redis.port = 6379, redis.timeout = 2147483647L, 
  redis.db.index = 1L, redis.flush = TRUE)  
{
  dict$socket <- list()
  gc()
  init_server(redis.host, redis.port, redis.timeout, redis.db.index, redis.flush)
  set_name(title)
  job.list <- gen_job_set(fun=FUN, argv.enumerate=X, argv.template=argv.template)
  cat(sprintf("There are %d jobs to do...\n", length(job.list)))
  job.list.hash <- sapply(job.list, function(a) a["hash"])
  if (length(job.list.hash) != length(unique(job.list.hash))) {
    stop("Hash of jobs are the same. There is a collision of \"fun\" and \"argv\"!")
  }
  commit_job(job.list)
  worker.pid <- vector("integer", length=num_worker)
  for(i in 1:num_worker) {
    worker.pid[i] <- open_subprocess(script.name="do_job.R", sub("*", "localhost", path, fixed=TRUE), shared_secret)
  }
  on.exit({
    for(i in 1:num_worker) {
      pskill(worker.pid[i])
    }
  }, add = TRUE)
  set_init_job(new("job", fun = init_fun, argv = init_argv))
  wait_worker(path, is_start=TRUE, is_clear_job_finish=TRUE, terminate=FALSE)
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
  result <- sapply(value, function(a) a["result"][[1]], simplify=FALSE)
  names(result) <- sapply(value, function(a) a["hash"])
  result <- result[job.list.hash]
  names(result) <- NULL
  return(result)
}