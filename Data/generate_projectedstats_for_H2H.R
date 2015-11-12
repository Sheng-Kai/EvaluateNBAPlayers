
rm(list=ls())

projStats <- read.csv("~/NBADATA_ProjStats_2015.csv", stringsAsFactors = FALSE)
# names(projStats)[23:27] <- paste0(names(projStats)[23:27], "2014") 

# checkSameName <- table(projStats$PlayerName) 
# checkSameName[checkSameName > 1]


# "Marcus Thornton"
# "Matthew Dellavedova"
# projStats[projStats$PlayerName == "Marcus Thornton",]

db <- src_sqlite('/Users/Sheng-KaiChou/NBADATA.sqlite3', create = TRUE)
src_tbls(db)
tblname <- "gamebygame"
box <- tbl(db, tblname)
stats2015 <- collect(box)

SeasonAvg2015 <- stats2015 %>% 
    group_by(PlayerName) %>%
    dplyr::summarize(
        GP = n(),
        MIN = mean(MIN),
        FG = sum(FGM, na.rm = TRUE)/sum(FGA, na.rm = TRUE), 
        FGM = mean(FGM, na.rm = TRUE),
        FGA = mean(FGA, na.rm = TRUE), 
        FT = sum(FTM, na.rm = TRUE)/sum(FTA, na.rm = TRUE), 
        FTM = mean(FTM, na.rm = TRUE),
        FTA = mean(FTA, na.rm = TRUE), 
        Three= sum(ThrPM, na.rm = TRUE)/sum(ThrPA, na.rm = TRUE), 
        ThrPM = mean(ThrPM, na.rm = TRUE), 
        ThrPA = mean(ThrPA, na.rm = TRUE), 
        PTS = mean(PTS, na.rm = TRUE), 
        REB = mean(REB, na.rm = TRUE),
        AST = mean(AST, na.rm = TRUE),
        STL = mean(STL, na.rm = TRUE),
        BLK = mean(BLK, na.rm = TRUE),
        DD = mean(DD, na.rm = TRUE),
        TO = mean(TO, na.rm = TRUE))     

names(SeasonAvg2015)[2:19] <- paste0(names(SeasonAvg2015)[2:19], "2015")
SeasonAvg2015$PlayerName[SeasonAvg2015$PlayerName == "Louis Williams"] <- "Lou Williams"
SeasonAvg2015$PlayerName[SeasonAvg2015$PlayerName == "Otto Porter Jr."] <- "Otto Porter"



data <- projStats %>%
    left_join(SeasonAvg2015, by = "PlayerName")

# hist(data$FGA2014-data$FGA2015)
# hist(data$FTA2014-data$FTA2015)

data$FGA2014[is.na(data$FGA2014)] <- data$FGA2015[is.na(data$FGA2014)]
data$FTA2014[is.na(data$FTA2014)] <- data$FTA2015[is.na(data$FTA2014)]

data$FGA2014[!is.na(data$FGA2014-data$FGA2015) & abs(data$FGA2014-data$FGA2015) >=5] <- data$FGA2014[!is.na(data$FGA2014-data$FGA2015) & abs(data$FGA2014-data$FGA2015) >=5]
data$FTA2014[!is.na(data$FTA2014-data$FTA2015) & abs(data$FTA2014-data$FTA2015) >=5] <- data$FTA2014[!is.na(data$FTA2014-data$FTA2015) & abs(data$FTA2014-data$FTA2015) >=5]


# item <- "FG"
# e <- paste0("e",item)
# eval(parse(text = e))


data$eMIN[is.na(data$eMIN)] <- ifelse(is.na(data$MIN2015[is.na(data$eMIN)]), data$MIN2014[is.na(data$eMIN)], data$MIN2015[is.na(data$eMIN)])
data$eFG[is.na(data$eFG)] <- ifelse(is.na(data$FG2015[is.na(data$eFG)]), data$FG2014[is.na(data$eFG)], data$FG2015[is.na(data$eFG)])
data$eFT[is.na(data$eFT)] <- ifelse(is.na(data$FT2015[is.na(data$eFT)]), data$FT2014[is.na(data$eFT)], data$FT2015[is.na(data$eFT)])
data$eThrPM[is.na(data$eThrPM)] <- ifelse(is.na(data$ThrPM2015[is.na(data$eThrPM)]), data$ThrPM2014[is.na(data$eThrPM)], data$ThrPM2015[is.na(data$eThrPM)])
data$ePTS[is.na(data$ePTS)] <- ifelse(is.na(data$PTS2015[is.na(data$ePTS)]), data$PTS2014[is.na(data$ePTS)], data$PTS2015[is.na(data$ePTS)])
data$eREB[is.na(data$eREB)] <- ifelse(is.na(data$REB2015[is.na(data$eREB)]), data$REB2014[is.na(data$eREB)], data$REB2015[is.na(data$eREB)])
data$eAST[is.na(data$eAST)] <- ifelse(is.na(data$AST2015[is.na(data$eAST)]), data$AST2014[is.na(data$eAST)], data$AST2015[is.na(data$eAST)])
data$eSTL[is.na(data$eSTL)] <- ifelse(is.na(data$STL2015[is.na(data$eSTL)]), data$STL2014[is.na(data$eSTL)], data$STL2015[is.na(data$eSTL)])
data$eBLK[is.na(data$eBLK)] <- ifelse(is.na(data$BLK2015[is.na(data$eBLK)]), data$BLK2014[is.na(data$eBLK)], data$BLK2015[is.na(data$eBLK)])
data$eTO[is.na(data$eTO)] <- ifelse(is.na(data$TO2015[is.na(data$eTO)]), data$TO2014[is.na(data$eTO)], data$TO2015[is.na(data$eTO)])

selected <- c("PlayerName", "PlayerPosition", "Team", 
              "eMIN", "eFG", "eFT", "eThrPM", "eREB", "eAST", "eSTL", "eBLK", "eTO", "ePTS", 
              "FGA2014", "FTA2014")

data <- data[, selected]


# "Marcus Thornton"
# "Matthew Dellavedova"
# data[data$PlayerName == "Matthew Dellavedova",]
# selected <- c("Nikola Vucevic", "Ian Mahinmi", "Willie Cauley-Stein", "Lou Williams", "Arron Afflalo", "Louis Williams")
# selected <- c("Otto Porter", "T.J. McConnell")
# data[data$PlayerName %in% selected, ]

rm(db)
gc()


write.csv(data, paste0("NBADATA_ProjStats_2015_", gsub("-", "", as.Date(Sys.time())), ".csv"), row.names = FALSE)
