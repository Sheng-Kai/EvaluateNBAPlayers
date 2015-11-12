# Target:Generate dataset for evaluating players 
# Author: Elvis Chou
# Updated at: 2015/10/27

# Combine:
# (1) 2015 Yahoo Fantasy projectd value
# (2) 2015 ESPN projected season average: GP, MIN, FG,	FT, ThrPM, REB, AST, AT, STL, BLK, TO, PTS
# (3) 2014 season average: FGA, FTA, ThrPA, Three, double double (DD)
rm(list=ls())

yahooFantasy <- read.csv("~/NBADATA_YahooFantasy_ProjValue_2015.csv", stringsAsFactors = FALSE)
espnProj <- read.csv("~/NBADATA_ESPN_ProjStats_2015.csv", stringsAsFactors = FALSE)
seasonAvg2014 <- read.csv("~/NBADATA_SeasonAvg_2014.csv", stringsAsFactors = FALSE)

# Delete 
cancel <- which(yahooFantasy$PlayerName %in% c("Chris Johnson", "Marcus Thornton") & yahooFantasy$PlayerTeam %in% c("BOS", "CLE"))
yahooFantasy <- yahooFantasy[-cancel,]
cancel <- which(espnProj$PlayerName %in% c("Chris Johnson", "Marcus Thornton") & espnProj$Team %in% c("BOS", "CLE"))
espnProj <- espnProj[-cancel,] 

seasonAvg2014 <- seasonAvg2014[,c("PlayerName", "GP", "MIN", "FG", "FGA", "FT", "FTA", "Three", "ThrPM", "ThrPA", 
                                  "PTS", "REB", "AST", "STL", "BLK", "TO")] 

names(seasonAvg2014)[2:16] <- paste0(names(seasonAvg2014)[2:16], "2014")

# View(espnProj[espnProj$PlayerName == "Louis Williams",])
# Louis Williams -> Lou Williams
espnProj$PlayerName[espnProj$PlayerName == "Louis Williams"] <- "Lou Williams"
seasonAvg2014$PlayerName[seasonAvg2014$PlayerName == "Louis Williams"] <- "Lou Williams"
espnProj$PlayerName[espnProj$PlayerName == "Otto Porter Jr."] <- "Otto Porter"
seasonAvg2014$PlayerName[seasonAvg2014$PlayerName == "Otto Porter Jr."] <- "Otto Porter"

# NA: TO = 1, Others = 0
data <- yahooFantasy %>%
    left_join(espnProj, by = "PlayerName") %>%
    left_join(seasonAvg2014, by = "PlayerName") 


# sum(data$PlayerName %in% c("Chris Johnson", "Marcus Thornton"))
# data[is.na(data$eTO),"eTO"] <- 1
# data[data$eTO == 0,"eTO"] <- 1
# data[is.na(data)] <-0
# data[data$ProjValue == 0, "ProjValue"] <- 1
# data[data$PlayerName %in% selected, ]

write.csv(data, "~/NBADATA_ProjStats_2015.csv", row.names = FALSE)



