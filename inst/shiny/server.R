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
  output$title <- renderUI({
    init_server(redis.flush=FALSE, redis.db.index=input$redis.index)
    name <- get_name()
    redisClose()
    if(is.null(name)) return(h4("No Title")) else return(h4(name))
  })
  output$bar <- renderUI({
    len <- list()
    init_server(redis.flush=FALSE, redis.db.index=input$redis.index)
    len[["queue"]] <- job_queue_len()
    len[["processing"]] <- job_processing_len()
    len[["finish"]] <- job_finish_len()
    redisClose()
    len.sum <- sum(unlist(len))
    retval <- sprintf('<meter value="%d" min="0" max="%d">%d out of %d</meter> %f', len[["finish"]], len.sum, len[["finish"]], len.sum, len[["finish"]] / len.sum * 100)
    HTML(paste(retval, "%"))
  })
})
