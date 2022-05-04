server <- function(input,output){
  output$recommendation_table <- DT::renderDataTable({
  RECS <- NULL
  if (isTruthy(input$selected_movies)) {
    # Rule out too popular movies early on
    too_popular <- POPULARITY$title[which(100 * POPULARITY$percentSeen > input$max_popularity)]
    
    # Keep popular movies that the user input
    too_popular <- setdiff(too_popular, input$selected_movies)
    
    min_support <- 4
    max_time <- 0
    
    RULES <- apriori(
      TRANS,
      parameter = list(
        supp = min_support / length(TRANS),
        conf = input$min_confidence,
        minlen = 2,
        maxtime = max_time
      ),
      appearance = list(
        none = too_popular,
        lhs = input$selected_movies,
        default = "rhs"
      ),
      control = list(
        verbose = FALSE
      )
    )
    
    if (length(RULES) > 0) {
      RULES <- RULES[!is.redundant(RULES)]
      RULES <- RULES[is.significant(RULES, TRANS)]
      
      RULESDF <- DATAFRAME(RULES, itemSep = " + ", setStart = "", setEnd = "")
      names(RULESDF)[1:2] <- c("BasedOn", "title")
      
      # Remove recs that the user gave as input
      RULESDF <- RULESDF[!(RULESDF$title %in% input$selected_movies), ]
      if (nrow(RULESDF) > 0) {
        RECS <- aggregate(confidence ~ title, data = RULESDF, FUN = max)
        
        RECS <- merge(RECS, POPULARITY, by = "title")
        
        RECS$item_id <- NULL
        RECS$countSeen <- NULL
        RECS$Year <- NULL
        names(RECS) <- c("Movie", "Confidence", "PercentSeen", "imdbRating")
        
        # Order the recommendations by confidence
        RECS <- RECS[order(RECS$Confidence, decreasing = TRUE), ]
        RECS <- head(RECS, input$number_of_recs)
        
        RECS <- if(input$sorting == 2) {RECS[order(RECS$Confidence, decreasing = TRUE), ]}
          else{if(input$sorting == 1){RECS[order(RECS$Movie, decreasing = TRUE), ]}
            else{if(input$sorting == 3){RECS[order(RECS$PercentSeen, decreasing = FALSE), ]}
              else{if(input$sorting == 4){RECS[order(RECS$imdbRating, decreasing = TRUE), ]}}}}
        
        RECS <- head(RECS, input$number_of_recs)
        
        # Take out confusing row names
        row.names(RECS) <- NULL
        
        RECS$Confidence <- round(RECS$Confidence * 100, 2)
        RECS$PercentSeen <- round(RECS$PercentSeen * 100, 2)
        
      }
    }
  }
  
  if (is.null(RECS)) {
    RECS <- data.frame(
      Error = "No recommendations with these parameters.  Add more movies, decrease confidence, or increase popularity!"
    )
  }
  
  RECS
  })
}