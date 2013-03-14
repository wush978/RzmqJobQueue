\docType{package}
\name{RzmqJobQueue}
\alias{RzmqJobQueue}
\alias{RzmqJobQueue-package}
\title{Configure RzmqJobQueue}
\usage{
  \code{options(arguments = value)}
}
\arguments{
  \item{RzmqJobQueue.logfile}{the path of logs. See
  \code{\link{create.logger}} for details.}

  \item{RzmqJobQueue.level}{the level of logger. See
  \code{\link{create.logger}} for details.}

  \item{RzmqJobQueue.logformat}{the format of logger. See
  \code{\link{create.logger}} for details.}
}
\description{
  Use following key of \code{\link{options}} to configure
  \code{RzmqJobQueue}:
}
\examples{
options(RzmqJobQueue.logfile = "/tmp/test.log")
library(RzmqJobQueue)
}

