
##### Example workflows (after sourcing makeReports and renderLakeReport functions) ##### 

# Render multiple reports at one time for the same site:
wy <- 2014

siteNumber <- '05390500'
plotNames <- c('ghtable', 'stagehydrograph')
makeReports(siteNumber, wy, plotNames, 'pdf')

siteNumber <- '455638089034501'
plotNames <- c('qwtable', 'depthprofiles', 'qwtimeseries')
makeReports(siteNumber, wy, plotNames, 'pdf')

# Rendering as word docs (tables don't have nice formatting)
# Same as above, but output is word documents
wy <- 2014

siteNumber <- '05390500'
plotNames <- c('ghtable', 'stagehydrograph')
makeReports(siteNumber, wy, plotNames, 'word')

siteNumber <- '455638089034501'
plotNames <- c('qwtable', 'depthprofiles', 'qwtimeseries')
makeReports(siteNumber, wy, plotNames, 'word')

# If stagehydrograph data is coming from a file and not 
# dataRetrieval, you will need to add extra arguments
# 
# filePath = '[FILEPATH W/ FILENAME & FILE EXTENSION]'
# dateTime = '[COLUMN NAME FOR THE DATE/DATE TIME]'
# gageHeight = '[COLUMN NAME FOR THE STAGE DATA]'

wy <- 2014
siteNumber <- '05390500'
plotNames <- 'stagehydrograph'
makeReports(siteNumber, wy, plotNames, 'pdf', 
            filePath = 'myfilepath',
            dateTime = 'sample_dt',
            gageHeight = 'result_va')
