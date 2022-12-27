library(shiny)
library(shinythemes)

ui <- fluidPage(
  theme = "superhero",

  littlePanel("Finances dashboard"),

  sidebarLayout(

    dateRangeInput(
      inputId = 'dateRange',
      label = 'Transaction Date',
      min = Sys.Date() -30, max = Sys.Date() + 30
    )

  )

  mainPanel(

    plotOutput(outputId = 'distPlot')

  )

)


server <- function(input, output){

  output$distPlot <- renderPlot({



  })

}
