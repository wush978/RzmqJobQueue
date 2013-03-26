#! /usr/bin/Rscript
cat(Sys.getpid())
capture.output({
  suppressWarnings(library(RzmqJobQueue, quietly=TRUE))
  argv <- commandArgs(trailingOnly=TRUE)
  stopifnot(length(argv) == 3)
  while(TRUE) ping(argv[1], argv[2], as.integer(argv[3]))
})
