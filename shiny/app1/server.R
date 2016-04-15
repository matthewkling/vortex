library(devtools)
library(maps)
library(mapproj)
library(ggplot2)
library(dplyr)
library(tidyr)
library(stringr)
if(!require(colormap)) install_github("matthewkling/colormap", "colormap") # Add the package colormap that Matt created because he's a bamf.
select <- dplyr::select


# load data
ds <- read.csv("data/cleanedsocial.csv", stringsAsFactors=F) %>%
      mutate(fips = as.integer(paste0(state_fips, str_pad(county_fips, 3, "left", 0)))) %>%
      select(-STNAME, -CTYNAME, -state_fips, -county_fips, -land_area)

dr <- read.csv("data/cleanedrisk.csv", stringsAsFactors=F) %>%
      #select(-land_area) %>%
      mutate(state_fips=as.integer(state_fips),
             county_fips=as.integer(county_fips)) %>%
      mutate(fips = as.integer(paste0(state_fips, str_pad(county_fips, 3, "left", 0)))) %>%
      select(-CTYNAME, -state_fips, -county_fips)

# fips-to-name dictionary from maps library;
FIPS <- maps::county.fips
FIPS$polyname <- as.character(FIPS$polyname)
FIPS$polyname[FIPS$polyname=="florida,miami-dade"] <- "florida,dade"

# a clean counties table with the proper number and order of counties for plotting
cty <- readRDS("data/counties.rds") %>%
      mutate(polyname = name) %>%
      select(polyname) %>%
      left_join(., FIPS) %>%
      mutate(ID=1:n())

#if(!all.equal(ds$fips, dr$fips)) stop("social and risk data are misaligned")
e <- cbind(dr, select(ds, -fips))
fill <- function(x) na.omit(x)[1]
e <- left_join(cty, e) %>%
      group_by(ID) %>%
      summarise_each(funs(fill)) %>%
      ungroup() %>%
      filter(!duplicated(ID))
#if(!all.equal(cty$fips, e$fips)) stop("incorrect county structure")
e <- as.data.frame(e)


# fill in some missing values -- this is a patch that shold maybe be transferred to the data prep scripts
na2min <- function(x){
      x[is.na(x) | x<0] <- min(na.omit(x[x>=0]))
      return(x)
}
e <- mutate_each_(e, funs(na2min), names(e)[grepl("tot_intensity", names(e))]) %>%
      mutate(population_density = TOTPOP/land_area,
             Income_Dollars = as.integer(as.character(sub(",", "", Income_Dollars))))


vars <- read.csv("data/variable_names", stringsAsFactors=F) %>%
      filter(category != "other") %>%
      arrange(desc(category), display)
r2d <- function(x) vars$display[match(x, vars$raw)]
d2r <- function(x) vars$raw[match(x, vars$display)]
g2r <- function(x) vars$raw[match(x, vars$group)]

# fake inputs for dev/debugging -- not used
input <- list(xv=vars$display[vars$category=="social"][1], 
              yv=vars$display[vars$category=="risk"][1],
              xscale="linear",
              yscale="linear",
              smoother="none",
              region="USA",
              palette="inferno",
              transpose_palette=F,
              groups=na.omit(vars$group[vars$group!=""])[1],
              envvar=vars$display[vars$category=="risk"][1],
              scale="linear",
              histogram_region="USA")


shinyServer(
      function(input, output) {
            
            ### intro tab content ###
            
            output$download_report <- downloadHandler(
                  filename="",
                  content=""
            )
            
            
            ### explore correlations tab content ###
            
            output$title1 <- renderText({
                  beforeparens <- function(x){
                        if(grepl("\\(", x)) return(substr(x, 1, regexpr("\\(", x)[1]-2))
                        return(x)}
                  paste(toupper(beforeparens(input$yv)), "versus", 
                        toupper(beforeparens(input$xv)), "in",
                        sub("USA", "the USA", toupper(input$region)))
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
                  if(input$transpose_palette) palette[c(2,4)] <- palette[c(4,2)]
                  d$color[goodrows] <- colors2d(na.omit(d[goodrows,colvars]), palette[1:4])
                  d$color[is.na(d$color)] <- palette[5]
                  
                  return(d)
                  
                  #map("county", regions=".", fill=TRUE, col=d$color, 
                  #    resolution = 0, lty = 0, projection = "polyconic", 
                  #    myborder = 0, mar = c(0,0,0,0))
                  
            })
            
            
            output$scatterplot <- renderPlot({
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
                  if(input$xscale=="log10") p <- p + scale_x_log10()
                  if(input$yscale=="log10") p <- p + scale_y_log10()
                  
                  plot(p)
            })
            
            
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
            
            
            ### compare groups tab content ###
            
            output$title2 <- renderText({
                  beforeparens <- function(x){
                        if(grepl("\\(", x)) return(substr(x, 1, regexpr("\\(", x)[1]-2))
                        return(x)}
                  title <- paste0(beforeparens(input$envvar), ": demographic groups compared")
                  if(input$histogram_region != "USA") title <- sub(":", paste0("in", input$histogram_region, ":"), title)
                  title
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
                        gather(race, pop, -v, -state) %>%
                        group_by(race) %>%
                        mutate(prop_pop = pop / sum(na.omit(pop))) %>%
                        na.omit()
                  
                  if(input$histogram_region != "USA") g <- filter(g, state==input$histogram_region)
                  
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