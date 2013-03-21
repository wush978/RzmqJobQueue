\name{query_job_queue}
\alias{query_job_queue}
\title{query_job_queue

Dump the jobs in the job queue for monitoring.
This function won't affect the job queue in redis server.}
\usage{
  query_job_queue()
}
\value{
  data.frame includes the information of jobs. The 'title'
  attribute is used in shiny app
}
\description{
  query_job_queue

  Dump the jobs in the job queue for monitoring. This
  function won't affect the job queue in redis server.
}

