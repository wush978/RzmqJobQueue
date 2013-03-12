options("RzmqJobQueue.logfile" = "/tmp/server.log")
options("RzmqJobQueue.level" = log4r:::DEBUG)
options("RzmqJobQueue.redis.flush" = TRUE)
library(RzmqJobQueue)
init_server()

for(i in 1:10) {
  job <- new("job", fun=base:::mean, argv = list(x = rnorm(10)))
  push_job_queue(job)
}

wait_worker(path="tcp://*:12345")
