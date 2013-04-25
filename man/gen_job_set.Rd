\name{gen_job_set}
\alias{gen_job_set}
\title{Generate a set of jobs}
\usage{
  gen_job_set(fun = NULL, argv.enumerate = list(),
    argv.template = list())
}
\arguments{
  \item{fun}{the function executed on worker}

  \item{argv.enumerate}{a list of varying arguments}

  \item{argv.template}{a list of static arguments}
}
\description{
  A helper function to generate jobs
}

