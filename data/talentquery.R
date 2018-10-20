library("Lahman")
library("dplyr")

b <- Batting[Batting$yearID > 2011,]

b$PA <- b$AB + b$BB + b$HBP + b$SH + b$SF

b <- b[b$PA >= 200,]

batters <- data.frame("X1B" = (b$H - b$X2B - b$X3B - b$HR)/b$PA,
                      "X2B" = b$X2B/b$PA,
                      "X3B" = b$X3B/b$PA,
                      "HR" = b$HR/b$PA,
                      "UBB" = (b$BB - b$IBB)/b$PA,
                      "SO" = b$SO/b$PA,
                      "IBB" = b$IBB/b$PA,
                      "HBP" = b$HBP/b$PA,
                      "SH" = b$SH/b$PA,
                      "SF" = b$SF/b$PA)

write.csv(batters, "./talents/talent.csv")

b$OBP <- (batters$X1B + batters$X2B + batters$X3B + batters$HR + batters$UBB + batters$IBB + batters$HBP) / (1 - batters$SH - .000137)
b

hist(batters$SF)