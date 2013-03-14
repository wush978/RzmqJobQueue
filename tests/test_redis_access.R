library(RzmqJobQueue)
job <- new("job", fun=mean, argv=list(x=rnorm(100)))
redisConnect()

redisLPush("test", job)
temp <- redisRPop("test")
all.equal(job, temp)

redisHSet("testH", field="test", job)
temp <- redisHGet("testH", "test")
all.equal(job, temp)