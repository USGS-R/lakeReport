
##### Example workflows (after sourcing makeReports and renderLakeReport functions) ##### 

# this doesn't work with the new gsplot v0.7 yet. Run this line to make sure you have v0.5.5
devtools::install_github('USGS-R/gsplot', ref='v0.5.5')

# Render multiple reports at one time for the same site:
wy <- 2015

siteNumber <- '05390500'
plotNames <- c('ghtable', 'stagehydrograph')
makeReports(siteNumber, wy, plotNames, 'pdf')

siteNumber <- '423556088365001'
plotNames <- c('qwtable', 'depthprofiles', 'qwtimeseries')
makeReports(siteNumber, wy, plotNames, 'pdf')

# Rendering as word docs (tables don't have nice formatting)
# Same as above, but output is word documents
wy <- 2014

siteNumber <- '05390500'
plotNames <- c('ghtable', 'stagehydrograph')
makeReports(siteNumber, wy, plotNames, 'word')

siteNumber <- '423556088365001'
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


### Rendering for multiple sites and plot types at a time

wy <- 2014
siteNumber <- c('05390500', '05404500')
plotNames <- c('ghtable', 'stagehydrograph')
makeReports(siteNumber, wy, plotNames, 'word')


### Using the 'auto' feature for siteNumber and plotNames
### Two possibilities:

# 1. Generate all possible plot types for specified sites 
wy <- 2014
siteNumber <- c('05390500', '424840088241600')
plotNames <- 'auto'
makeReports(siteNumber, wy, plotNames, 'word')

# 2. Generate all possible plot types for all possible sites 
wy <- 2014
siteNumber <- 'auto'
plotNames <- 'auto'
makeReports(siteNumber, wy, plotNames, 'word')
