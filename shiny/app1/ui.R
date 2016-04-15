
shinyUI(navbarPage(strong("DEMOGRAPHICS OF DISASTER"), 
                   
                   tabPanel("about",
                            includeMarkdown("text/intro.md"),
                            hr(),
                            br(),
                            downloadButton("download_report", label="Download the report")
                   ),
                   
                   tabPanel("explore correlations",
                            fluidRow(
                                  column(2,
                                         selectInput("region", "Region", choices=c("USA", na.omit(unique(as.character(e$STNAME)))))
                                  ),
                                  column(2,
                                         selectInput("xv", "X and Y variables", choices=vars$display, selected=vars$display[vars$category=="social"][1]),
                                         selectInput("yv", NULL, choices=vars$display, selected=vars$display[vars$category=="risk"][1])
                                  ),
                                  column(2,
                                         selectInput("xscale", "X and Y scale transformations", choices=c("linear", "log10", "percentile"), selected="log10"),
                                         selectInput("yscale", NULL, choices=c("linear", "log10", "percentile"), selected="log10")
                                  ),
                                  column(2,
                                         selectInput("smoother", "Smoother", choices=c("none", "lm", "loess", "gam"), selected="lm"),
                                         checkboxInput("se", label="show confidence interval", value=F)
                                  ),
                                  column(2,
                                         selectInput("palette", "Color palette", choices=c("inferno", "dayglo", "alfalfa", "proton")),
                                         checkboxInput("transpose_palette", label="transpose", value=F)
                                  )
                                  
                            ),
                            hr(),
                            h3(textOutput("title1"), align="center"),
                            fluidRow(
                                  column(5,plotOutput("scatterplot", height="600px")),
                                  column(7,plotOutput("map"), height="600px")
                            ),
                            br(),
                            br(),
                            fluidRow(
                                  column(2,downloadButton("download_scatterplot", label="Download scatterplot")),
                                  column(8),
                                  column(2,downloadButton("download_map", label="Download map"))
                            ),
                            br(),
                            includeMarkdown("text/explore_correlations.md")
                            
                   ),
                   
                   tabPanel("compare groups",
                            fluidRow(
                                  column(3,
                                         selectInput("groups", "Select social groups", choices=na.omit(vars$group[vars$group!=""]),
                                                     selected=na.omit(vars$group[vars$group!=""])[c(3,4)], multiple=T, selectize=T)
                                  ),
                                  column(3,
                                         selectInput("envvar", "Select environmental variable", choices=vars$display[vars$category=="risk"],
                                                     selected=vars$display[vars$category=="risk"][1], multiple=F, selectize=T)
                                  ),
                                  column(3,
                                         selectInput("scale", "Scale transformation", choices=c("linear", "log10"), selected="log10")
                                  ),
                                  column(3,
                                         selectInput("histogram_region", "Region", choices=c("USA", na.omit(unique(as.character(e$STNAME)))))
                                  )
                            ),
                            hr(),
                            h3(textOutput("title2"), align="center"),
                            fluidRow(
                                  plotOutput("histogram", height="650px")
                                  #column(5,plotOutput("scatterplot", height="500px")),
                                  #column(7,plotOutput("map"), height="600px")
                            ),
                            br(),
                            br(),
                            fluidRow(
                                  column(2,downloadButton("download_histogram", label="Download histogram")),
                                  column(10)
                            ),
                            br(),
                            includeMarkdown("text/explore_correlations.md")
                   )
                   
))