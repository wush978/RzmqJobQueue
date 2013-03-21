\name{init_server}
\alias{init_server}
\title{init_server

Connect to the redis server.}
\usage{
  init_server(redis.host = "localhost", redis.port = 6379,
    redis.timeout = 2147483647L, redis.db.index = 1L,
    redis.flush = FALSE)
}
\arguments{
  \item{redis.host}{string, the location of redis.host}

  \item{redis.port}{int, the port}

  \item{redis.timeout}{int, time(second) of timeout.}

  \item{redis.db.index}{int, the index of redis server used
  to maintain the job queue}

  \item{redis.flush}{logical, whether clear the index
  ofredis server or not}
}
\description{
  init_server

  Connect to the redis server.
}

