# Target: Scrape NBA game-by-game data from ESPN
# Author: Elvis Chou
# Updated at: 2015/10/27

library(dplyr)
library(XML)
library(rvest)

rm(list=ls())

tic <- Sys.time()
# Input time period
y <- 2010:2014
# nG: number of games
# rS: regular season start
# rE: regular season end
# source: https://en.wikipedia.org/wiki/2010%E2%80%9311_NBA_season
nG <- c(1230, 990, 1230, 1230, 1230)
rS <- c("2010-10-26", "2011-12-25", "2012-10-30", "2013-10-29", "2014-10-28")
rE <- c("2011-04-13", "2012-04-26", "2013-04-17", "2014-04-16", "2015-04-15")
regDuration <- data.frame(year = y, nGames = nG, regStart = rS, regEnd = rE, stringsAsFactors = FALSE)

# Scraping for loop
for(iy in 2013){

    seasonBoxscores <- list()
    length(seasonBoxscores) <- regDuration[regDuration$year == iy, "nGames"]
    indexSB <- 1
    
    start <- regDuration[regDuration$year == iy, "regStart"]
    end <- regDuration[regDuration$year == iy, "regEnd"]
    
    days <- seq(from = as.Date(start), to = as.Date(end), by = 'days' )
    
    for (i in seq_along(days)){
        
        setDate <- gsub("-", "", days[i])
        # setDate <- "20150215"
    
        html<-readLines(paste0("http://scores.espn.go.com/nba/scoreboard?date=",setDate),warn=F,encoding = "UTF-8")
        scriptdata <- html[grep("window.espn.scoreboardData",html)]
        indexStart <- unlist(gregexpr("gameId",scriptdata))
        
        # No games on this date?
        if(indexStart[1] == -1){
            print(paste(paste0(setDate,":"), "No games on this date.", sep = " "))
        } else{
            
            gameID <- rep(NA,length(indexStart)) 
            
            for (g in 1:length(gameID)) {
                gameID[g] <- substr(scriptdata,indexStart[g]+7,indexStart[g]+15)
            }
            
            gameID <- unique(gameID)
            gamehtml <- paste0("http://espn.go.com/nba/boxscore?gameId=",gameID)
            
            for(ig in 1:length(gamehtml)){
                
                Sys.sleep(time = abs(rnorm(1, mean = 0.5, sd = 2)))    
                onehtml<-readLines(gamehtml[ig],warn=F,encoding = "UTF-8")
                
                if (length(grep("width=5%>MIN",onehtml))==0) {
                    print(paste(paste0(gameID[ig],":"), "The game was postponed.", sep = " "))
                    next
                }
            
                pagetree <- XML::htmlTreeParse(onehtml[grep("logo-small logo-nba-small nba-small",onehtml)], useInternalNodes = TRUE, encoding='UTF-8')
                # the second element of the vector "teamName" is Home team
                teamName<-XML::xpathSApply(pagetree,'//th',xmlValue)
                
                Sys.sleep(time = abs(rnorm(1, mean = 1.5, sd = 2))) 
                data <- rvest::html(gamehtml[ig]) %>%
                    rvest::html_nodes("#my-players-table td") %>%
                    rvest::html_text()
                
                indexNostring <- which(data == "")
                
                gameBoxscores <- rbind(cbind(gameID[ig], setDate, "away", teamName[1], matrix(data[1:(indexNostring[1]-indexNostring[1] %% 15)], ncol = 15, byrow = TRUE)),
                                       cbind(gameID[ig], setDate, "home", teamName[2], matrix(data[(indexNostring[3]+2):(indexNostring[4]-(indexNostring[4]-indexNostring[3]-1) %% 15)], ncol = 15, byrow = TRUE)))
                
                seasonBoxscores[[indexSB]] <- gameBoxscores
                indexSB <- indexSB + 1
            }
        }
    }
    seasonBoxscores.matrix <- do.call(rbind, seasonBoxscores)
    seasonBoxscores.df <- data.frame(seasonBoxscores.matrix, stringsAsFactors = FALSE)
    names(seasonBoxscores.df) <- c("GameID", "PlayDate", "HomeAway", "Team",
                                   "Player", "MIN", "FGM-A", "3PM-A", "FTM-A",
                                   "OREB", "DREB", "REB", "AST", "STL",
                                   "BLK", "TO", "PF", "PlusMinus", "PTS" )
    fileName <- paste0("NBADATA_gbg_Dirty_", iy, ".csv")
    write.csv(seasonBoxscores.df, fileName, row.names = FALSE)
}

toc <- Sys.time
difftime(toc, tic, units = c("secs"))

db <- src_sqlite('/Users/Sheng-KaiChou/gamebygame.sqlite3', create = TRUE)    

copy_to(db, starting.lineup, name = "slineup", temporary = FALSE)




######################################################################################################
######################################################################################################
# db <- src_sqlite('/Users/Sheng-KaiChou/openWAR_2011-2015.sqlite3', create = TRUE)
# 
# atbats <- tbl(db, 'play_by_play')
# dates <- collect(select(atbats, date))
# dates <- dates$date
# 
# max.date <- max(as.Date(dates[!is.na(dates)], "%Y-%m-%d"))
# 
# update.start <- max.date + 1
# update.end <- as.Date(Sys.Date()) - 1


# find player id
# data <- html(gamehtml[ig]) %>%
#     html_nodes("#my-players-table a") %>%
#     html_attrs()
# player <- data.frame(href = sapply(data, names), playerid = do.call(rbind, data), stringsAsFactors = FALSE)
# player <- player[player$href == "href", 2]
# player <- substring(player, 36, nchar(player))
# playerid <- substring(player, 1, regexpr("/", player)-1)
# playerName <- substring(player, regexpr("/", player)+1, nchar(player))
# playerName <- sub("-", " ", playerName)