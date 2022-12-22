library(DBI)
library(dbplyr)
personaldb <- dbConnect(duckdb::duckdb(), dbdir="/home/georgy/personal.duckdb", read_only=F)
transaction <- function(tdate, ttime, amount, category, commentary){
  values <- list(Transaction.Date=tdate, Transaction.Time=ttime,
                 Amount=amount, Category=category, Commentary=commentary)
  data.frame(values)
}
Transaction <- transaction(
  tdate = readline("Date in format YYYY-mm-DD: "),
  ttime = readline("Time in format HH:MM: "),
  amount = readline("Amount, negative '-' for spending: "),
  category = readline("Category: "),
  commentary = readline("what did you do: ")
)
dbAppendTable(personaldb, "finances", Transaction)
dbDisconnect(personaldb, shutdown=T)
