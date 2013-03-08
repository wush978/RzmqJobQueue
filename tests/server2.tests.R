library(RzmqJobQueue)

for(i in 1:10) {
  push_job_queue(list(  list("function" = function(argv) mean(argv), argv = rnorm(10))  ))
}

wait_worker(path="tcp://*:12345")
