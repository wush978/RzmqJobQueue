\name{zmqSapply}
\alias{zmqSapply}
\title{zmqSapply}
\usage{
  zmqSapply(path, X, FUN, argv.template = list(),
    init_fun = function() { }, init_argv = list(),
    num_worker = parallel::detectCores(),
    shared_secret = "default", title = "No Title",
    redis.host = "localhost", redis.port = 6379,
    redis.timeout = 2147483647L, redis.db.index = 1L,
    redis.flush = TRUE)
}
\arguments{
  \item{path}{character, indicate the ip and port of the
  \code{server}}

  \item{X}{a list of varying arguments. \code{X} is similar
  to the argument \code{X} of function
  \code{\link{sapply}}.}

  \item{FUN}{a function executed on workers. \code{FUN} is
  similar to the argument \code{FUN} of function
  \code{\link{sapply}}. This argument is also passed to
  \code{\link{gen_job_set}} as arugment
  \code{argv.enumerate}.}

  \item{argv.template}{see \code{\link{gen_job_set}}}

  \item{init_fun}{a function which is executed once after
  the \code{worker} is registered.}

  \item{num_worker}{a integer to decide how many workers
  will be spawn on \code{server}. Note that you may
  dynamically link and unlink workers to zmqJobQueue.}

  \item{shared_secret}{A tested feature to do a simple
  authorization between \code{server} and \code{worker}.}

  \item{title}{A title of this series of jobs. Displayed in
  the monitor.}

  \item{redis.host,}{redis.port, redis.timeout. The
  parameter of the backend redis server. See
  \code{\link{init_server}} and
  \code{\link{redisConnect}}.}

  \item{redis.db.index}{The index used for this series of
  jobs.}

  \item{redis.flush}{Whether to flush the content of redis
  server. See \code{\link{init_server}}}
}
\description{
  A high level function to parallely execute jobs on
  multiple machines
}

