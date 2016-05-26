## Functions for making QW tables

makeWqTable <- function(qw_nwis){
    
  #filter nwis qw data and format for report
  qwtable <- qw_nwis %>% 
    select(sample_dt, sample_tm, result_va, parm_cd) %>%
    group_by(sample_dt) %>% 
    spread(key = parm_cd, value = result_va) %>% 
    filter(!is.na(`00078`) | !is.na(`32210`) | !is.na(`00665`)) %>% 
    select(-sample_tm)
  
  #reorder columns
  col_order <- c("sample_dt", "00078", "00098", "00010", "00095", 
                 "00400", "00300", "32210", "00665")
  # append rest of columns not explicitly defined in col_order
  col_order <- c(col_order, names(qwtable)[which(!names(qwtable) %in% col_order)])
  qwtable <- qwtable[, match(col_order, names(qwtable))]
  
  #rename columns based on parameter name, not code
  parm_info <- attr(qw_nwis, 'variableInfo')
  parm_cd <- parm_info$parameter_cd
  parm_nm <- parm_info$parameter_nm
  colnames_cds <- as.character(factor(names(qwtable)[-1], #exclude date column
                                      levels = parm_cd,
                                      labels = parm_nm))
  colnames(qwtable) <- c(names(qwtable)[1], colnames_cds) #include date column
  
  qwtable_list <- splitQwTable(qwtable)
  
  return(qwtable_list)
}

splitQwTable <- function(qwtable, ncol=13){
  qwtable_nodate <- qwtable[,which(names(qwtable) != "sample_dt")]
  
  ncol_nodate <- ncol(qwtable_nodate) #total num columns (excl date column)
  ntables <- ceiling(ncol_nodate/ncol) #number of different tables there should be
  nextracols <- ncol - (ncol_nodate - (ncol*(ntables-1)))
  table_levels <- head(gl(ntables, ncol), -nextracols)
  sep_qwtable_nodate <- tapply(as.list(qwtable_nodate), 
                               table_levels, as.data.frame) #creating list of tables
  
  sep_qwtable <- lapply(sep_qwtable_nodate, 
                        function(df, datecol){
                          df <- df %>% mutate(Date = datecol) %>% select(Date, everything())
                        }, datecol = qwtable$sample_dt)
  return(sep_qwtable)
}


