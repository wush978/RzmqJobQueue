\name{query_job_finish}
\alias{query_job_finish}
\title{query_job_finish

Dump the jobs which is finished
This function won't affect the job queue in redis server.}
\usage{
  query_job_finish()
}
\value{
  data.frame includes the information of jobs. The 'title'
  attribute is used in shiny app
}
\description{
  query_job_finish

  Dump the jobs which is finished This function won't
  affect the job queue in redis server.
}

