library(RzmqJobQueue)

for(i in 1:4) {
  push_job_queue(list(  list("function" = function(argv) Sys.sleep(argv), argv = rexp(1, 0.5))  ))
}

wait_worker(path="tcp://*:12345")
gc()
