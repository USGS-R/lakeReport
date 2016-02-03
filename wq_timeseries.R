
## wq timeseries plots ##

# pcode = (00665 OR 00666) for total phosphorus (mg/L)
# pcode = 32210 for chlorophyll (ug/L)
# pcode = 00078 for secchi depth (meters)
# trophic state index ??

makeTimeseriesPlots <- function(qw_historic){
  totalP <- filterParmData(qw_historic, "00665") 
  chlorophyll <- filterParmData(qw_historic, "32210")
  secchi <- filterParmData(qw_historic, "00078")
  trophic <- data.frame()
  
  totalP_title <- "TOTAL PHOSPHORUS CONCENTRATION\nIN MILLIGRAMS PER LITER"
  chlorophyll_title <- "CHLOROPHYLL CONCENTRATION\nIN MICROGRAMS PER LITER"
  secchi_title <- "SECCHI DEPTH, IN METERS"
  trophic_title <- "TROPHIC STATE INDEX"
  
  plot_layout <- matrix(1:4, 4, 1)
  layout(plot_layout)
  print(makeTimeseriesPlot(totalP, totalP_title, 
                           isTrophicIndex = FALSE, axisFlip = FALSE))
  print(makeTimeseriesPlot(chlorophyll, chlorophyll_title, 
                           isTrophicIndex = FALSE, axisFlip = FALSE))
  print(makeTimeseriesPlot(secchi, secchi_title, 
                           isTrophicIndex = FALSE, axisFlip = TRUE))
  print(makeTimeseriesPlot(trophic, trophic_title, 
                           isTrophicIndex = TRUE, axisFlip = FALSE))
  
}

filterParmData <- function(data, pcode){
  data %>% 
    filter(parm_cd == pcode) %>% 
    select(sample_dt, result_va)
}

makeTimeseriesPlot <- function(parm_data, title, isTrophicIndex, axisFlip){
  if(!isTrophicIndex){
    parm_plot <- gsplot() %>% 
      points(x = parm_data$sample_dt, y = parm_data$result_va, 
             xlab = "", ylab = title, pch = 20) %>% 
      axis(side=2, reverse = axisFlip)
  } else {
    parm_plot <- gsplot() %>% 
      points(x = NA, y = NA, 
             xlab = "", ylab = title, pch = 20) %>% 
      axis(side=2, reverse = axisFlip)
  }
}

