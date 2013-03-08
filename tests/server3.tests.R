# test pop_job_queue when job_queue is empty

library(RzmqJobQueue)

for(i in 1:10) {
  push_job_queue(list(  list("function" = function(argv) Sys.sleep(argv), argv = rexp(1, 0.1))  ))
}

wait_worker(path="tcp://*:12345")
readline(prompt="pause")