ui <- fluidPage(
  titlePanel('Movie Recomendation'),
  sidebarLayout(
    sidebarPanel(
      selectInput(
        inputId = 'selected_movies',
        label = 'Select your top movies',
        choices = ALL_MOVIE_TITLES,
        multiple = TRUE
      ),
      numericInput(
        inputId = 'number_of_recs',
        label = 'Select number of recomendations you would like',
        value = 10
      ),
      numericInput(
        inputId = 'min_confidence',
        label = 'Select you minimum confidence',
        value = .25
      ),
      numericInput(
        inputId = 'max_popularity',
        label = 'Select you max popularity',
        value = 5
      ),
      radioButtons(
        inputId = "sorting", 
        label = h3("Sort by"),
        choices = list("Confidence" = 2,"Movie" = 1, "Popularity" = 3, "imdbRating" = 4), 
        selected = 2),
      hr(),
      submitButton(
        text = 'Recommend me a movie!'
      )
    ),
    mainPanel(
    DT::dataTableOutput('recommendation_table')
    )
  )
)