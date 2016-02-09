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

##### Example workflows (after running code for makeReports and renderLakeReport functions) ##### 

# Run multiple reports at one time for the same site:
wy <- 2014
siteNumber <- '05390500'
reportNames <- c('ghtable', 'stagehydrograph')
makeReports(siteNumber, wy, reportNames, 'pdf')

siteNumber <- '455638089034501'
reportNames <- c('qwtable', 'depthprofiles', 'qwtimeseries')
makeReports(siteNumber, wy, reportNames, 'pdf')

# Or run reports individually:

## Rendering as pdf
## the following 5 lines give the same results as the example of 
## running multiple reports at once above
renderLakeReport('ghtable', '05390500', 2014, 'pdf')
renderLakeReport('stagehydrograph', '05390500', 2014, 'pdf')
renderLakeReport('qwtable', "455638089034501", 2014, 'pdf')
renderLakeReport('depthprofiles', "455638089034501", 2014, 'pdf')
renderLakeReport('qwtimeseries', "455638089034501", 2014, 'pdf')

## rendering as word docs (tables don't have nice formatting)
renderLakeReport('ghtable', '05390500', 2014, 'word')
renderLakeReport('stagehydrograph', '05390500', 2014, 'word')
renderLakeReport('qwtable', "455638089034501", 2014, 'word')
renderLakeReport('depthprofiles', "455638089034501", 2014, 'word')
renderLakeReport('qwtimeseries', "455638089034501", 2014, 'word')

#different site test for ghtable and stagehydrograph
siteNumber <- "430251088284700"
wy <- 2014
renderLakeReport('ghtable', siteNumber, wy, 'pdf')
renderLakeReport('stagehydrograph', siteNumber, wy, 'pdf')

#different site test for qw only
siteNumber <- "424915088083900"
wy <- 2014
renderLakeReport('qwtable', siteNumber, wy, 'pdf')
renderLakeReport('depthprofiles', siteNumber, wy, 'pdf')
renderLakeReport('qwtimeseries', siteNumber, wy, 'pdf')

# Different site test for qw only:
siteNumber <- "423246088175800"
wy <- 2014
renderLakeReport('qwtable', siteNumber, wy, 'pdf')
renderLakeReport('depthprofiles', siteNumber, wy, 'pdf')
renderLakeReport('qwtimeseries', siteNumber, wy, 'pdf')

#####################################################################################


