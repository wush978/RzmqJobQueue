library(RzmqJobQueue)
# base:::debug(do_job)
do_job("tcp://localhost:12345")

library(parallel)
cl <- makePSOCKcluster(2)
clusterEvalQ(cl, Sys.getpid())
clusterEvalQ(cl, {
  temp <- list()
  temp[[RzmqJobQueue:::get_opt_name("logfile")]] <- sprintf("/tmp/%d.log", Sys.getpid())
  options(temp)
  library(RzmqJobQueue)
  # Sys.getpid()
  # RzmqJobQueue:::dict$worker.id
  while(TRUE) {
    do_job("tcp://localhost:12345")
  }
  getOption(RzmqJobQueue:::get_opt_name("logfile"))
})
# stopCluster(cl)