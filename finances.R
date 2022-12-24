library(DBI)
library(dbplyr)
library(dplyr)

personaldb <- dbConnect(duckdb::duckdb(),
                        dbdir="/home/georgy/personal.duckdb",
                        read_only=F)

make.transaction <- function(){
  values <- list(
    Transaction.Date = readline("Date in format YYYY-mm-DD: "),
    Transaction.Time = readline("Time in format HH:MM: "),
    Amount = readline("Amount, negative '-' for spending: "),
    Category = readline("Category: "),
    Commentary = readline("What have you done?! : "))
  data.frame(values)
}

send.transaction <- function(data){
  dbAppendTable(personaldb, 'finances', data)
  output <- tbl(personaldb, 'finances')%>% collect()%>% tail()
  output
}

new.transaction <- function(){
  send.transaction(data=make.transaction())
}

end.transaction <- function(){
  dbDisconnect(personaldb, shutdown=T)
}
