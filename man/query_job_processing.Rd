\name{query_job_processing}
\alias{query_job_processing}
\title{query_job_processing

Dump the jobs which is under executing for monitoring.
This function won't affect the job queue in redis server.}
\usage{
  query_job_processing()
}
\value{
  data.frame includes the information of jobs. The 'title'
  attribute is used in shiny app
}
\description{
  query_job_processing

  Dump the jobs which is under executing for monitoring.
  This function won't affect the job queue in redis server.
}

