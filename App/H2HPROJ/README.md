# NBA Fantasy H2H Projections(NBAH2HPROJ)

## Outline
- Why do I need NBAH2HPROJ?
- What is the black box in NBAH2HPROJ?
- How shoul I use NBAH2HPROJ?
- What will I see?

## Why do I need NBAH2HPROJ?
As a Fantasy H2H player, your team compete against a single other team over a week and teams are different every week. In most leagues, you have four moves in a week, i.e. you can adjust four players in your team. ** How do you know how to use your movse to get more wins? NBAH2HPROJ is designed to tell you the instruction.**

The difference of some statistics might be a huge gap between you and your opponent but some might be small. For example, NBAH2HPROJ would tell you the differences of REB, PTS and 3PM are -105, +35, -5 in the current roster. Consdiering the random effect, what will you do to get more wins? 

If you want to win in REB, you will have to get additional 15 REBs every day in a week. In most leagues (12-14 participants), it is hard to find 4 players (in FA or trade) to fullfill this gap without affecting other stats (you may lose your strentgh). The best way to adjust your roster is to find players with PTS and 3PM and give up players with REB (without PTS and 3PM). 

## What is the black box in NBAH2HPROJ?
The statistics are made up by players so the key factors we need to know to estimate statistics are:

- Time interval: Mon-Sun (US time zone)
- Player list: Who are in you player list?
- Injured players: You can't count stats of players who are [Out/ GTD/ INJ/ OFS](https://help.yahoo.com/kb/SLN6808.html). Basically, you will need to follow the news and get information as soon as the information are released.
- GP (game play): You need [NBA Schedule](http://rotoguru2.com/hoop/schedule.html) to estimate GP of players in the following week.
- Estimated stats of the games: You have to estimate the performance of palyers every game and aggregate stats. The estimation here is the combination of ESPN projections and average stats in 2014-15 and 2015-16.

## How sould I use NBAH2HPROJ?
As explain in the last section, you need to collect those data to get the estimated team stats. Actually you just need to input the first three data and NBAH2HPROJ will take care of everything else:

- Start NBAH2HPROJ:
	- remote [link](https://shengkai.shinyapps.io/H2HAdjustment)
	- local device: download source code and run in RStudio
- Select time interval: You can see the date selection widget **in the upper left side** of UI. Choose the start and the end of duration you want to estimate.
- Upload matchpus **csv** file: You have to upload player lists for you and your opponent **in the upper middle part** of UI. Row represents a Fantasy team. The first column is [team name] and the rest of 13 columns are [NBA player name]. Please click [See file sample](https://drive.google.com/file/d/0B-S1w3z_-BvCbmJDalBjVFNnUVU/view?usp=drive_web) to see the sample.
- Upload "Out list" **csv** file: You have to upload Out list for you and your opponent **in the upper right side** of UI. Row represents a NBA player. Please click [See file sample](https://drive.google.com/open?id=0B-S1w3z_-BvCX3FwR09jMjdsZWc) to see the sample.

## What will I see?
After you done the instructions in the last section, NBAH2HPROJ will automatically generate result in the lower part of UI. The result includes four parts which are located in four tab panels (from left to right): **Player List**, **Projected**, **Plot** and **Detail**.

**Player List** shows the matchups you upload and you can check if it is correct. **Projected** shows the team stats in the duration you put in the first step. 

**Plot** shows the time series of stats you slected in the upper left side of the tab. You can also choose the teams you want to compare with in the upper middle part of the tab. **Detail** shows the performance per game and estimated GP in the duration for all NBA players in a team(exclduing Out list). 

All tables are available to sort by click the head of the table.
