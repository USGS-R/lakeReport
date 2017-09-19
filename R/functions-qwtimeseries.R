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

makeTimeseriesPlot <- function(parm_data, y_axis_name, date_info, isTrophicIndex = FALSE, 
                               axisFlip = FALSE, ylim_buffer = NULL, addLegend = NULL, 
                               plot_main_title = NULL, plot_sub_title = NULL){
 
  if(nrow(parm_data) == 0){
    parm_plot <- 'No data available'
  } else {
  
    if(!isTrophicIndex){
      
      usgs_cen <- parm_data %>% filter(coll_ent_cd != "OBSERVER") %>% filter(!is.na(remark_cd))
      usgs_uncen <- parm_data %>% filter(coll_ent_cd != "OBSERVER") %>% filter(is.na(remark_cd))
      observer_cen <- parm_data %>% filter(coll_ent_cd == "OBSERVER") %>% filter(!is.na(remark_cd))
      observer_uncen <- parm_data %>% filter(coll_ent_cd == "OBSERVER") %>% filter(is.na(remark_cd))
      
      parm_plot <- plotSetup(parm_data, y_axis_name, axisFlip, y_n.minor = 1, date_info, ylim_buffer, 
                             plot_main_title, plot_sub_title) %>% 
        
        # adding data to plot
        points(x = usgs_cen$sample_dt, y = usgs_cen$result_va, pch = 18, col = "red", cex = 2, 
               legend.name = "USGS - Censored") %>% 
        points(x = usgs_uncen$sample_dt, y = usgs_uncen$result_va, pch = 18, col = "black", cex = 2,
               legend.name = "USGS - Uncensored") %>% 
        points(x = observer_cen$sample_dt, y = observer_cen$result_va, pch = 1, col = "red", cex = 2,
               legend.name = "Observer - Censored") %>%
        points(x = observer_uncen$sample_dt, y = observer_uncen$result_va, pch = 1, col = "black", cex = 2,
               legend.name = "Observer - Uncensored") 
      
    } else {
      totalP <- filter(parm_data, Timeseries == 'totalP')
      secchi <- filter(parm_data, Timeseries == 'secchi')
      chlorophyll <- filter(parm_data, Timeseries == 'chlorophyll')
      
      olig_pos <- median(c(min(parm_data$TSI), 40))
      eutr_pos <- median(c(50, max(parm_data$TSI)))
      
      parm_plot <- plotSetup(parm_data, y_axis_name, axisFlip, y_n.minor = 4, date_info, ylim_buffer, 
                             plot_main_title, plot_sub_title)
      
      parm_plot <- parm_plot %>% 
        
        # dummy point call for blank legend entry
        points(x = NA, y = NA, col = 'white', legend.name = "") %>%
  
        # adding data to the plot
        lines(x = totalP$sample_dt, y = totalP$TSI, 
              lty = 2, col = "red", legend.name = "Total Phosphorus") %>% 
        lines(x = chlorophyll$sample_dt, y = chlorophyll$TSI, 
              lty = 1, col = "forestgreen", legend.name = "Chlorophyll a") %>%
        lines(x = secchi$sample_dt, y=secchi$TSI, 
              lty = 3, col = "blue", legend.name = "Secchi depth") %>%
        
        # defining trophic zones
        rect(xleft = xlim(parm_plot, side = 1)[1], xright = xlim(parm_plot, side = 1)[2],
             ybottom = c(0, 40, 50), ytop = c(40, 50, 100),
             legend.name = c("Oligotrophic", "Mesotrophic", "Eutrophic"),
             col = c("lightskyblue", "tan1", "darkolivegreen3"), border = NA, where = "first")
        
      # adding the legend (no box around it)
      # merging this plot legend with a legend representing the first three time series
      if(!is.null(addLegend)){
        parm_plot$legend$legend.auto <- 
          mapply(c, addLegend$legend.auto, parm_plot$legend$legend.auto, SIMPLIFY = FALSE)
        parm_plot <- parm_plot %>% legend("below", bty = 'n', ncol=3, inset = -0.4)
      }
      
    }
  }
  return(parm_plot)
}

plotSetup <- function(parm_data, y_axis_name, axisFlip, y_n.minor, date_info, ylim_buffer, 
                      plot_main_title = NULL, plot_sub_title = NULL){
  
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
           xlim = c(date_info$firstDate, date_info$lastDate),
           ylim = c(ymin, ymax)) %>% 
    title(ylab=y_axis_name, line=3, main = plot_main_title) %>% 
    mtext(text = plot_sub_title, line = 0.5, cex = 0.7)%>%
    
    # formatting axes
    axis(side = 2, reverse = axisFlip, n.minor = y_n.minor) %>% 
    axis(side = 4, reverse = axisFlip, n.minor = y_n.minor, labels = FALSE) %>%  
    axis(side = 1, at = x_at, n.minor = x_n.minor, labels = year(x_at)) %>% 
    axis(side = 3, at = x_at, n.minor = x_n.minor, labels = FALSE)
  
  return(parm_plot)
}

