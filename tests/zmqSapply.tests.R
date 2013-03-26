library(RzmqJobQueue)
zmqSapply("tcp://*:12345", as.list(1:10), function(n) {
  if (runif(1) < 0.5) stop("testing error handling")
  letters[1:n]
  })
stopifnot(length(system("ps -ef | grep do_job.R", intern = TRUE)) == 2)