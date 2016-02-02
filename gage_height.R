
### gage height table ###
makeGageHeightTable <- function(stage_data, wy_start){
  wy_months <- month.abb[c(10,11,12, 1:9)]
  
  gh_table <- stage_data %>% 
    filter(dateTime >= wy_start) %>% 
    select(dateTime, X_.CONTINUOUS._00065_00003) %>% 
    mutate(Month = factor(month(dateTime, label = TRUE, abbr = TRUE), 
                          levels = wy_months, ordered = TRUE)) 
  
  gh_table_months <- gh_table %>% 
    mutate(Day = format(dateTime, "%d")) %>%
    select(Day, Month, X_.CONTINUOUS._00065_00003) %>% 
    spread(Month, X_.CONTINUOUS._00065_00003)
  
  stats_mean <- gh_table_months %>% 
    summarize_each(funs = funs(mean(., na.rm = TRUE)), vars = -1) %>% 
    mutate(Day = "MEAN") %>% select(Day, everything())
  stats_max <- gh_table_months %>% 
    summarize_each(funs = funs(max(., na.rm = TRUE)), vars = -1) %>% 
    mutate(Day = "MAX") %>% select(Day, everything())
  stats_min <- gh_table_months %>% 
    summarize_each(funs = funs(min(., na.rm = TRUE)), vars = -1) %>% 
    mutate(Day = "MIN") %>% select(Day, everything())
  
  gh_table_final <- gh_table_months %>% 
    bind_rows(stats_mean, stats_max, stats_min)
  
  return(gh_table_final)
}

### stage hydrograph ###
makeStageHydrograph <- function(stage_data){
  gage_height_obs <- stage_data %>% 
    select(dateTime, X_OBSERVER_00065_00003) %>% 
    filter(!is.na(X_OBSERVER_00065_00003)) %>% 
    rename(gageHeight = X_OBSERVER_00065_00003)
  gage_height_cont <- stage_data %>% 
    select(dateTime, X_.CONTINUOUS._00065_00003) %>% 
    filter(!is.na(X_.CONTINUOUS._00065_00003)) %>% 
    rename(gageHeight = X_.CONTINUOUS._00065_00003)
  gage_height_all <- rbind(gage_height_obs, gage_height_cont)
    
  stageHydrograph <- gsplot() %>% 
    lines(gage_height_all$dateTime, gage_height_all$gageHeight) %>% 
    title(ylab = "GAGE HEIGHT, IN FEET")
  
  return(stageHydrograph)
}
