# top-level functions 

makeReports <- function(siteNumber, wy, plotNames, output, ...){
  
  #if you want to run reports for all of the sites
  if(all(siteNumber == 'auto')){
    siteNumber_specified <- getSiteNumbers()
  } else {
    siteNumber_specified <- siteNumber
  }
  
  successful_count <- 0
  failed_reports <- data.frame(siteNumber = c(), plotName = c())
  
  for(s in siteNumber_specified){
    
    #if you want to run all possible reports for each siteNumber
    if(all(plotNames == 'auto')){
      plotNames_specified <- getPlotNames(s)
    } else {
      plotNames_specified <- plotNames
    }
    
    for(p in plotNames_specified){
      #generate a report for the current plotName (p) and siteNumber (s)
      status_report <- tryCatch(renderLakeReport(p, s, wy, output, ...), 
                                error = function(e){
                                  err_msg <- gsub("\n", "", e)
                                  return(err_msg)
                                })
      if(grepl("Error", status_report)){
        failed_reports <- rbind(failed_reports, 
                                data.frame(siteNumber = s, plotName = p, error = status_report))
      } else {
        successful_count <- successful_count + 1
      }
    }
    
  }
  
  message(paste("\n\n", successful_count, "reports successful"))
  message("\nFAILED REPORTS:")
  print(failed_reports)
}

renderLakeReport <- function(plotName, siteNumber, wy, output, ...){
  library(rmarkdown)
  
  if(plotName == 'stagehydrograph'){
    gageheight_filepath <- getGageHeightFilePath(siteNumber)
  }
  
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

convertWYtoDate <- function(wy){
  s <- as.POSIXct(paste0(wy-1, "-10-01"), tz = "UTC")
  e <- as.POSIXct(paste0(wy, "-09-30"), tz = "UTC")
  return(list(wy_start = s, wy_end = e))
}

getGageHeightFilePath <- function(siteNumber){
  library(dplyr)
  siteDetails <- read.csv("data/plotNames_by_site.csv",
                          colClasses = c("character", "character",
                                         rep("logical", 5), "character"),
                          stringsAsFactors = FALSE)
  siteDetails_site <- filter(siteDetails, site_no == siteNumber)
  siteFilePath <- siteDetails_site$gageHeight_files
  return(siteFilePath)
}
