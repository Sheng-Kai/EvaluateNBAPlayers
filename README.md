# Evaluate NBA Players

## Introduction

The repo is to evaluate NBA players as a tool to play Fantasy (I play Yahoo Fantasy). No matter what types of scoring in your league (Head to head/ Rotisserie), you will have to make decisions on selecting players in the following two stages:

1. Draft: In the draft stage, you will have to select players as your main team members. There are two types of drafts, standard and auction drafts. In the standard drafts, you have to decide the **order** of picks. In the auction drafts, you have to decide the **order** and the **price** of picks.    
		 
2. Starting Lineup Adjustment: You have to select **10** (at most) out of 13 players as your starting lineup periodically (daily or weekly).  

For a normal Fantasy player, you can just follow the metrices of the NBA players (Proj Value/ O-Rank/ Rank) provided by Yahoo to make decision. However, as a pro Fantasy player, you know the metrics are calcuated as an overall rating and the decisions are actually based on:

- **scoring items** (PTS, REB, etc.)

- **number of Fantasy players** (2-14)
 

## Repo Structure

You need NBA game-by-game data and schedule prior to evaluation. The data are mostly collected via web scraping and all relevant scripts are located in **Data** directory. After you collect the data, you have to predict the statistics of NBA players. In the beginning, 
I just follow the 2016 projections done by ESPN. My target is to predict the statistics game by game. All analysis scripts (precition and evaluation) are stored in **Analysis** directory.