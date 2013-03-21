\name{do_job}
\alias{do_job}
\title{do_job

Ask a job from the server, execute it, and report.
To merge the result of the job, the user should write its own logic in \code{job["fun"]}}
\usage{
  do_job(path = NULL, shared_secret = "default")
}
\arguments{
  \item{path}{example: "tcp://localhost:5555"}

  \item{shared_secret}{a secrete share with the server.}
}
\description{
  do_job

  Ask a job from the server, execute it, and report. To
  merge the result of the job, the user should write its
  own logic in \code{job["fun"]}
}

