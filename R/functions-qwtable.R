## Functions for making QW tables

makeWqTable <- function(qw_nwis){
    
  #filter nwis qw data and format for report
  qw_table <- qw_nwis %>% 
    select(sample_dt, sample_tm, result_va, parm_cd) %>%
    group_by(sample_dt) %>% 
    spread(key = parm_cd, value = result_va) %>% 
    filter(!is.na(`00078`) | !is.na(`32210`) | !is.na(`00665`)) %>% 
    select(-sample_tm)
  
  #reorder columns
  col_order <- c("sample_dt", "00078", "00098", "00010", "00095", 
                 "00400", "00300", "32210", "00665")
  # append rest of columns not explicitly defined in col_order
  col_order <- c(col_order, names(qw_table)[which(!names(qw_table) %in% col_order)])
  qw_table <- qw_table[, match(col_order, names(qw_table))]
  
  #rename columns based on parameter name, not code
  parm_info <- attr(qw_nwis, 'variableInfo')
  parm_cd <- parm_info$parameter_cd
  parm_nm <- parm_info$parameter_nm
  colnames_cds <- as.character(factor(names(qw_table)[-1], #exclude date column
                                      levels = parm_cd,
                                      labels = parm_nm))
  colnames(qw_table) <- c(names(qw_table)[1], colnames_cds) #include date column
  
  return(qw_table)
}
