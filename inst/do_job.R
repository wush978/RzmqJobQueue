#! /usr/bin/Rscript
cat(Sys.getpid())
capture.output({
  suppressWarnings(library(RzmqJobQueue, quietly=TRUE, warn.conflicts=FALSE))
  argv <- commandArgs(trailingOnly=TRUE)
  while(TRUE) do_job(argv[1], argv[2])
})
