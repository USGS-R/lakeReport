## Functions for making gage height tables

makeGageHeightTable <- function(stage_data, wy_start){
  wy_months <- month.abb[c(10,11,12, 1:9)]
  
  gh_table <- stage_data %>% 
    filter(dateTime >= wy_start) %>% 
    select(dateTime, ends_with("_00065_00003"), 
           -starts_with("X_OBSERVER"), -starts_with('X_TAILWATER')) %>% 
    mutate(Month = factor(month(dateTime, label = TRUE, abbr = TRUE), 
                          levels = wy_months, ordered = TRUE)) 
  
  gh_table_months <- gh_table %>% 
    mutate(Day = format(dateTime, "%d")) %>%
    select(Day, Month, gageHeight = ends_with("_00065_00003")) %>%
    spread(Month, gageHeight)
  
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
