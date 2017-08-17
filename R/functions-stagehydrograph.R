## Functions for making stage hydrograph plots

makeStageHydrograph_dataRetrieval <- function(stage_data){
  if("X_OBSERVER_00065_00003" %in% colnames(stage_data)){
    stage_data_obs <- stage_data %>% 
      select(dateTime, X_OBSERVER_00065_00003) %>% 
      rename(gageHeight = X_OBSERVER_00065_00003) %>% 
      filter(!is.na(gageHeight)) 
  } else {
    stage_data_obs <- NULL
  }
  
  stage_data_cont <- stage_data %>% 
    select(dateTime, ends_with("_00065_00003"), 
           -starts_with("X_OBSERVER")) %>% 
    select(-starts_with('X_TAILWATER')) %>% 
    select(dateTime, gageHeight = ends_with("_00065_00003")) %>% 
    filter(!is.na(gageHeight)) 
  stage_data_all <- rbind(stage_data_obs, stage_data_cont)
  
  allDates <- seq(stage_data_all$dateTime[1], tail(stage_data_all$dateTime,1), by="years")
  allYears <- year(allDates)
  
  stageHydrograph <- gsplot(yaxs='r') %>% 
    points(stage_data_all$dateTime, stage_data_all$gageHeight, 
           pch=20, col="black") %>% 
    axis(side=1, at=allDates, labels=allYears) %>% 
    axis(side=3, at=allDates, labels=FALSE) %>%
    axis(side=2, n.minor=4) %>%
    title(ylab = "GAGE HEIGHT, IN FEET", line=2)
  
  return(stageHydrograph)
}

makeStageHydrograph_file <- function(stage_data, siteNumber, startDate){
  
  if(siteNumber == '04082500'){
    stage_data <- stage_data %>% 
      mutate(decimalDate = as.numeric(decimalDate)) %>% 
      mutate(dateTime = date_decimal(decimalDate)) %>%  
      mutate(dateTime = as.Date(dateTime))
  }
  #dplyr 0.5.0 filter not working
  # stage_data <- stage_data %>% filter(!is.na(dateTime))
  stage_data <- stage_data[which(!is.na(stage_data$dateTime)), ]
  stage_data <- stage_data %>%
    filter(dateTime>=as.POSIXct(startDate))
  startYear <- year(stage_data$dateTime[1])
  startDate <- as.POSIXct(paste0(startYear, "-01-01"))
  endYear <- year(tail(stage_data$dateTime,1)) +  1 # plus one to include Sept end of WY
  endDate <- as.POSIXct(paste0(endYear, "-12-31"))
  allYears <- seq(startYear, endYear)
  allDates <- seq(startDate, endDate, by="years")
  
  stageHydrograph <- gsplot(yaxs='r') %>% 
    points(stage_data$dateTime, stage_data$gageHeight, pch=20, col="black") %>% 
    axis(side=1, at=allDates, labels=allYears) %>% 
    axis(side=3, at=allDates, labels=FALSE) %>%
    axis(side=2, n.minor=4) %>%
    title(ylab = "GAGE HEIGHT, IN FEET", line=2)
  
  return(stageHydrograph)
}
