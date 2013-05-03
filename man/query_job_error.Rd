\name{query_job_error}
\alias{query_job_error}
\title{query_job_error

Dump the jobs which occurred errors.
This function won't affect the job queue in redis server.}
\usage{
  query_job_error()
}
\value{
  data.frame includes the information of jobs. The 'title'
  attribute is used in shiny app
}
\description{
  query_job_error

  Dump the jobs which occurred errors. This function won't
  affect the job queue in redis server.
}

