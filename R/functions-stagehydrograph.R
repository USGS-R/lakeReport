## Functions for making stage hydrograph plots

makeStageHydrograph <- function(stage_data){
  if("X_OBSERVER_00065_00003" %in% colnames(stage_data)){
    gage_height_obs <- stage_data %>% 
      select(dateTime, X_OBSERVER_00065_00003) %>% 
      rename(gageHeight = X_OBSERVER_00065_00003) %>% 
      filter(!is.na(gageHeight)) 
  } else {
    gage_height_obs <- NULL
  }
  
  gage_height_cont <- stage_data %>% 
    select(dateTime, ends_with("_00065_00003"), -starts_with("X_OBSERVER")) %>% 
    select(dateTime, gageHeight = ends_with("_00065_00003")) %>% 
    filter(!is.na(gageHeight)) 
  gage_height_all <- rbind(gage_height_obs, gage_height_cont)
  
  allYears <- seq(year(gage_height_all$dateTime[1]), year(tail(gage_height_all$dateTime,1)))
  allDates <- seq(gage_height_all$dateTime[1], tail(gage_height_all$dateTime,1), by="years")
  
  stageHydrograph <- gsplot() %>% 
    lines(gage_height_all$dateTime, gage_height_all$gageHeight) %>% 
    axis(side=1, at=allDates, labels=allYears) %>% 
    axis(side=3, at=allDates, labels=FALSE) %>%
    axis(side=2, n.minor=4) %>%
    title(ylab = "GAGE HEIGHT, IN FEET")
  
  return(stageHydrograph)
}
