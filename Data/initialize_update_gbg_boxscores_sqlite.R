# Target: Initialize and update NBA game-by-game sqlite database
# Author: Elvis Chou
# Updated at: 2015/10/30

library(dplyr)
library(XML)
library(rvest)
library(DBI)

rm(list=ls())

# tic <- Sys.time()
# toc <- Sys.time()
# difftime(toc, tic, units = c("secs"))

schedule <- read.csv("NBADATA_Schedule_2015.csv", stringsAsFactors = FALSE)
schedule$gameDate <- as.Date(as.character(schedule$gameDate), "%Y%m%d")
# should add type of game in function parameters
# tog: regular/ playoff
scrapeNBAgbg <- function(start, end){
    # y <- 2010:2015
    # # nG: number of games
    # # rS: regular season start
    # # rE: regular season end
    # # source: https://en.wikipedia.org/wiki/2010%E2%80%9311_NBA_season
    # nG <- c(1230, 990, 1230, 1230, 1230, 1230)
    # rS <- c("2010-10-26", "2011-12-25", "2012-10-30", "2013-10-29", "2014-10-28", "2015-10-27")
    # rE <- c("2011-04-13", "2012-04-26", "2013-04-17", "2014-04-16", "2015-04-15", "2015-04-13")
    # regDuration <- data.frame(year = y, nGames = nG, regStart = rS, regEnd = rE, stringsAsFactors = FALSE)
    
    if(as.Date(start) > as.Date(end)){
        stop("It has been updated.")
    }else{
        
        duration <- seq(from = as.Date(start), to = as.Date(end), by = 'days')
        
        # number of games
        nG <- dim(schedule[schedule$gameDate %in% duration, ])[1]
        
        boxscores <- list()
        length(boxscores) <- nG/2
        indexG <- 1
        # Scraping for loop
        
        
        for (i in seq_along(duration)){
            
            setDate <- gsub("-", "", duration[i])
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
                    
                    # Sys.sleep(time = abs(rnorm(1, mean = 0.5, sd = 2)))    
                    onehtml<-readLines(gamehtml[ig],warn=F,encoding = "UTF-8")
                    
                    if (length(grep("width=5%>MIN",onehtml))==0) {
                        print(paste(paste0(gameID[ig],":"), "The game was postponed.", sep = " "))
                        next
                    }
                    
                    pagetree <- XML::htmlTreeParse(onehtml[grep("logo-small logo-nba-small nba-small",onehtml)], useInternalNodes = TRUE, encoding='UTF-8')
                    # the second element of the vector "teamName" is Home team
                    teamName<-XML::xpathSApply(pagetree,'//th',xmlValue)
                    
                    # Sys.sleep(time = abs(rnorm(1, mean = 1.5, sd = 2))) 
                    data <- rvest::html(gamehtml[ig]) %>%
                        rvest::html_nodes("#my-players-table td") %>%
                        rvest::html_text()
                    
                    indexNostring <- which(data == "")
                    
                    gameBoxscores <- rbind(cbind(gameID[ig], setDate, "away", teamName[1], matrix(data[1:(indexNostring[1]-indexNostring[1] %% 15)], ncol = 15, byrow = TRUE)),
                                           cbind(gameID[ig], setDate, "home", teamName[2], matrix(data[(indexNostring[3]+2):(indexNostring[4]-(indexNostring[4]-indexNostring[3]-1) %% 15)], ncol = 15, byrow = TRUE)))
                    
                    boxscores[[indexG]] <- gameBoxscores
                    indexG <- indexG + 1
                }
            }
        }   
        
        boxscores.matrix <- do.call(rbind, boxscores)
        boxscores.df <- data.frame(boxscores.matrix, stringsAsFactors = FALSE)
        names(boxscores.df) <- c("GameID", "PlayDate", "HomeAway", "Team",
                                 "Player", "MIN", "FGM-A", "3PM-A", "FTM-A",
                                 "OREB", "DREB", "REB", "AST", "STL",
                                 "BLK", "TO", "PF", "PlusMinus", "PTS" )
        
        #  Seperate FGM-A/ 3PM-A/ FTM-A
        boxscores.df$PlayerPosition <- substr(boxscores.df$Player, regexpr(",", boxscores.df$Player) + 2, nchar(boxscores.df$Player))
        boxscores.df$PlayerName <- substr(boxscores.df$Player, 1, regexpr(",", boxscores.df$Player) - 1) 
        
        #  Seperate FGM-A/ 3PM-A/ FTM-A
        boxscores.df$FGM <- as.numeric(substr(boxscores.df$`FGM-A`, 1, regexpr("-", boxscores.df$`FGM-A`) - 1))
        boxscores.df$FGA <- as.numeric(substr(boxscores.df$`FGM-A`, regexpr("-", boxscores.df$`FGM-A`) + 1, nchar(boxscores.df$`FGM-A`)))
        boxscores.df$FG <- boxscores.df$FGM/ boxscores.df$FGA
        
        boxscores.df$ThrPM <- as.numeric(substr(boxscores.df$`3PM-A`, 1, regexpr("-", boxscores.df$`3PM-A`) - 1))
        boxscores.df$ThrPA <- as.numeric(substr(boxscores.df$`3PM-A`, regexpr("-", boxscores.df$`3PM-A`) + 1, nchar(boxscores.df$`3PM-A`))) 
        boxscores.df$Three <- boxscores.df$ThrPM/ boxscores.df$ThrPA
        
        boxscores.df$FTM <- as.numeric(substr(boxscores.df$`FTM-A`, 1, regexpr("-", boxscores.df$`FTM-A`) - 1))
        boxscores.df$FTA <- as.numeric(substr(boxscores.df$`FTM-A`, regexpr("-", boxscores.df$`FTM-A`) + 1, nchar(boxscores.df$`FTM-A`)))
        boxscores.df$FT <- boxscores.df$FTM/ boxscores.df$FTA
        
        selectedCol <- c(2, 6, 10:19)
        boxscores.df[, selectedCol] <- apply(boxscores.df[, selectedCol], 2, function(x) as.numeric(x))
        
        boxscores.df$AT <- boxscores.df$AST/ boxscores.df$TO
        boxscores.df$DD <- as.numeric(((boxscores.df$PTS >= 10) + (boxscores.df$REB >= 10) + (boxscores.df$AST >= 10) + (boxscores.df$BLK >= 10)) >= 2)
        
        # Reallocate order of columns
        boxscores.df <- boxscores.df %>% select(GameID, PlayDate, HomeAway, Team, PlayerName, PlayerPosition,
                                                MIN, FGM, FGA, FG, FTM, FTA, FT, 
                                                ThrPM, ThrPA, Three, PTS, OREB, DREB, REB,
                                                AST, STL, BLK, TO, AT, PF, PlusMinus, DD)   
        
        return(boxscores.df)    
    }
}

