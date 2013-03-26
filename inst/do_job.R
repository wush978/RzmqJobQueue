#! /usr/bin/Rscript
cat(Sys.getpid())
capture.output({
  suppressPackageStartupMessages(library(RzmqJobQueue))
  argv <- commandArgs(trailingOnly=TRUE)
  while(TRUE) do_job(argv[1], argv[2])
})
