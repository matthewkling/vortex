library(devtools)
library(maps)
library(mapproj)
library(ggplot2)
library(dplyr)
library(tidyr)
library(stringr)
if(!require(colormap)) install_github("matthewkling/colormap", "colormap") # Add the package colormap that Matt created because he's a bamf.
select <- dplyr::select


# load and merge data
#e <- read.csv("data/cleanedcounty.csv") # exposure data
ds <- read.csv("data/cleanedsocial.csv", stringsAsFactors=F) %>%
      select(-X, -land_area)
dr <- read.csv("data/cleanedrisk.csv", stringsAsFactors=F) %>%
      select(-land_area) %>%
      mutate(state_fips=as.integer(state_fips), county_fips=as.integer(county_fips))
FIPS <- maps::county.fips # fips-to-name dictionary from maps library


e <- full_join(ds, dr) %>%
      mutate(fips = as.integer(paste0(state_fips, str_pad(county_fips, 3, "left", 0)))) %>%
      left_join(FIPS, .)

input <- list(xv=names(e)[grepl("Mino", names(e))][1], yv=names(e)[grepl("tornado", names(e))][1])

shinyServer(
      function(input, output) {
            
            ### intro page content ###
            
            output$intro <- renderText({ "<< project description >>\n\n\n" })
            
            output$download_report <- downloadHandler(
                  filename="",
                  content=""
            )
            
            d <- reactive({
                  
                  # isolate data specific to user-selected variables
                  d <- data.frame(state_fips=e$state_fips,
                                  county_fips=e$county_fips,
                                  state=e$STNAME,
                                  pop=e$TOTPOP,
                                  x=e[,input$xv],
                                  y=e[,input$yv]) %>%
                        mutate(xlog=log10(x), ylog=log10(y))
                  
                  if(input$region != "USA") d <- filter(d, state %in% input$region)
                  
                  # get 2D color values
                  colvars <- c(switch(input$xscale, "linear"="x", "log10"="xlog"),
                               switch(input$yscale, "linear"="y", "log10"="ylog"))
                  goodrows <- apply(d[,colvars], 1, function(x) all(is.finite(x)))
                  d$color[goodrows] <- colors2d(na.omit(d[goodrows,colvars]))#, c("purple", "blue", "black", "red"))
                  d$color[is.na(d$color)] <- "gray95"
                  
                  return(d)
            })
            
            
            output$scatterplot <- renderPlot({
                  alpha <- switch(input$region, "USA"=.4, .8)
                  size <- switch(input$region, "USA"=6, 20)
                  p <- ggplot(d(), aes(x, y, alpha=pop)) +
                        geom_point(size = scales::rescale(log(d()$pop)) * size, 
                                   fill=d()$color, color=NA, 
                                   alpha=alpha, shape=21) +
                        theme_minimal() +
                        theme(text=element_text(size=20)) +
                        labs(x=paste0(input$xv, "\n(point size proportional to county population)"), y=input$yv)
                  if(input$smoother %in% c("lm", "loess")) p <- p + geom_smooth(color="black", se=input$se, method=input$smoother)
                  if(input$smoother=="gam") p <- p + geom_smooth(color="black", se=input$se, method="gam", formula = y ~ s(x))
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
            
            
            g <- reactive({
                  s <- data.frame(e[,input$groups])
                  s <- as.data.frame(as.matrix(s) * e$TOTPOP)
                  if(ncol(s)==1) names(s) <- input$groups
                  v <- e[,input$envvar]
                  if(class(v)=="factor") v <- as.character(v)
                  v <- as.numeric(v)
                  g <- data.frame(state_fips=e$state_fips,
                                  county_fips=e$county_fips,
                                  state=as.character(e$STNAME)) %>%
                        cbind(v) %>%
                        cbind(s) %>%
                        gather(race, pop, -v, -state_fips, -county_fips, -state) %>%
                        group_by(race) %>%
                        mutate(prop_pop = pop / sum(na.omit(pop))) %>%
                        na.omit()
                  
                  if(input$histogram_region != "USA") g <- filter(g, state==input$histogram_region)
                  #g$race[g$race=="s"] <- input$groups
                  
                  return(g)
            })
            
            m <- reactive({
                  m <- summarize(g(), wmean = weighted.mean(v, pop))
            })
            
            output$histogram <- renderPlot({
                  p <- ggplot(g(), aes(v, weight=prop_pop, color=factor(race), fill=factor(race))) +
                        geom_density(adjust=2, alpha=.2, size=.75) +
                        geom_vline(data=m(), aes(xintercept=wmean, color=factor(race)), size=1.5) +
                        #scale_fill_manual(values=colors) +
                        #scale_color_manual(values=colors) +
                        theme_minimal() +
                        theme(axis.text.y=element_blank(),
                              text=element_text(size=20),
                              legend.position="top") +
                        labs(x=input$envvar, 
                             y="\nrelative proportion of group",
                             color="group", fill="group")
                  if(input$scale=="log10") p <- p + scale_x_log10()
                  
                  plot(p)
            })
            
            
            
      }
)