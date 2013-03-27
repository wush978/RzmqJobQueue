library(RzmqJobQueue)
zmqSapply("tcp://*:12346", list(n=as.list(1:10)), function(n) {
  Sys.sleep(runif(1, 0, 2))
  if (runif(1) < 0.5) stop("testing error handling")
  letters[1:n]
  })
