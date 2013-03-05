library(RzmqJobQueue)
for(i in 1:10) {
  push_job_queue(list( list("function" = mean, "argv" = rnorm(sample(10:20, 1))) ))
}
stopifnot(length(RzmqJobQueue:::dict$job.queue) == 10)
job <- pop_job_queue()
stopifnot(length(RzmqJobQueue:::dict$job.queue) == 9)
clear_job_queue()
stopifnot(length(RzmqJobQueue:::dict$job.queue) == 0)
