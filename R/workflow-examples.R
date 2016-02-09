
##### Example workflows (after sourcing makeReports and renderLakeReport functions) ##### 

# Render multiple reports at one time for the same site:
wy <- 2014

siteNumber <- '05390500'
reportNames <- c('ghtable', 'stagehydrograph')
makeReports(siteNumber, wy, reportNames, 'pdf')

siteNumber <- '455638089034501'
reportNames <- c('qwtable', 'depthprofiles', 'qwtimeseries')
makeReports(siteNumber, wy, reportNames, 'pdf')

# Rendering as word docs (tables don't have nice formatting)
# Same as above, but output is word documents
wy <- 2014

siteNumber <- '05390500'
reportNames <- c('ghtable', 'stagehydrograph')
makeReports(siteNumber, wy, reportNames, 'word')

siteNumber <- '455638089034501'
reportNames <- c('qwtable', 'depthprofiles', 'qwtimeseries')
makeReports(siteNumber, wy, reportNames, 'word')
