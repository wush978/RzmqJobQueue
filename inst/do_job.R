#! /usr/bin/Rscript
cat(Sys.getpid())
capture.output({
  suppressPackageStartupMessages(library(RzmqJobQueue))
  library(RzmqJobQueue)
  argv <- commandArgs(trailingOnly=TRUE)
  init_worker(argv[1], argv[2])
  while(TRUE) do_job(argv[1], argv[2])
})
