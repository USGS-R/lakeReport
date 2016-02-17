## Functions for making QW Timeseries plots

# pcode = (00665 OR 00666) for total phosphorus (mg/L)
# pcode = 32210 for chlorophyll (ug/L)
# pcode = 00078 for secchi depth (meters)

filterParmData <- function(data, pcode){
  data %>% 
    filter(parm_cd == pcode) %>% 
    select(sample_dt, result_va, coll_ent_cd)
}

calcTrophicIndex <- function(totalP, chlorophyll, secchi){
  
  totalP <- totalP %>% 
    mutate(TSI = 4.15 + (14.42 * log(totalP$result_va * 1000))) %>% 
    mutate(Timeseries = rep('totalP', nrow(totalP)))
  secchi <- secchi %>% 
    mutate(TSI = 60.0 - (14.41 * log(secchi$result_va))) %>% 
    mutate(Timeseries = rep('secchi', nrow(secchi)))
  chlorophyll <- chlorophyll %>% 
    mutate(TSI = 30.6 + (9.81 * log(chlorophyll$result_va))) %>% 
    mutate(Timeseries = rep('chlorophyll', nrow(chlorophyll)))
  
  TSI <- rbind(totalP, secchi, chlorophyll)
  return(TSI)
}

makeTimeseriesPlot <- function(parm_data, title, isTrophicIndex, axisFlip){
  if(!isTrophicIndex){
    usgs <- parm_data %>% filter(coll_ent_cd != "OBSERVER")
    observer <- parm_data %>% filter(coll_ent_cd == "OBSERVER")

    parm_plot <- plotSetup(parm_data, title, axisFlip, y_n.minor = 1) %>% 
      
      # adding data to plot
      points(x = usgs$sample_dt, y = usgs$result_va, 
             legend.name = "USGS",
             pch = 18, col = "black") %>% 
      points(x = observer$sample_dt, y = observer$result_va, 
             legend.name = "Observer",
             pch = 1, col = "black")
    
    # only include legend on the top plot
    if(length(grep("PHOSPHORUS", title)) > 0){ 
      parm_plot <- parm_plot %>%
        legend()
    }
    
  } else {
    totalP <- filter(parm_data, Timeseries == 'totalP')
    secchi <- filter(parm_data, Timeseries == 'secchi')
    chlorophyll <- filter(parm_data, Timeseries == 'chlorophyll')
    
    olig_pos <- median(c(min(parm_data$TSI), 40))
    eutr_pos <- median(c(50, max(parm_data$TSI)))
    
    parm_plot <- plotSetup(parm_data, title, axisFlip, y_n.minor = 4) %>% 

      # adding data to the plot
      lines(x = totalP$sample_dt, y = totalP$TSI, 
            lty = 2, legend.name = "Total Phosphorus") %>% 
      lines(x = chlorophyll$sample_dt, y = chlorophyll$TSI, 
            lty = 1, legend.name = "Chlorophyll a") %>%
      lines(x = secchi$sample_dt, y=secchi$TSI, 
            lty = 3, legend.name = "Secchi depth") %>%
      
      # defining trophic zones
      abline(h = c(40,50), lty = 5) %>% 
      text(x = min(parm_data$sample_dt), y = c(olig_pos, 45, eutr_pos), 
           cex = 0.8, pos = 4,
           labels = c("Oligotrophic", "Mesotrophic", "Eutrophic")) %>% 
      
      # adding the legend (no box around it)
      legend(bty = 'n')
    
  }
  return(parm_plot)
}

plotSetup <- function(parm_data, title, axisFlip, y_n.minor){
  # getting correct dates for labels/axis ticks
  unique_yrs <- unique(year(parm_data$sample_dt))
  startOfWy <- as.Date(paste0(unique_yrs, "-10-01"))
  startOfYear <- as.Date(paste0(unique_yrs, "-01-01"))
  endOfYear <- as.Date(paste0(unique_yrs, "-12-31"))
  
  parm_plot <- gsplot() %>% 
    # setting up plot limits
    points(NA, NA, 
           ylab = title, 
           xlim = c(startOfYear[1], 
                    tail(endOfYear, 1))) %>% 
    
    # formatting axes
    axis(side = 2, reverse = axisFlip, n.minor = y_n.minor) %>% 
    axis(side = 4, reverse = axisFlip, n.minor = y_n.minor, labels = FALSE) %>%  
    axis(side = 1, at = startOfYear, n.minor = 11,
         labels = FALSE) %>%
    mtext(side = 1, text = format(startOfWy, "%Y"), at = startOfWy, line = 1) %>% 
    axis(side = 3, at = startOfYear, n.minor = 11, 
         labels = FALSE)
  
  return(parm_plot)
}

