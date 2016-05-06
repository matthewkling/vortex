
shinyUI(navbarPage(strong("DEMOGRAPHICS of DISASTER"), 
                   windowTitle="demographics of disaster",
                   
                   tabPanel("about",
                            imageOutput("katrina"),
                            includeMarkdown("text/intro.md"),
                            hr(),
                            fluidRow(
                                  column(2, tags$a(class="btn btn-default", 
                                                   href="https://preview.overleaf.com/public/fpdvkktnsrbz/pdfs/56f36d34c9e2fb3b8321d455f3f4354e48f556f2/demographics-disaster.pdf",
                                                   "read the report")),
                                  column(2, tags$a(class="btn btn-default", href="https://github.com/matthewkling/vortex", "view github repository"))
                            ),
                            hr(),
                            imageOutput("workflow") 
                   ),
                   
                   tabPanel("explore correlations",
                            fluidRow(
                                  column(4,
                                         h2(htmlOutput("title1"), align="left")
                                  ),
                                  column(2,
                                         selectInput("xv", "X & Y variables", choices=vars$display, selected=vars$display[grepl("minority", vars$display)][1]),
                                         selectInput("yv", NULL, choices=vars$display, selected=vars$display[grepl("tornado", vars$display)][1])
                                  ),
                                  column(2,
                                         selectInput("xscale", "X & Y scale transformations", choices=c("linear", "log10", "percentile"), selected="percentile"),
                                         selectInput("yscale", NULL, choices=c("linear", "log10", "percentile"), selected="percentile")
                                  ),
                                  column(2,
                                         selectInput("smoother", "Smoother & color palette", choices=c("none", "lm", "loess", "gam"), selected="lm"),
                                         selectInput("palette", NULL, choices=c("inferno", "dayglo", "alfalfa", "proton"))#,
                                         #checkboxInput("transpose_palette", label="transpose", value=F)
                                         #checkboxInput("se", label="show confidence interval", value=F)
                                  ),
                                  column(2,
                                         selectInput("region", "Region", choices=c("USA", na.omit(unique(as.character(e$STNAME))))),
                                         downloadButton("download_correlation_plot", label="Download plot")
                                  )
                            ),
                            hr(),
                            fluidRow(
                                  column(5,plotOutput("scatterplot", height="600px")),
                                  column(7,plotOutput("map"), height="600px")
                            ),
                            br(),
                            hr(),
                            includeMarkdown("text/explore_correlations.md")
                            
                   ),
                   
                   tabPanel("compare groups",
                            fluidRow(
                                  column(4,
                                         h2(htmlOutput("title2"), align="left")
                                  ),
                                  column(2,
                                         selectInput("histogram_region", "Region", choices=c("USA", na.omit(unique(as.character(e$STNAME))))),
                                         downloadButton("download_histogram", label="Download plot")
                                  ),
                                  column(2,
                                         selectInput("groups", "Select social groups", choices=na.omit(vars$group[vars$group!=""]),
                                                     selected=na.omit(vars$group[vars$group!=""])[c(3,4)], multiple=T, selectize=T)
                                  ),
                                  column(2,
                                         selectInput("envvar", "Select environmental variable", choices=vars$display[vars$category=="risk"],
                                                     selected=vars$display[vars$category=="risk"][1], multiple=F, selectize=T)
                                  ),
                                  column(2,
                                         selectInput("scale", "Scale transformation", choices=c("linear", "log10"), selected="log10")
                                  )
                            ),
                            hr(),
                            fluidRow(
                                  plotOutput("histogram", height="650px")
                            ),
                            br(),
                            hr(),
                            includeMarkdown("text/compare_groups.md")
                   )
                   
))