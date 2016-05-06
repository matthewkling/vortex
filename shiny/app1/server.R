library(plyr)
library(markdown)
library(devtools)
library(maps)
library(mapproj)
library(ggplot2)
library(grid)
library(gridExtra)
library(gridBase)
library(dplyr)
library(tidyr)
library(stringr)
library(mgcv)
if(!require(colormap)) install_github("matthewkling/colormap", "colormap")
select <- dplyr::select

shinyServer(
      function(input, output) {
            
            
            ### intro tab content ###
            
            output$katrina <- renderImage({
                  dims <- c(1919, 558)
                  scale = .7
                  list(src = "www/Katrina_Storm.jpg",
                       contentType = 'image/jpg',
                       width = dims[1]*scale,
                       height = dims[2]*scale,
                       alt = "Hurricane Katrina")
            }, deleteFile = F)
            
            output$workflow <- renderImage({
                  dims <- c(960,540)
                  scale = 1.3
                  list(src = "www/workflow_diagram.png",
                       contentType = 'image/png',
                       width = dims[1]*scale,
                       height = dims[2]*scale,
                       alt = "Project workflow diagram")
            }, deleteFile = F)
            
            output$report <- downloadHandler(
                  filename="demographics_of_disaster.pdf",
                  content=function(file){
                        file.copy("www/demographics-disaster.pdf", file)
                  }
            )
            
            ### explore correlations tab content ###
            
            output$title1 <- renderUI({
                  HTML(paste(paste(capfirst(beforeparens(input$yv)), "vs."),
                             capfirst(beforeparens(input$xv)),
                             switch(input$region, 
                                    "USA"="in the United States",
                                    paste("in", input$region)),
                             sep="<br/>"))
            })
            
            d <- reactive({
                  
                  # isolate data specific to user-selected variables
                  d <- data.frame(fips=e$fips,
                                  #state_fips=e$state_fips,
                                  #county_fips=e$county_fips,
                                  state=e$STNAME,
                                  pop=e$TOTPOP,
                                  x=e[,d2r(input$xv)],
                                  y=e[,d2r(input$yv)])
                  
                  # subset to selected state
                  if(input$region != "USA") d <- filter(d, state %in% input$region)
                  
                  d <- mutate(d,
                              xlog=log10(x), ylog=log10(y),
                              xpercentile=ecdf(x)(x), ypercentile=ecdf(y)(y))
                  
                  # approximate log-destroyed values
                  d$xlog[d$xlog==-Inf] <- min(d$xlog[is.finite(d$xlog)])
                  d$ylog[d$ylog==-Inf] <- min(d$ylog[is.finite(d$ylog)])
                  
                  # get 2D color values
                  colvars <- c(switch(input$xscale, "linear"="x", "log10"="xlog", "percentile"="xpercentile"),
                               switch(input$yscale, "linear"="y", "log10"="ylog", "percentile"="ypercentile"))
                  
                  goodrows <- apply(d[,colvars], 1, function(x) all(is.finite(x)))
                  palette <- switch(input$palette, 
                                    inferno=c("yellow", "red", "black", "blue", "white"),
                                    dayglo=c("yellow", "green", "dodgerblue", "magenta", "white"),
                                    alfalfa=c("darkgreen", "dodgerblue", "gray95", "yellow", "white"),
                                    proton=c("cyan", "black", "gray95", "magenta", "white"))
                  #if(input$transpose_palette) palette[c(2,4)] <- palette[c(4,2)]
                  d$color[goodrows] <- colors2d(na.omit(d[goodrows,colvars]), palette[1:4])
                  d$color[is.na(d$color)] <- palette[5]
                  
                  return(d)
            })
            
            scatterplot <- reactive({
                  d <- d()
                  
                  # set point size and transparency should vary by number of counties
                  alpha <- switch(input$region, "USA"=.6, .8)
                  size <- switch(input$region, "USA"=6, 20)
                  
                  # x axis label and data transformation
                  xlab <- input$xv
                  if(input$xscale=="percentile"){
                        d$x <- d$xpercentile
                        xlab <- paste0(xlab, ": percentile")
                  }
                  xlab <- paste0(xlab, "\n(point size proportional to county population)")
                  
                  # y axis label and data transformation
                  ylab <- input$yv
                  if(input$yscale=="percentile"){
                        d$y <- d$ypercentile
                        ylab <- paste0(ylab, ": percentile")
                  }
                  
                  # plot
                  p <- ggplot(d, aes(x, y, alpha=pop)) +
                        geom_point(size = scales::rescale(log(d$pop)) * size, 
                                   fill=d$color, color=NA, 
                                   alpha=alpha, shape=21) +
                        theme_minimal() +
                        theme(text=element_text(size=20)) +
                        labs(x=xlab, y=ylab)
                  
                  # apply smoothers and variable transformations
                  if(input$smoother %in% c("lm", "loess")) p <- p + geom_smooth(color="black", se=input$se, method=input$smoother)
                  if(input$smoother=="gam") p <- p + geom_smooth(color="black", se=input$se, method="gam", formula = y ~ s(x))
                  if(input$yscale=="log10") p <- p + scale_y_log10()
                  if(input$xscale=="log10") p <- p + scale_x_log10()
                  
                  return(p)
            })
            
            output$scatterplot <- renderPlot({ plot(scatterplot()) })
            
            output$map <- renderPlot({ 
                  region <- tolower(input$region)
                  if(input$region=="USA") region <- "."
                  map("county", regions=region, fill=TRUE, col=d()$color, 
                      resolution = 0, lty = 0, projection = "polyconic", 
                      myborder = 0, mar = c(0,0,0,0))
                  map("state", regions=region, col = "white", fill = FALSE, add = TRUE,
                      lty = 1, lwd = 1, projection = "polyconic", 
                      myborder = 0, mar = c(0,0,0,0))
            }, height=600)
            
            output$download_correlation_plot <- downloadHandler(
                  filename = function() { paste0(beforeparens(input$yv), "_vs_", beforeparens(input$xv), ".png") },
                  content = function(file) {
                        
                        png(file, width=1200, height=600)
                        vp.scatter <- viewport(height=unit(1, "npc"), width=unit(0.45, "npc"), 
                                               just=c("left","top"), 
                                               y=1, x=0)
                        vp.map <- viewport(height=unit(1, "npc"), width=unit(0.55, "npc"), 
                                           just=c("left","top"), 
                                           y=1, x=0.45)
                        
                        
                        pushViewport(vp.map)
                        grid.rect()
                        par(plt = gridPLT(), new=TRUE)
                        
                        region <- tolower(input$region)
                        if(input$region=="USA") region <- "."
                        map("county", regions=region, fill=TRUE, col=d()$color, 
                            resolution = 0, lty = 0, projection = "polyconic", 
                            myborder = 0, mar = c(0,0,0,0))
                        map("state", regions=region, col = "white", fill = FALSE, add = TRUE,
                            lty = 1, lwd = 1, projection = "polyconic", 
                            myborder = 0, mar = c(0,0,0,0))
                        popViewport(1)
                        
                        plot(scatterplot(), vp=vp.scatter)
                        
                        
                        dev.off()
                  })
            
            
            
            ### compare groups tab content ###
            
            output$title2 <- renderUI({
                  HTML(paste(capfirst(beforeparens(input$envvar)),
                             "exposure comparison",
                             switch(input$histogram_region, 
                                    "USA"="for the United States",
                                    paste("for", input$histogram_region)),
                             sep="<br/>"))
            })
            
            g <- reactive({
                  s <- data.frame(e[,g2r(input$groups)])
                  s <- as.data.frame(as.matrix(s) * e$TOTPOP)
                  if(ncol(s)==1) names(s) <- g2r(input$groups)
                  names(s) <- input$groups
                  v <- e[,d2r(input$envvar)]
                  if(class(v)=="factor") v <- as.character(v)
                  v <- as.numeric(v)
                  g <- data.frame(state=as.character(e$STNAME)) %>%
                        cbind(v) %>%
                        cbind(s) %>%
                        tidyr::gather(group, pop, -v, -state) %>%
                        dplyr::group_by(group) %>%
                        mutate(prop_pop = pop / sum(na.omit(pop)),
                               group=factor(group)) %>%
                        na.omit()
                  
                  if(input$histogram_region != "USA") g <- filter(g, state==input$histogram_region)
                  
                  return(g)
            })
            
            m <- reactive({
                  m <- group_by(g(), group) %>% dplyr::summarize(wmean = weighted.mean(v, pop))
                  m
            })
            
            histogram <- reactive({
                  p <- ggplot() +
                        geom_area(data=g(), 
                                     aes(v, ..density.., weight=prop_pop, color=factor(group), fill=factor(group)),
                                     alpha=.15, size=.5, bins=15, position="identity", stat="bin") +
                        geom_vline(data=m(), aes(xintercept=wmean, color=factor(group)), size=1.5) +
                        theme_minimal() +
                        theme(axis.text.y=element_blank(),
                              text=element_text(size=20),
                              legend.position="top") +
                        labs(x=input$envvar, 
                             y="\nrelative proportion of group",
                             color="group", fill="group")
                  if(input$scale=="log10") p <- p + scale_x_log10()
                  p
            })
            
            output$histogram <- renderPlot({ plot(histogram()) })
            
            output$download_histogram <- downloadHandler(
                  filename = function() { paste0(beforeparens(input$envvar), ".png") },
                  content = function(file) {
                        png(file, width=800, height=600)
                        plot(histogram() +
                                   labs(title=paste(capfirst(beforeparens(input$envvar)),
                                                    "exposure comparison",
                                                    switch(input$histogram_region, 
                                                           "USA"="for the United States",
                                                           paste("for", input$histogram_region)))))
                        dev.off()
                  })
            
      }
)