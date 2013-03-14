library(shiny)

shinyServer(function(input, output) {
  library(RzmqJobQueue)
  init_server(redis.flush=FALSE)
  output$job.queue <- renderTable(reactive({
    query_job_queue()
  })())
  output$job.processing <- renderTable(reactive({
    query_job_processing()
  })())
  output$job.finish <- renderTable(reactive({
    query_job_finish()
  })())
  
})
