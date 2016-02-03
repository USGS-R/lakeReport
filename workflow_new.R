library(dplyr)
library(dataRetrieval)
library(tidyr)
library(gsplot)

pcodes <- read.csv("pcodes.lakes1",header=FALSE,
                   colClasses = "character")[,1]

sites <- read.csv("water_quality_lakes",header=FALSE,
                  colClasses = "character")[,1]

sitesStage <- read.csv("stage_only_lakes",header=FALSE,
                       colClasses = "character")[,1]

qwDataNWIS <- readNWISqw(sites, pcodes, "2013-10-01", "2014-09-30")
qwDataWQP <- readWQPqw(paste0("USGS-",sites), pcodes, "2013-10-01", "2014-09-30")



### gh table & stage hydrograph, p.24 ###

library(dataRetrieval)
library(lubridate)
library(dplyr)
library(tidyr)
library(gsplot)

wy_start <- as.POSIXct("2013-10-01")
wy_end <- as.POSIXct("2014-09-30")

stage_data <- readNWISdata(service = "dv", sites = "05390500", 
                           parameterCd = "00065", startDate = "1800-01-01", 
                           endDate = wy_end)

ghtable <- makeGageHeightTable(stage_data, wy_start) 
stagehydro <- makeStageHydrograph(stage_data)

### ###

### qw data table & lake profiles, p.25-29 ###
library(dataRetrieval)
library(dplyr)
library(gsplot)

wy_start <- as.POSIXct("2013-10-01")
wy_end <- as.POSIXct("2014-09-30")

pcodes <- read.csv("pcodes.lakes1",header=FALSE,
                   colClasses = "character")[,1]

qw_nwis <- readNWISqw(siteNumbers = "455638089034501", 
                      parameterCd = pcodes, 
                      startDate = wy_start, 
                      endDat = wy_end)

qw_table <- makeWqTable(qw_nwis)
qw_depth_profiles <- makeLakeDepthProfiles(qw_nwis)

### ###

### qw timeseries, p. 30 ###
library(dataRetrieval)
library(gsplot)

wy_end <- as.POSIXct("2014-09-30")

pcodes <- c("00665", "00666", "32210", "00078")

qw_historic <- readNWISqw(siteNumbers = "455638089034501", 
                          parameterCd = pcodes,
                          startDate = "1800-01-01", 
                          endDat = wy_end)

qw_timeseries <- makeTimeseriesPlots(qw_historic)

### ###
