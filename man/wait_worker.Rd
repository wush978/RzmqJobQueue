\name{wait_worker}
\alias{wait_worker}
\title{wait_worker

Listen to a specific port for workers and assign the first job in job queue if the worker asks a job.}
\usage{
  wait_worker(path = NULL, shared_secret = "default",
    terminate = TRUE, is_start = FALSE,
    is_clear_job_finish = FALSE)
}
\arguments{
  \item{path}{string, ex: "tcp://*:12345"}

  \item{shared_secret}{string, a secret shares with
  workers}

  \item{terminate}{unused}

  \item{is_start}{logical, check if the hash value of job
  under execution is empty or not}

  \item{is_clear_job_finish}{logical, whether clear the
  list of finished job or not}
}
\description{
  wait_worker

  Listen to a specific port for workers and assign the
  first job in job queue if the worker asks a job.
}

