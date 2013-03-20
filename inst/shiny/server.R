library(shiny)

shinyServer(function(input, output) {
  library(RzmqJobQueue)
  output$job.queue <- renderTable(reactive({
    init_server(redis.flush=FALSE, redis.db.index=input$redis.index)
    result <- query_job_queue()
    redisClose()
    result
  })())
  output$job.processing <- renderTable(reactive({
    init_server(redis.flush=FALSE, redis.db.index=input$redis.index)
    result <- query_job_processing()
    redisClose()
    result
  })())
  output$job.finish <- renderTable(reactive({
    init_server(redis.flush=FALSE, redis.db.index=input$redis.index)
    result <- query_job_finish()
    redisClose()
    result
  })())
  
})
