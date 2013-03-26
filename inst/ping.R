cat(Sys.getpid())
cat("\n")
capture.output({
  library(RzmqJobQueue)
  argv <- commandArgs(trailingOnly=TRUE)
  while(TRUE) ping(argv[1], argv[2], as.integer(argv[3]))
})
