library(shiny)
library(shinythemes)
library(DT)
library(DBI)
library(dplyr)
library(RPostgreSQL)

source('setup.R')

categories <- list('Salary', 'Passive income', 'Food', 'Entertainment', 'BigBuy', 'Transport', 'Products')

ui <- fluidPage(
  theme = shinytheme('flatly'),

  navbarPage(
    title = 'Personal finances app',

    tabPanel( title = 'New transaction',

      sidebarPanel(
        title = 'Append transactions',

        tags$h3('Balance:'),
        verbatimTextOutput('balance'),

        tags$h3('New transaction:'),

        dateInput(inputId = 'tdate'       , label = 'Transaction date: ', value = Sys.Date() ),
        textInput(inputId = 'ttime'       , label = 'Transaction time: '),
        textInput(inputId = 'amount'      , label = 'Amount: '),
        selectInput(inputId = 'category'    , label = 'Category: ', choices = categories),
        textInput(inputId = 'commentary'  , label = 'Comment: '),

        actionButton(inputId = 'submit_but', label = 'Submit')

      ), # sidebarPanel

      mainPanel(

        h1("Last transactions:"),
        DT::dataTableOutput(outputId = 'last_trans')

      ) # mainPanel

    ), # tabPanel

    tabPanel(
      title = "Expenses",

      fluidRow(

        column( width = 4, offset = 1,

          plotOutput('expenses_barchart'),

        ), # column

        column( width = 4, offset = 1,

          plotOutput('expenses_piechart')

        ), # column

      ), # fluidRow

      fluidRow(

        column(width = 10, offset = 1,

               plotOutput('expenses_linechart')

               ) # column

      ), # fluidRow

    ), # tabPanel

    tabPanel(
      title = "Income",

      fluidRow(

        column( width = 4, offset = 1,

          plotOutput('income_barchart'),

        ), # column

        column( width = 4, offset = 1,

          plotOutput('income_piechart')

        ), # column

      ), # fluidRow

      fluidRow(

        column(width = 10, offset = 1,

               plotOutput('income_linechart')

               ) # column

      ), # fluidRow


    ), # tabPanel


  ) # navbarPage


) # fluidPage

server <- function(input, output){

  mydb <- dbConnect(dbDriver("PostgreSQL"),
                     dbname = dbname,
                     host = dbhostname,
                     port = dbport,
                     user = dbuser,
                     password = dbpass)

  observeEvent(input$submit_but, {

    newTrans <- list(

      Transaction.Date = input$tdate,
      Transaction.Time = input$ttime,
      Amount = input$amount,
      Category = input$category,
      Commentary = input$commentary

    )%>%data.frame() # newTrans

    dbAppendTable(mydb, 'finances', newTrans)

  }) # observeEvent

  all.transactions <- tbl(mydb, 'finances')


  count.expenses <- all.transactions%>%
    filter(Category != 'Salary')%>%
    filter(Category != 'Passive income')%>%
    group_by(Category)%>%
    summarise(count = n())%>%
    collect()

  output$expenses_barchart <- renderPlot({
    barplot(
      height = count.expenses$count,
      names.arg = count.expenses$Category,
      las = 2,
      ## col = '#b9c0ab',
      main = 'Expenses by quantity'
    )
  }) # output$barchart

  sum.expenses <- all.transactions%>%
    filter(Category != 'Salary')%>%
    filter(Category != 'Passive income')%>%
    group_by(Category)%>%
    summarise(sum = sum( abs(as.numeric(Amount)) ))%>%
    collect()

  output$expenses_piechart <- renderPlot({

    pie(
      x = sum.expenses$sum,
      labels = sum.expenses$Category,
      main = 'Expenses by amount'
    ) # pie

  }) # output$piechart

  daytoday.expenses <- all.transactions%>%
    filter(Category != 'Salary')%>%
    filter(Category != 'Passive income')%>%
    group_by(date = Transaction.Date)%>%
    summarise(sum = sum( abs(as.numeric(Amount)) ))%>%
    collect()


  output$expenses_linechart <- renderPlot({

    barplot(
      daytoday.expenses$sum,
      names.arg = daytoday.expenses$date,
      col = '#e66868',
      main = 'Day-to-day expenses'

    ) # barplot

  }) # output$expenses_linechart

  count.income <- all.transactions%>%
    filter(Category == 'Salary' | Category == 'Passive income')%>%
    group_by(Category)%>%
    summarise(count = n())%>%
    collect()

  output$income_barchart <- renderPlot({
    barplot(
      height = count.income$count,
      names.arg = count.income$Category,
      las = 2,
      ## col = '#b9c0ab',
      main = 'Incomes by quantity'
    )
  }) # output$barchart

  sum.income <- all.transactions%>%
    filter(Category == 'Salary' | Category == 'Passive income')%>%
    group_by(Category)%>%
    summarise(sum = sum( abs(as.numeric(Amount)) ))%>%
    collect()

  output$income_piechart <- renderPlot({

    pie(
      x = sum.income$sum,
      labels = sum.income$Category,
      main = 'Income by amount'
    ) # pie

  }) # output$piechart

  monthtomonth.income <- all.transactions%>%
    filter(Category == 'Salary' | Category == 'Passive income')%>%
    group_by(date = substring(Transaction.Date, 0, 7))%>%
    summarise(sum = sum( abs(as.numeric(Amount)) ))%>%
    collect()


  output$income_linechart <- renderPlot({

    barplot(
      monthtomonth.income$sum,
      names.arg = monthtomonth.income$date,
      col = '#e66868',
      main = 'Month-to-month income'
    ) # barplot

  }) # output$income_linechart

  last.transactions <- all.transactions%>%
    arrange(desc(Transaction.Date), desc(Transaction.Time))%>%
    collect(n = 100)

  output$last_trans <- DT::renderDataTable(last.transactions)

  balance <- all.transactions%>%
    select(Amount)%>%
    collect()

  output$balance <- as.numeric(balance$Amount)%>%
    sum()%>%
    renderText()

  onStop( function(){dbDisconnect(mydb, shutdown=T)} )

} # server

shinyApp(ui = ui, server = server)
