\name{job}
\alias{job}
\alias{job-class}
\title{job-class}
\description{
  job-class
}
\section{Slots}{
  \describe{ \item{\code{type}:}{The type of the job.
  Possible value: \code{normal}, \code{empty}, and
  \code{terminate}} \item{\code{fun}:}{The job will be
  executed by \code{do.call(fun, argv)}}
  \item{\code{argv}:}{The job will be executed by
  \code{do.call(fun, argv)}} \item{\code{hash}:}{The hash
  of the job} \item{\code{worker.id}:}{The id of worker who
  do the job} \item{\code{start.processing}:}{When the job
  is delivered to the worker}
  \item{\code{processing.time}:}{How much time to execute
  the job} }
}
\examples{
## Not run
job <- new("job", fun = base:::mean, argv = list(x = rnorm(10)))
push_job_queue(job)
## END(**Not run**)
}
\author{
  Wush Wu
}

