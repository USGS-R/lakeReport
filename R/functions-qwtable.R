## Functions for making QW tables

makeWqTable <- function(qw_nwis){
  
  qw_table <- qw_nwis %>% 
    select(sample_dt, sample_tm, result_va, parm_cd) %>%
    group_by(sample_dt) %>% 
    spread(key = parm_cd, value = result_va) 
  
  col_order <- c("sample_dt", "sample_tm", "00078", "00098", "00010", "00095", "00400", "00300", 
                 "32210", "00665", "00666", "00671", "00600", "00608", "00623", "00625", "00631")
  qw_table <- qw_table[, match(col_order, names(qw_table))]
  
  return(qw_table)
}
