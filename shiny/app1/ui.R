
shinyUI(fluidPage(
      br(),
      titlePanel("Climate Justice"),
      h4("Explore patterns in socioeconomic exposure to natural disasters"),
      hr(),
      fluidRow(
            column(3,
                   selectInput("xv", "X and Y variables", choices=names(e), selected=names(e)[grepl("Mino", names(e))][1]),
                   selectInput("yv", NULL, choices=names(e), selected=names(e)[grepl("tornado", names(e))][1])
            ),
            column(3,
                   selectInput("xscale", "X and Y scale transformations", choices=c("linear", "log10"), selected="log10"),
                   selectInput("yscale", NULL, choices=c("linear", "log10"), selected="log10")
            ),
            column(3,
                   selectInput("smoother", "Smoother", choices=c("none", "lm", "loess", "gam"), selected="lm")
            ),
            column(3,
                   selectInput("region", "Region", choices=c("USA", unique(as.character(e$CensusRace...STNAME))))
            )
            
      ),
      hr(),
      fluidRow(
            column(5,plotOutput("scatterplot", height="500px")),
            column(7,plotOutput("map"), height="600px")
      )
))