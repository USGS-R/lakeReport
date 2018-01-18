## Functions for making lake depth profiles

# pcode = 00098 for sampling depth (meters)
# pcode = 00300 for dissolved oxygen (mg/L)
# pcode = 00010 for water temperature (deg C)
# pcode = 00400 for pH
# pcode = 00095 for specific conductance (uS/cm at 25 deg C)

filterLakeDepthProfileData <- function(qw_nwis){
  
  # more than one depth measurement was taken on a particular day
  unique_depth_samples <- qw_nwis %>% 
    filter(parm_cd == "00098") %>% 
    group_by(sample_dt) %>% 
    count(sample_dt) %>% 
    filter(n > 1) 
  
  # filter based on criteria from above
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
  
  return(list(DO = DO, h2otemp = h2otemp, 
              PH = PH, specifcond = specifcond, 
              dates_uniq = dates_uniq))
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

depthProfilePlot <- function(gs, side1, side3, filter_date, 
                             top, left, xranges){
  # find range for all data
  all_y <- c(side1[['depth']], side3[['depth']])
  
  # grab data only from current date
  side1_list <- filterByDate(side1, filter_date)
  side3_list <- filterByDate(side3, filter_date)
  
  # figure out yaxis major and minor ticks
  if(max(all_y) <= 10){
    yseq <- 2
    yn.minor <- 1
  } else if(max(all_y) > 10 & max(all_y) <= 35){
    yseq <- 4
    yn.minor <- 3
  } else if(max(all_y) > 35 & max(all_y) <= 50){
    yseq <- 5
    yn.minor <- 0
  } else if(max(all_y) > 50){
    yseq <- 10
    yn.minor <- 1
  }
  #round the highest value up to the nearest multiple of yseq
  ceiling_mult_yseq <- max(all_y)+(yseq-max(all_y)%%yseq) 
  yvals <- seq(from=0, to=ceiling_mult_yseq, by=yseq)
  
  # create tick mark sequences 
  # WT, DO, and pH are set based on file
  # SC are dynamic based on values
  if(top){
    side1 <- seq(from=xranges$wt_low, to=xranges$wt_high, by=10)
    side3 <- seq(from=xranges$do_low, to=xranges$do_high, by=10)
    xn.minor <- 4
    plottext <- c("W.T.", "D.O.") # legend label
    mainTitle <- filter_date
  } else{
    sc_sequence_categ <- cut(xranges$sc_high - xranges$sc_low,
                             breaks=c(0, 50, 200, 500, 900, Inf),
                             labels = c(5, 50, 100, 200, 500))
    sc_sequence <- as.numeric(levels(sc_sequence_categ))[sc_sequence_categ]
    
    side1 <- seq(from=xranges$sc_low, to=xranges$sc_high, by=sc_sequence)
    side3 <- seq(from=xranges$ph_low, to=xranges$ph_high, by=1)
    xn.minor <- 0
    plottext <- c("S.C.", "pH") # legend label
    mainTitle <- ""
  }
  
  depthplot <- gs %>% 
    # water temp or specific conductance
    lines(side1_list$x, side1_list$y, lty=3, lwd=1.5, 
          ylim=c(0, ceiling_mult_yseq),
          xlim=c(side1[1], tail(side1,1)),
          legend.name=plottext[1]) %>% 
    
    # dissolved oxygen or pH
    lines(side3_list$x, side3_list$y, side=3, 
          ylim=c(0, ceiling_mult_yseq),
          xlim=c(side3[1], tail(side3,1)),
          legend.name=plottext[2]) %>% 
    
    # formatting y axes
    axis(side=2, reverse=TRUE, n.minor=yn.minor, at=yvals) %>% 
    axis(side=4, reverse=TRUE, labels=FALSE, n.minor=yn.minor, at=yvals) %>% 
    
    # formatting x axes
    axis(side=1, at=side1, n.minor=xn.minor) %>% 
    axis(side=3, at=side3, n.minor=xn.minor) %>% 
    
    # add dates title only to top plots
    title(main = mainTitle, line = 3.5)
  
  # add legend to only plots on far left
  if(left){
    depthplot <- depthplot %>% 
      legend(location="bottomright", bty='n', cex=0.8, font=2)
  }
  
  return(depthplot)
}
