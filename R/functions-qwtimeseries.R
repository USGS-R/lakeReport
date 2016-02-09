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
      axis(side=2, reverse = axisFlip)
    if(length(grep("PHOSPHORUS", title)) > 0){ 
      parm_plot <- parm_plot %>%
        legend()
    }
  } else {
    parm_plot <- gsplot() %>% 
      points(x = NA, y = NA, 
             xlab = "", ylab = title, pch = 20) %>% 
      axis(side=2, reverse = axisFlip)
  }
  return(parm_plot)
}
