# Get positions of the players on Yahoo Fantasy

library(rvest)
library(dplyr)

rm(list=ls())

result <- data.frame(stringsAsFactors = FALSE)

for(i in 1:13){
    
    url <- paste0("http://basketball.fantasysports.yahoo.com/nba/draftanalysis?tab=AD&pos=ALL&sort=DA_AP&count=", (i-1)*50)

    pageSource.Fantasy <- readLines(url)
    indexPlayer <- grep('target=\"sports\">', pageSource.Fantasy)
    indexPrice <- grep('Alt Last', pageSource.Fantasy)
    
    tempPlayer <- pageSource.Fantasy[indexPlayer]
    
    playerName <- substr(tempPlayer,
                         regexpr('sports\">', tempPlayer) + nchar("sports\">"),
                         regexpr("</a> <span", tempPlayer) - 1)
    
    tempPosition <- substr(tempPlayer,
                           regexpr('class=\"Fz-xxs\">', tempPlayer) + nchar('class=\"Fz-xxs\">'),
                           nchar(tempPlayer) - 14)
    
    playerPosition <- substr(tempPosition,
                             regexpr("-", tempPosition) + 2,
                             nchar(tempPosition))
    
    temp <- pageSource.Fantasy[indexPrice][-1]
    temp <- substr(temp,
                   nchar("        </div></div></td><td class=\"\"><div >$"),
                   regexpr('</div></td><td class=\"\"><div >100%', temp) - 1)
    projValue <- substr(temp, 2, regexpr("div", temp) - nchar("div"))
    
    avgCost <- substr(temp, regexpr("div ", temp) + 6, nchar(temp))
    
    tempResult <- data.frame(PlayerName = playerName,
                             PlayerPosition = playerPosition,
                             ProjValue = projValue,
                             AvgCost = avgCost)
    
    result <- rbind(result, tempResult)
}

result[, 1:4] <- apply(result[, 1:4], 2, function(x) as.character(x))
result$ProjValue <- as.numeric(result$ProjValue)
result$AvgCost <- as.numeric(result$AvgCost)

result$C <- as.integer(grepl("C", result$PlayerPosition))
result$PF <- as.integer(grepl("PF", result$PlayerPosition))
result$SF <- as.integer(grepl("SF", result$PlayerPosition))
result$SG <- as.integer(grepl("SG", result$PlayerPosition))
result$PG <- as.integer(grepl("PG", result$PlayerPosition))

write.csv(result, "NBADATA_YahooFantasy_ProjValue_2015.csv", row.names = FALSE)
