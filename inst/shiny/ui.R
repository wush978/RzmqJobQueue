library(shiny)
library(RzmqJobQueue)

shinyUI(pageWithSidebar(
  headerPanel("Status"),
  sidebarPanel(
    numericInput("redis.index", "Index of Redis Server", 1L)
    ),
  mainPanel(
    tabsetPanel(
      tabPanel("Job Queue", value="job.queue", tableOutput("job.queue")),
      tabPanel("Job Processing", value="job.processing", tableOutput("job.processing")),
      tabPanel("Job Finished", value="job.finish", tableOutput("job.finish")),
      id = "tabs"
      )
    )
  ))