UpdateToDb <- function(db, tablename){
    binary.db.exist <- dbExistsTable(db$con, tablename)
    # end <- gsub("-", "", as.character(Sys.Date() - 2))
    end <- as.character(Sys.Date() - 1)    

    if(binary.db.exist){
        box <- tbl(db, tblname)
        dates <- collect(select(box, PlayDate))
        max.date <- as.Date(as.character(max(dates$PlayDate)), "%Y%m%d")
        
        start <- as.character(max.date + 1)
        
        boxsc.df <- scrapeNBAgbg(start, end)
        
        db_insert_into(con = db$con, table = tablename, values = boxsc.df) 
    } else{
        # assign start of duration
        start <- "2015-10-27"
        
        boxsc.df <- scrapeNBAgbg(start, end)
        
        copy_to(db, boxsc.df, name = tablename, temporary = FALSE)
    }
}    

db <- src_sqlite('/Users/Sheng-KaiChou/NBADATA.sqlite3', create = TRUE)
tblname <- "gamebygame"
UpdateToDb(db, tblname)


box <- tbl(db, tblname)
dates <- collect(select(box, PlayDate))
max.date <- as.Date(as.character(max(dates$PlayDate)), "%Y%m%d")
as.character(max.date + 1)

# rm(db)
# gc()

