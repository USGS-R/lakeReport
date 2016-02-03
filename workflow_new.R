# 
# pcodes <- read.csv("pcodes.lakes1",header=FALSE,
#                    colClasses = "character")[,1]
# 
# sites <- read.csv("water_quality_lakes",header=FALSE,
#                   colClasses = "character")[,1]
# 
# sitesStage <- read.csv("stage_only_lakes",header=FALSE,
#                        colClasses = "character")[,1]
# 
# qwDataNWIS <- readNWISqw(sites, pcodes, "2013-10-01", "2014-09-30")
# qwDataWQP <- readWQPqw(paste0("USGS-",sites), pcodes, "2013-10-01", "2014-09-30")

#####################################################################################

## generating PDFs workflow

renderLakeReports <- function(reportName, siteNumber, wy, output){
  library(rmarkdown)
  
  output_dir <- getwd()
  filename <- paste(reportName, wy, siteNumber, sep="_")
  rmd_file <- paste0(reportName, '.Rmd') 
  
  out_file <- render(rmd_file, paste0(output,"_document"), 
                     output_file = paste(filename, output, sep="."),
                     output_dir = output_dir)
  return(out_file)
}

#example workflow:

##rendering as pdf
renderLakeReports('ghtable', '05390500', 2014, 'pdf')
renderLakeReports('stagehydrograph', '05390500', 2014, 'pdf')
renderLakeReports('qwtable', "455638089034501", 2014, 'pdf')
renderLakeReports('depthprofiles', "455638089034501", 2014, 'pdf')
renderLakeReports('qwtimeseries', "455638089034501", 2014, 'pdf')

## rendering as word docs (tables don't have nice formatting)
renderLakeReports('ghtable', '05390500', 2014, 'word')
renderLakeReports('stagehydrograph', '05390500', 2014, 'word')
renderLakeReports('qwtable', "455638089034501", 2014, 'word')
renderLakeReports('depthprofiles', "455638089034501", 2014, 'word')
renderLakeReports('qwtimeseries', "455638089034501", 2014, 'word')

#####################################################################################


