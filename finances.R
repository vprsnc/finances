library(DBI)
library(dbplyr)

personaldb <- dbConnect(duckdb::duckdb(), dbdir="/home/georgy/personal.duckdb", read_only=F)

categories <- c("Smoking", "Booze", "Transport", "Eatout", "Products", "Bigbuy",
                "Rent", "Taxes", "Salary", "Earnings")

transaction <- function(tdate, ttime, amount, category, commentary){
  values <- list(Transaction.Date=tdate, Transaction.Time=ttime,
                 Amount=amount, Category=category, Commentary=commentary)
  data.frame(values)
}

Transaction <- transaction(
  tdate = readline("Date in format YYYY-mm-DD: "),
  ttime = readline("Time in format HH:MM: "),
  amount = readline("Amount, negative '-' for spending: "),
  category = readline(categories),
  commentary = readline("what did you do: ")
)
