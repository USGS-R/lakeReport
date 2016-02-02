
## wq_table ##
makeWqTable <- function(qw_nwis){
  
  qw_table <- qw_nwis %>% 
    select(sample_dt, sample_tm, result_va, parm_cd) %>%
    group_by(sample_dt) %>% 
    spread(key = parm_cd, value = result_va) 
  
  col_order <- c("sample_dt", "sample_tm", "00078", "00098", "00010", "00095", "00400", "00300", 
                 "32210", "00665", "00666", "00671", "00600", "00608", "00623", "00625", "00631")
  qw_table <- qw_table[, match(col_order, names(qw_table))]
  
  return(qw_table_final)
}

## wq depth profiles ##

# pcode = 00098 for sampling depth (meters)
# pcode = 00300 for dissolved oxygen (mg/L)
# pcode = 00010 for water temperature (deg C)
# pcode = 00400 for pH
# pcode = 00095 for specific conductance (uS/cm at 25 deg C)

makeLakeDepthProfiles <- function(qw_nwis){
  
  # titles of each graph
  DO_title <- "DISSOLVED OXYGEN (D.O.) IN MILLIGRAMS PER LITER"
  h2otemp_title <- "WATER TEMPERATURE (W.T.) IN DEGREES CELCIUS"
  PH_title <- "PH IN STANDARD UNITS"
  specifcond_title <- "SPECIFIC CONDUCTANCE (S.C.) IN MICROSIEMENS PER CENTIMETER AT 25 DEGREES CELCIUS"
  
  # seperating data
  unique_depth_samples <- qw_nwis %>% 
    filter(parm_cd == "00098") %>% 
    group_by(sample_dt) %>% 
    count(sample_dt) %>% 
    filter(n > 1)
  
  depth <- qw_nwis %>% 
    filter(parm_cd == "00098") %>%
    filter(sample_dt %in% unique_depth_samples$sample_dt) %>% 
    select(sample_dt, sample_tm, result_va) %>% 
    rename(depth = result_va)
  
  DO <- getQWData(qw_nwis, depth, "00300")
  h2otemp <- getQWData(qw_nwis, depth, "00010")
  PH <- getQWData(qw_nwis, depth, "00400")
  specifcond <- getQWData(qw_nwis, depth, "00095")
  
  # figuring out the number of plots that will be needed
  dates_uniq <- unique_depth_samples$sample_dt
  num_2x4_plots <- floor(length(dates_uniq)/4)
  num_extra_dates <- length(dates_uniq)%%4
  
  #2x4 plots
  d <- 1
  plotList <- list()
  for(p in seq(num_2x4_plots)){
    dts <- dates_uniq[d:(p*4)]
    plot_setup <- matrix(1:8, 2, 4)
    
    layout(plot_setup)
    for(t in seq_along(dts)){
      left_logic <- t == 1
      print(depthProfilePlot(h2otemp, DO, dts[t], top=TRUE,
                              DO_title, h2otemp_title, left_logic))
      print(depthProfilePlot(specifcond, PH, dts[t], top=FALSE, 
                              PH_title, specifcond_title, left_logic))
    }
    
    d <- (p*4)+1
  }
  
  #extras 
  dts <- tail(dates_uniq, num_extra_dates)
  plot_setup <- matrix(1:(2*num_extra_dates), 2, num_extra_dates)
  
  layout(plot_setup)
  for(t in seq_along(dts)){
    left_logic <- t == 1
    print(depthProfilePlot(h2otemp, DO, dts[t], top=TRUE,
                            DO_title, h2otemp_title, left_logic))
    print(depthProfilePlot(specifcond, PH, dts[t], top=FALSE,
                            PH_title, specifcond_title, left_logic))
  }
  
  ## still working on lake-depth profiles
  ##left off -- need to eliminate no data graphs
  ##tick marks and formatting for graphs
  ##have same scale on matching axes (all side3 from 0-20, all side1 from 0-30) 
  ##y limits are not being used correctly on graph (only goes to 8, but should go to 10)
  
}

getQWData <- function(data, depth, pcode){
  pcode_data <- data %>% 
    filter(parm_cd == pcode) %>% 
    select(sample_dt, sample_tm, result_va)

  plot_data <- left_join(depth, pcode_data)
  return(plot_data)
}

filterByDate <- function(df, filter_date){
  df <- df %>% filter(sample_dt == filter_date) %>% 
    arrange(depth)
  return(list(x=df[['result_va']], y=df[['depth']]))
}

depthProfilePlot <- function(side1, side3, filter_date, top,
                              title_above, title_below, left){
  side1_list <- filterByDate(side1, filter_date)
  side3_list <- filterByDate(side3, filter_date)
  
  title_main <- ifelse(top, as.character(filter_date), "")
  ylab_left <- ifelse(left, "DEPTH, IN METERS", "")
  
  smartTicks <- function(vals, yaxis, top){
    low_lim <- min(floor(vals/5)*5)
    up_lim <- max(ceiling(vals/5)*5)
    minor_x <- ifelse(top, 4, 0)
    by_step <- ifelse(yaxis, 2, 5)
    at_vals <- seq(low_lim, up_lim, by=by_step)
    return(list(nminor=minor_x, at_vals=at_vals))
  }
  
  all_y <- c(side1_list$y, side3_list$y)
  yticks <- smartTicks(all_y, yaxis=TRUE, top)
  xticks_1 <- smartTicks(side1_list$x, yaxis=FALSE, top)
  xticks_3 <- smartTicks(side3_list$x, yaxis=FALSE, top)
  
  gs <- gsplot() %>% 
    lines(side1_list$x, side1_list$y, lty=3) %>% 
    lines(side3_list$x, side3_list$y, side=3) %>% 
    axis(side=2, reverse=TRUE, n.minor=1, at=yticks$at_vals) %>% 
    axis(side=4, reverse=TRUE, labels=FALSE, n.minor=1, at=yticks$at_vals) %>% 
    axis(side=1, at=xticks_1$at_vals, n.minor=xticks_1$nminor) %>% 
    axis(side=3, at=xticks_3$at_vals, n.minor=xticks_3$nminor) %>% 
    title(main = title_main, ylab = ylab_left)
  
  return(gs)
}


