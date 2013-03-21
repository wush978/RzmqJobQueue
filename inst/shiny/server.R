library(shiny)

shinyServer(function(input, output) {
  library(RzmqJobQueue)
  output$job.queue <- renderTable(reactive({
    init_server(redis.flush=FALSE, redis.db.index=input$redis.index)
    result <- query_job_queue()
    redisClose()
    result
  })(), sanitize.rownames.function = function(str) {
    data <- get("data", parent.frame(2))
    str <- paste("<a title='", attr(data, "title"), "'>", str, "</a>")
    return(str)
  })
  output$job.processing <- renderTable(reactive({
    init_server(redis.flush=FALSE, redis.db.index=input$redis.index)
    result <- query_job_processing()
    redisClose()
    result
  })(), sanitize.rownames.function = function(str) {
    data <- get("data", parent.frame(2))
    str <- paste("<a title='", attr(data, "title"), "'>", str, "</a>")
    return(str)
  })
  output$job.finish <- renderTable(reactive({
    init_server(redis.flush=FALSE, redis.db.index=input$redis.index)
    result <- query_job_finish()
    redisClose()
    result
  })(), sanitize.rownames.function = function(str) {
    data <- get("data", parent.frame(2))
    str <- paste("<a title='", attr(data, "title"), "'>", str, "</a>")
    return(str)
  })
  
})
