library(RzmqJobQueue)

for(i in 1:5) {
  do_job("tcp://localhost:12345")
}