## Functions for making QW Timeseries plots

# pcode = (00665 OR 00666) for total phosphorus (mg/L)
# pcode = 32210 for chlorophyll (ug/L)
# pcode = 00078 for secchi depth (meters)

filterParmData <- function(data, pcode, depth_df = NULL, isTotalP = FALSE){
  parm_data <- data %>% 
    filter(parm_cd %in% pcode) %>% 
    select(sample_dt, sample_tm, result_va, remark_cd, coll_ent_cd) %>% 
    mutate(result_va = as.numeric(result_va))
  
  if(!is.null(depth_df)){
    depth_df <- depth_df %>% 
      rename(sample_depth = result_va) %>% 
      select(-coll_ent_cd, -remark_cd)
    parm_data <- left_join(parm_data, depth_df, by = c('sample_dt', 'sample_tm')) %>% 
      select(-sample_tm)
  }
  
  if(isTotalP){
    parm_data <- parm_data %>% 
      group_by(sample_dt) %>% 
      filter(sample_depth == min(sample_depth)) %>% 
      ungroup()
  }
  
  return(parm_data)
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

makeTimeseriesPlot <- function(parm_data, title, date_info, isGreenLake, isSecchi = FALSE,
                               isTrophicIndex = FALSE, axisFlip = FALSE, ylim_buffer = NULL){
 
  if(nrow(parm_data) == 0){
    parm_plot <- 'No data available'
  } else {
  
    if(!isTrophicIndex){
      
      col_censored <- "red"
      col_uncensored <- "black"
      pch_usgs <- 18
      pch_observer <- 1
      
      parm_data <- parm_data %>% 
        mutate(symbolColor = ifelse(is.na(remark_cd), col_uncensored, col_censored))
      
      if(isGreenLake && isSecchi){
        usgs <- parm_data %>% filter(sample_depth != 0.1)
        observer <- parm_data %>% filter(sample_depth == 0.1) 
      } else {
        usgs <- parm_data %>% filter(coll_ent_cd != "OBSERVER") 
        observer <- parm_data %>% filter(coll_ent_cd == "OBSERVER") 
      }
      
      parm_plot <- plotSetup(parm_data, title, axisFlip, y_n.minor = 1, date_info, ylim_buffer) %>% 
        
        # adding data to plot
        points(x = usgs$sample_dt, y = usgs$result_va, 
               pch = pch_usgs, col = usgs$symbolColor) %>% 
        points(x = observer$sample_dt, y = observer$result_va, 
               pch = pch_observer, col = observer$symbolColor) 
      
      # only include legend on the top plot
      if(length(grep("PHOSPHORUS", title)) > 0){ 
        parm_plot <- parm_plot %>%
          legend(pch = c(pch_usgs,pch_usgs,pch_observer,pch_observer), 
                 col = rep(c(col_uncensored, col_censored),2), 
                 legend = c("USGS - Uncensored", "USGS - Censored", 
                            "Observer - Uncensored", "Observer - Censored"))
      }
      
    } else {
      totalP <- filter(parm_data, Timeseries == 'totalP')
      secchi <- filter(parm_data, Timeseries == 'secchi')
      chlorophyll <- filter(parm_data, Timeseries == 'chlorophyll')
      
      olig_pos <- median(c(min(parm_data$TSI), 40))
      eutr_pos <- median(c(50, max(parm_data$TSI)))
      
      parm_plot <- plotSetup(parm_data, title, axisFlip, y_n.minor = 4, date_info, ylim_buffer) %>% 
  
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
  }
  return(parm_plot)
}

plotSetup <- function(parm_data, title, axisFlip, y_n.minor, date_info, ylim_buffer){
  
  # x axis format depends on total length of time for the plot
  timeperiod <- year(date_info$lastDate) - year(date_info$firstDate)
  if(timeperiod <= 10){
    x_at <- date_info$yrs
    x_n.minor <- 11
  } else if(timeperiod <= 20){
    x_at <- date_info$yrs
    x_n.minor <- 0
  } else if(timeperiod > 20){
    x_at <- seq(date_info$firstDate, date_info$lastDate, by="5 years")
    x_n.minor <- 0
  }

  #ylim_buffer is NULL for trophic index plot
  if(is.null(ylim_buffer)){
    ymin <- min(parm_data$TSI)
    ymax <- max(parm_data$TSI)
    ymin_buffer <- ymin%%10
    ymax_buffer <- ifelse(ymax%%10 == 0, 0, 10 - ymax%%10)
    # applying buffer
    ymin <- ymin - ymin_buffer
    ymin <- ifelse(ymin < 0, 0, ymin)
    ymax <- ymax + ymax_buffer
  } else {
    ymin <- 0
    ymax <- max(parm_data$result_va)
    ymax_buffer <- ylim_buffer
    
    ymax <- ymax + ymax_buffer*ymax
    ymax <- tail(pretty(c(ymin, ymax)), 1)
  }
  
  parm_plot <- gsplot() %>% 
    # setting up plot limits
    points(NA, NA, 
           ylab = title, 
           xlim = c(date_info$firstDate, date_info$lastDate),
           ylim = c(ymin, ymax)) %>% 
    
    # formatting axes
    axis(side = 2, reverse = axisFlip, n.minor = y_n.minor) %>% 
    axis(side = 4, reverse = axisFlip, n.minor = y_n.minor, labels = FALSE) %>%  
    axis(side = 1, at = x_at, n.minor = x_n.minor, labels = year(x_at)) %>% 
    axis(side = 3, at = x_at, n.minor = x_n.minor, labels = FALSE)
  
  return(parm_plot)
}

