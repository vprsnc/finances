library(shiny)
library(shinythemes)

provide.ui <- function(){

  ui <- fluidPage(
    theme = 'superhero',

    navbarPage(
      title = 'Personal finances app',
      provide.tabPanel.dashboard(),
      provide.tabPanel.details(),
      provide.tabPanel.input()

    )
  )

  ui

}
