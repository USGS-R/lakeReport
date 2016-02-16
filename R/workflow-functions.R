# top-level functions 

makeReports <- function(siteNumber, wy, plotNames, output, ...){
  
  #if you want to run reports for all of the sites
  if(siteNumber == 'auto'){
    siteNumber_specified <- getSiteNumbers()
  } else {
    siteNumber_specified <- siteNumber
  }
  
  for(s in siteNumber_specified){
    
    #if you want to run all possible reports for each siteNumber
    if(plotNames == 'auto'){
      plotNames_specified <- getPlotNames(s)
    } else {
      plotNames_specified <- plotNames
    }
    
    for(p in plotNames_specified){
      #generate a report for the current plotName (p) and siteNumber (s)
      renderLakeReport(p, s, wy, output, ...)
    }
    
  }
  
}

renderLakeReport <- function(plotName, siteNumber, wy, output, ...){
  library(rmarkdown)
  
  output_dir <- file.path(getwd(), wy)
  filename <- paste(plotName, wy, siteNumber, sep="_")
  rmd_file <- paste0("Report_templates/", plotName, '.Rmd') 
  
  out_file <- render(rmd_file, paste0(output,"_document"), 
                     output_file = paste(filename, output, sep="."),
                     output_dir = output_dir, intermediates_dir = NULL)
  return(out_file)
}

getSiteNumbers <- function(){
  column_classes <- c(rep("character",2), rep("logical", 5))
  info <- read.csv("data/plotNames_by_site.csv", colClass=column_classes)  
  return(info$site_no)
}

getPlotNames <- function(siteNumber){
  library('dplyr')
  
  column_classes <- c(rep("character",2), rep("logical", 5))
  
  info <- read.csv("data/plotNames_by_site.csv", colClass=column_classes) %>% 
    filter(site_no == siteNumber) %>% 
    select(-c(site_name, site_no))

  isPlot <- sapply(info, c)
  plotNames <- names(which(isPlot))
  
  return(plotNames)

}

getAttr <- function(data, attr_nm){
  attributes(data)$siteInfo[[attr_nm]]
}

formatDate <- function(date){
  paste0(month(date, label=T, abbr=F), " ", 
         day(date), ", ",
         year(date))
}
