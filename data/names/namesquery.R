library("Lahman")
library("plyr")
library("rstudioapi")

current_path <- getActiveDocumentContext()$path 

setwd(dirname(current_path))

first = Master$nameFirst[!is.na(Master$nameFirst)]
last = Master$nameLast[!is.na(Master$nameLast)]

first = count(first)
last = count(last)

write.csv(first, "./firstnames.csv")
write.csv(last, "./lastnames.csv")
