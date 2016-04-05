library(maps)
library(mapproj)
library(ggplot2)
library(colormap)
library(dplyr)
library(tidyr)
library(stringr)
select <- dplyr::select


# load and merge data
e <- read.csv("data/cleanedcounty.csv") # exposure data
FIPS <- maps::county.fips # fips-to-name dictionary from maps library
e <- e %>%
      mutate(fips = as.integer(paste0(state_fips, str_pad(county_fips, 3, "left", 0)))) %>%
      left_join(FIPS, .)


shinyServer(
      function(input, output) {
            
            
            d <- reactive({
                  
                  # isolate data specific to user-selected variables
                  d <- data.frame(state_fips=e$state_fips,
                                  county_fips=e$county_fips,
                                  state=e$CensusRace...STNAME,
                                  pop=e$CensusRace...TOT_POP,
                                  x=e[,input$xv],
                                  y=e[,input$yv]) %>%
                        mutate(xlog=log10(x), ylog=log10(y))
                  
                  if(input$region != "USA") d <- filter(d, state==input$region)
                  
                  # get 2D color values
                  colvars <- c(switch(input$xscale, "linear"="x", "log10"="xlog"),
                               switch(input$yscale, "linear"="y", "log10"="ylog"))
                  goodrows <- apply(d[,colvars], 1, function(x) all(is.finite(x)))
                  d$color[goodrows] <- colors2d(na.omit(d[goodrows,colvars]))#, c("purple", "blue", "black", "red"))
                  d$color[is.na(d$color)] <- "gray95"
                  
                  return(d)
            })
            
            
            output$scatterplot <- renderPlot({
                  p <- ggplot(d(), aes(x, y, alpha=pop)) +
                        geom_point(size = scales::rescale(log(d()$pop)) * 6, 
                                   fill=d()$color, color=NA, 
                                   alpha=.5, shape=21) +
                        theme_minimal() +
                        labs(x=input$xv, y=input$yv)
                  if(input$smoother!="none") p <- p + geom_smooth(color="black", se=F, method=input$smoother)
                  if(input$xscale=="log10") p <- p + scale_x_log10()
                  if(input$yscale=="log10") p <- p + scale_y_log10()
                  plot(p)
            })
            
            
            output$map <- renderPlot({
                  region <- tolower(input$region)
                  if(input$region=="USA") region <- "."
                  map("county", regions=region, fill = TRUE, col = d()$color, 
                      resolution = 0, lty = 0, projection = "polyconic", 
                      myborder = 0, mar = c(0,0,0,0))
                  map("state", regions=region, col = "white", fill = FALSE, add = TRUE,
                      lty = 1, lwd = 1, projection = "polyconic", 
                      myborder = 0, mar = c(0,0,0,0))    
            }, height=600)
      }
)











# scatterplot
p <- ggplot(d, aes(x, y, alpha=pop)) +
      geom_point(size = scales::rescale(log(d$pop)) * 6, 
                 fill=d$color, color=NA, 
                 alpha=.5, shape=21) +
      geom_smooth(color="black", se=F) +
      theme_minimal() +
      labs(x=xv, y=yv)
if(logtrans) p <- p + scale_x_log10() + scale_y_log10()


# map
plot.new()
map("county", fill = TRUE, col = d$color, 
    resolution = 0, lty = 0, projection = "polyconic", 
    myborder = 0, mar = c(0,0,0,0))
map("state", col = "white", fill = FALSE, add = TRUE,
    lty = 1, lwd = 1, projection = "polyconic", 
    myborder = 0, mar = c(0,0,0,0))

