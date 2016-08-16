## Functions for making gage height tables

makeGageHeightTable <- function(stage_data, wy_start){
  wy_months <- month.abb[c(10,11,12, 1:9)]
  
  ghtable_template <- data.frame(Day = sprintf("%02d", 1:31), stringsAsFactors = FALSE)
  ghtable_template[,2:13] <- as.numeric(NA)
  names(ghtable_template)[2:13] <- wy_months
  
  gh_table <- stage_data %>% 
    filter(dateTime >= wy_start) %>% 
    select(dateTime, ends_with("_00065_00003")) %>% 
    select(-starts_with("X_OBSERVER")) %>% 
    select(-starts_with('X_TAILWATER')) %>% 
    mutate(Month = factor(month(dateTime, label = TRUE, abbr = TRUE), 
                          levels = wy_months, ordered = TRUE)) 
  
  gh_table_months <- gh_table %>% 
    mutate(Day = format(dateTime, "%d")) %>%
    select(Day, Month, gageHeight = ends_with("_00065_00003")) %>%
    spread(Month, gageHeight)
  
  col_match <- which(names(ghtable_template) %in% 
                       intersect(names(ghtable_template), names(gh_table_months)))
  row_match <- which(ghtable_template$Day %in% 
                       intersect(ghtable_template$Day, gh_table_months$Day))
  ghtable_template[row_match, col_match] <- gh_table_months 
  gh_table_display <- ghtable_template
  
  stats_mean <- gh_table_display %>% 
    summarize_each(funs = funs(mean(., na.rm = TRUE)), vars = -1) %>% 
    mutate(Day = "MEAN") %>% select(Day, everything())
  stats_max <- gh_table_display %>% 
    summarize_each(funs = funs(max(., na.rm = TRUE)), vars = -1) %>% 
    mutate(Day = "MAX") %>% select(Day, everything())
  stats_min <- gh_table_display %>% 
    summarize_each(funs = funs(min(., na.rm = TRUE)), vars = -1) %>% 
    mutate(Day = "MIN") %>% select(Day, everything())
  
  gh_table_final <- gh_table_display %>% 
    bind_rows(stats_mean, stats_max, stats_min)
  
  return(gh_table_final)
}
