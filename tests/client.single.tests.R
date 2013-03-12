options("RzmqJobQueue.logfile" = "/tmp/client.log")
options("RzmqJobQueue.level" = log4r:::DEBUG)
library(RzmqJobQueue)
if (!exists("argv") argv <- 10
if (argv[1] != Inf) {
  for(i in 1:argv[1]) {
    do_job("tcp://localhost:12345")
  }
} else {
  while(TRUE) {
    do_job("tcp://localhost:12345")
  }
}