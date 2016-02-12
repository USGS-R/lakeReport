## Functions for making QW Timeseries plots

# pcode = (00665 OR 00666) for total phosphorus (mg/L)
# pcode = 32210 for chlorophyll (ug/L)
# pcode = 00078 for secchi depth (meters)
# trophic state index ??

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
    
    parm_plot <- gsplot() %>% 
      points(x = usgs$sample_dt, y = usgs$result_va, 
             xlab = "", ylab = title, legend.name = "USGS",
             pch = 18, col = "black") %>% 
      points(x = observer$sample_dt, y = observer$result_va, 
             xlab = "", legend.name = "Observer",
             pch = 1, col = "black") %>%
      axis(side = 2, reverse = axisFlip)
    if(length(grep("PHOSPHORUS", title)) > 0){ 
      parm_plot <- parm_plot %>%
        legend()
    }
  } else {
    totalP <- filter(parm_data, Timeseries == 'totalP')
    secchi <- filter(parm_data, Timeseries == 'secchi')
    chlorophyll <- filter(parm_data, Timeseries == 'chlorophyll')
    
    olig_pos <- 40-(40-min(parm_data$TSI))/2
    eutr_pos <- 50+(max(parm_data$TSI)-50)/2
    
    parm_plot <- gsplot() %>% 
      lines(ylab = title,
            x = totalP$sample_dt, y = totalP$TSI, 
            lty = 2, legend.name = "Total Phosphorus") %>% 
      lines(x = chlorophyll$sample_dt, y = chlorophyll$TSI, 
            lty = 1, legend.name = "Chlorophyll a") %>%
      lines(x = secchi$sample_dt, y=secchi$TSI, 
            lty = 3, legend.name = "Secchi depth") %>%
      abline(h = c(40,50), lty = 5) %>% 
      text(x = min(parm_data$sample_dt), y = c(olig_pos, 45, eutr_pos), 
           cex = 0.8, pos = 4,
           labels = c("Oligotrophic", "Mesotrophic", "Eutrophic")) %>% 
      axis(side = 2, reverse = axisFlip) %>% 
      legend(bty = 'n')
  }
  return(parm_plot)
}

