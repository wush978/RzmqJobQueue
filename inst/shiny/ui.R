library(shiny)
library(RzmqJobQueue)

shinyUI(bootstrapPage(
  headerPanel("Status"),
  mainPanel(
    tabsetPanel(
      tabPanel("Job Queue", value="job.queue", tableOutput("job.queue")),
      tabPanel("Job Processing", value="job.processing", tableOutput("job.processing")),
      tabPanel("Job Finished", value="job.finish", tableOutput("job.finish")),
      id = "tabs"
      )
    )
  ))
