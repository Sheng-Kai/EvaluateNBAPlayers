library(dplyr)
library(ggplot2)

data <- read.csv("~/NBADATA_gbg_Dirty_2014.csv", stringsAsFactors = FALSE)

#  Seperate FGM-A/ 3PM-A/ FTM-A
data$PlayerPosition <- substr(data$Player, regexpr(",", data$Player) + 2, nchar(data$Player))
data$PlayerName <- substr(data$Player, 1, regexpr(",", data$Player) - 1) 

#  Seperate FGM-A/ 3PM-A/ FTM-A
data$FGM <- as.numeric(substr(data$`FGM-A`, 1, regexpr("-", data$`FGM-A`) - 1))
data$FGA <- as.numeric(substr(data$`FGM-A`, regexpr("-", data$`FGM-A`) + 1, nchar(data$`FGM-A`)))
data$FG <- data$FGM/ data$FGA
    
data$ThrPM <- as.numeric(substr(data$`3PM-A`, 1, regexpr("-", data$`3PM-A`) - 1))
data$ThrPA <- as.numeric(substr(data$`3PM-A`, regexpr("-", data$`3PM-A`) + 1, nchar(data$`3PM-A`))) 
data$Three <- data$ThrPM/ data$ThrPA

data$FTM <- as.numeric(substr(data$`FTM-A`, 1, regexpr("-", data$`FTM-A`) - 1))
data$FTA <- as.numeric(substr(data$`FTM-A`, regexpr("-", data$`FTM-A`) + 1, nchar(data$`FTM-A`)))
data$FT <- data$FTM/ data$FTA

selectedCol <- c(6, 10:19)
data[, selectedCol] <- apply(data[, selectedCol], 2, function(x) as.numeric(x))

data$AT <- data$AST/ data$TO
data$DD <- as.numeric(((data$PTS >= 10) + (data$REB >= 10) + (data$AST >= 10) + (data$BLK >= 10)) >= 2)

# Reallocate order of columns
data <- data %>% select(GameID, PlayDate, HomeAway, Team, PlayerName, PlayerPosition,
                        MIN, FGM, FGA, FG, FTM, FTA, FT, 
                        ThrPM, ThrPA, Three, PTS, OREB, DREB, REB,
                        AST, STL, BLK, TO, AT, PF, PlusMinus, DD)

# Exclude all-star game
data <- data %>% filter(Team != "Western Conf All-stars", Team != "Eastern Conf All-stars")
