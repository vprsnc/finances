#!/usr/bin/env Rscript
library(DBI)
library(dbplyr)

personaldb <- dbConnect(duckdb::duckdb(), dbdir="/home/georgy/personal.duckdb", read_only=F)


transaction <- function(tdate, ttime, amount, category, commentary){
  values <- list(Transaction.Date=tdate, Transaction.Time=ttime,
                 Amount=amount, Category=category, Commentary=commentary)
  data.frame(values)
}


## Transaction <- transaction(
##   tdate = getenv(),
##   ttime = getenv(),
##   amount = getenv(),
##   category = getenv(),
##   commentary = getenv()
## )

dbAppendTable(personaldb, "finances", Transaction)

dbDisconnect(personaldb, shutdown=T)
args <- commandArgs()
print(args)
