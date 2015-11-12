library(shiny)
library(dplyr)
library(tidyr)
library(ggplot2)

shinyServer(function(input, output, session) {
    
    stats <- read.csv("NBADATA_ProjStats_2015_20151110.csv", stringsAsFactors = FALSE)
    
    nbaSch <- read.csv("NBADATA_Schedule_2015.csv", stringsAsFactors = FALSE)
    nbaSch$gameDate <- as.Date(as.character(nbaSch$gameDate), "%Y%m%d")
    
    projStats <- function(players, projstats, injured){
        output <- projstats %>% 
            filter(PlayerName %in% players) %>%
            filter(!(PlayerName %in% injured)) %>%
            summarise(eFG = round(sum(FGA2014*eFG*eGP, na.rm = TRUE)/sum(FGA2014*eGP,  na.rm = TRUE), digits = 3), 
                      eFT = round(sum(FTA2014*eFT*eGP, na.rm = TRUE)/sum(FTA2014*eGP,  na.rm = TRUE), digits = 3),
                      eThrPM = round(sum(eThrPM*eGP), digits = 1),
                      ePTS = round(sum(ePTS*eGP), digits = 1),
                      eREB = round(sum(eREB*eGP), digits = 1),
                      eAST = round(sum(eAST*eGP), digits = 1),
                      eSTL = round(sum(eSTL*eGP), digits = 1),
                      eBLK = round(sum(eBLK*eGP), digits = 1),
                      eTO = round(sum(eTO*eGP), digits = 1))    
    }
    
    detailStats <- function(players, projstats, injured){
        ownedStats <- projstats %>% 
            filter(PlayerName %in% players) %>%
            filter(!(PlayerName %in% injured)) %>%
            select(PlayerName, PlayerPosition, Team, eGP, eMIN,
                   round(eFG, digits = 3),
                   round(eFT, digits = 3),
                   round(eThrPM, digits = 1),
                   round(ePTS, digits = 1),
                   round(eREB, digits = 1),
                   round(eAST, digits = 1),
                   round(eSTL, digits = 1),
                   round(eBLK, digits = 1),
                   round(eTO, digits = 1))
    }
    
    observe({
        inFile <- input$file1
        
        if (is.null(inFile))
            return(NULL)
        
        ppp <- read.csv(inFile$datapath, stringsAsFactors = FALSE)
        
        updateSelectInput(session, "inSelect",
                          choices = sort(ppp[,1]),
                          selected = ppp[1,1]
        )
        
        updateSelectInput(session, "inSelect2",
                          choices = sort(ppp[,1]),
                          selected = ppp[,1]
        )
    })
    daterange <- reactive({input$dateRange})
    
    players <- reactive({
        inFile <- input$file1
    
    if (is.null(inFile))
        return(NULL)
    
    read.csv(inFile$datapath, stringsAsFactors = FALSE)
    })
    
    out <- reactive({
        inFile <- input$file2
        
        if (is.null(inFile))
            return(NULL)
        
        read.csv(inFile$datapath, stringsAsFactors = FALSE)
    })
    
    output$contents <- renderDataTable({players()})
    
    output$projected <- renderDataTable({
        
        date <- daterange()
        # date <- c(as.Date("2015-11-08"), as.Date("2015-11-15"))
        duration <- seq(from = date[1], to = date[2], by = 'days' )    
        # players <- read.csv("MatchupsMultani.csv", stringsAsFactors = FALSE)
        # out <- read.csv("OutPossible.csv", stringsAsFactors = FALSE)
        
        
        eGP <- nbaSch %>% 
            filter(gameDate %in% duration) %>%
            group_by(chosenTeam) %>%
            summarize(eGP = n())

        stats <- stats %>%
            left_join(eGP, by = c("Team" = "chosenTeam"))

        players <- players()
        out <- out()
            
        result <- list(dim(players[1]))
        for(i in 1:dim(players)[1]){
            result[[i]] <- c(Team = players[i,1], projStats(players[i,-1], stats, out[,1]))
        }
        tempresult <- matrix(unlist(do.call(rbind, result)), ncol = 10)
        resultoutput <- as.data.frame(tempresult, stringsAsFactors = FALSE)
        names(resultoutput) <- c("FantasyTeam", "eFG", "eFT", "eThrPM", "ePTS", "eREB", "eAST", "eSTL", "eBLK", "eTO")
        resultoutput[, 2:10] <- apply(resultoutput[, 2:10], 2, function(x) as.numeric(x))
        
        resultoutput
    })
    
    output$projectedPlot <- renderPlot({
        
        date <- daterange()
        # date <- c(as.Date("2015-11-08"), as.Date("2015-11-15"))
        
        duration <- seq(from = date[1], to = date[2], by = 'days' )     
        
        players <- players()
        
        out <- out()
        
        # players <- read.csv("MatchupsMultani.csv", stringsAsFactors = FALSE)
        # out <- read.csv("OutPossible.csv", stringsAsFactors = FALSE)
          
        b <- players %>% 
            tidyr::gather("Player", "PlayerName", 2:14)
        b <- b[,-2]
        names(b) <- c("FantasyTeam", "PlayerName")
        b <- b %>%
            filter(!(PlayerName %in% out[, 1]))
        
        stat <- stats %>% 
            filter(PlayerName %in% as.vector(as.matrix(players[,-1]))) %>%
            filter(!(PlayerName %in% out[, 1]))
            
        date <- nbaSch %>%
            filter(gameDate %in% duration) %>%
            select(gameDate, chosenTeam)
        
        temp <- stat %>%
            left_join(date, by = c("Team" = "chosenTeam"))
            
        result <- b %>% 
                left_join(temp, by = "PlayerName") 
                
        output <- result %>%
            group_by(FantasyTeam, gameDate) %>%
            summarise(FG = sum(FGA2014*eFG, na.rm = TRUE)/sum(FGA2014,  na.rm = TRUE),
                      FGA = sum(FGA2014, na.rm = TRUE),
                      FT = sum(FTA2014*eFT, na.rm = TRUE)/sum(FTA2014,  na.rm = TRUE),
                      FTA = sum(FTA2014, na.rm = TRUE),
                      ThrPM = sum(eThrPM, na.rm = TRUE),
                      PTS = sum(ePTS, na.rm = TRUE),
                      REB = sum(eREB, na.rm = TRUE),
                      AST = sum(eAST, na.rm = TRUE),
                      STL = sum(eSTL, na.rm = TRUE),
                      BLK = sum(eBLK, na.rm = TRUE),
                      TO = sum(eTO, na.rm = TRUE)) %>%
                mutate(
                    cumFG = order_by(gameDate, cumsum(FGA*FG)/cumsum(FGA)),
                    cumFT = order_by(gameDate, cumsum(FTA*FT)/cumsum(FTA)),
                    cumThrPM = order_by(gameDate, cumsum(ThrPM)),
                    cumPTS = order_by(gameDate, cumsum(PTS)),
                    cumREB = order_by(gameDate, cumsum(REB)),
                    cumAST = order_by(gameDate, cumsum(AST)),
                    cumSTL = order_by(gameDate, cumsum(STL)),
                    cumBLK = order_by(gameDate, cumsum(BLK)),
                    cumTO = order_by(gameDate, cumsum(TO))
                    )
        output$gameDate <- as.character(output$gameDate)
        output <- output %>%
            filter(FantasyTeam %in% input$inSelect2)
        
        plotresult <- ggplot(output, aes_string(x = "gameDate", y = input$selectItem, group = "FantasyTeam")) +
            geom_line(aes(color = FantasyTeam)) +
            xlab("Date") +
            ylab("stats")
        
        plotresult
    })
    
    output$detail <- renderDataTable({
        
        players <- players()
        out <- out()
        
        date <- daterange()
        duration <- seq(from = date[1], to = date[2], by = 'days' )    
        
        eGP <- nbaSch %>% 
            filter(gameDate %in% duration) %>%
            group_by(chosenTeam) %>%
            summarize(eGP = n())
        
        eGP <- data.frame(eGP, stringsAsFactors = FALSE)
        
        stats <- stats %>%
            left_join(eGP, by = c("Team" = "chosenTeam"))
        
        detailList <- detailStats(players[players$Team == input$inSelect,-1], stats, out[,1])
        
        detailList
    })
})