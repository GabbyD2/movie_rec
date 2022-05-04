library(arules)
library(shiny)

load("MOVIERECSpring2022.RData")

POPULARITY <- POPULARITY[POPULARITY$percentSeen * 100 >= 0.1, ]
ALL_MOVIE_TITLES <- sort(unique(POPULARITY$title))
