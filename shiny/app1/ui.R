
shinyUI(navbarPage(strong("DEMOGRAPHICS OF DISASTER"), 
                   
                   tabPanel("about",
                            textOutput("intro")
                   ),
                   
                   tabPanel("explore correlations",
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
                                         selectInput("smoother", "Smoother", choices=c("none", "lm", "loess", "gam"), selected="lm"),
                                         checkboxInput("se", label="show confidence interval", value=F)
                                  ),
                                  column(3,
                                         selectInput("region", "Region", choices=c("USA", unique(as.character(e$CensusRace...STNAME))))
                                  )
                                  
                            ),
                            hr(),
                            fluidRow(
                                  column(5,plotOutput("scatterplot", height="600px")),
                                  column(7,plotOutput("map"), height="600px")
                            )
                   ),
                   
                   tabPanel("compare groups",
                            fluidRow(
                                  column(3,
                                         selectInput("groups", "Select social groups", choices=names(e)[grepl("CensusRace", names(e))],
                                                     selected=names(e)[grepl("pop", names(e), ignore.case=T)][1], multiple=T, selectize=T)
                                  ),
                                  column(3,
                                         selectInput("envvar", "Select environmental variable", choices=names(e)[!grepl("CensusRace", names(e))],
                                                     selected=names(e)[grepl("tornado", names(e))][1], multiple=F, selectize=T)
                                  ),
                                  column(3,
                                         selectInput("scale", "Scale transformation", choices=c("linear", "log10"), selected="log10")
                                  ),
                                  column(3,
                                         selectInput("histogram_region", "Region", choices=c("USA", unique(as.character(e$CensusRace...STNAME))))
                                  )
                            ),
                            hr(),
                            fluidRow(
                                  plotOutput("histogram", height="650px")
                                  #column(5,plotOutput("scatterplot", height="500px")),
                                  #column(7,plotOutput("map"), height="600px")
                            )
                   )
                   
))