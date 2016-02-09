# top-level functions 

makeReports <- function(siteNumber, wy, reportNames, output){
  for(rn in reportNames){
    renderLakeReport(rn, siteNumber, wy, output)
  }
}

renderLakeReport <- function(reportName, siteNumber, wy, output){
  library(rmarkdown)
  
  output_dir <- getwd()
  filename <- paste(reportName, wy, siteNumber, sep="_")
  rmd_file <- paste0(reportName, '.Rmd') 
  
  out_file <- render(rmd_file, paste0(output,"_document"), 
                     output_file = paste(filename, output, sep="."),
                     output_dir = output_dir)
  return(out_file)
}
