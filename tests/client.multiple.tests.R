library(parallel)
argv <- commandArgs(TRUE)
argv <- as.integer(argv)
cl <- makeForkCluster(argv[1])
clusterExport(cl, "argv")
clusterEvalQ(cl, {
  argv <- argv[2]
  source("client.single.tests.R")
})
stopCluster(cl)