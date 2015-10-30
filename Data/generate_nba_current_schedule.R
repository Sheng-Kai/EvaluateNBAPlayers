
schTable <- read.csv("NBADATA_Schedule_Table_2015.csv", stringsAsFactors = FALSE)
schTable <- schTable[-31,]

schDataframe <- reshape2::melt(schTable, id = c("Date"))
names(schDataframe) <- c("chosenTeam", "gameDate", "oppTeam")

schDataframe$gameDate <- as.character(schDataframe$gameDate)
schDataframe <- schDataframe[schDataframe$oppTeam != "",]
schDataframe <- schDataframe[schDataframe$gameDate != "Date.1",]

schDataframe$chosenTeam <- toupper(schDataframe$chosenTeam) 
schDataframe$oppTeam <- toupper(schDataframe$oppTeam)

temp <- do.call(rbind, strsplit(schDataframe$gameDate , split = "\\."))
month <- temp[, 2]
day <- temp[, 3]
year <- ifelse(month %in% c(10, 11, 12), "2015", "2016")
schDataframe$gameDate <- gsub("-", "", as.character(as.Date(paste(year, month, day, sep = "-"))))




# iden: identifier for home/away
schDataframe$iden <- as.integer(grepl("@", schDataframe$oppTeam))
schDataframe$oppTeam <- gsub("@ ", "",schDataframe$oppTeam)

schDataframe$homeaway <- ifelse(schDataframe$iden == 1, "away", "home")

schDataframe <- schDataframe[, c("gameDate", "chosenTeam", "homeaway", "oppTeam")]

schDataframe$chosenTeam[schDataframe$chosenTeam == "GSW"] <- "GS"
schDataframe$chosenTeam[schDataframe$chosenTeam == "NO"] <- "NOR"
schDataframe$chosenTeam[schDataframe$chosenTeam == "UTH"] <- "UTA"
schDataframe$chosenTeam[schDataframe$chosenTeam == "WAS"] <- "WSH"

schDataframe$oppTeam[schDataframe$oppTeam == "GSW"] <- "GS"
schDataframe$oppTeam[schDataframe$oppTeam == "NO"] <- "NOR"
schDataframe$oppTeam[schDataframe$oppTeam == "UTH"] <- "UTA"
schDataframe$oppTeam[schDataframe$oppTeam == "WAS"] <- "WSH"

View(schDataframe)

write.csv(schDataframe, "NBADATA_Schedule_2015.csv", row.names = FALSE)



# data <- read.csv("NBADATA_Schedule_2015.csv", stringsAsFactors = FALSE)
# 
# data <- data[, -c(3)]
# 
# temp <- data %>%
#     full_join(data, by = "gameDate")
# 
# result <- table(temp[,-1])
# 
