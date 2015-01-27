library(dataRetrieval)
library(smwrGraphs)

pcodes <- read.csv("pcodes.lakes1",header=FALSE,
                   colClasses = "character")[,1]

sites <- read.csv("water_quality_lakes",header=FALSE,
                  colClasses = "character")[,1]

sitesStage <- read.csv("stage_only_lakes",header=FALSE,
                       colClasses = "character")[,1]

dataAvail <- whatNWISdata(sites) #Water Quality
stageSitesInfo <- readNWISsite(sitesStage)
stageSitesInfo$type <- rep("Lake-stage station",nrow(stageSitesInfo))
qwSitesInfo <- readNWISsite(sites)
qwSitesInfo$type <- rep("Lake water-quality and stage station",nrow(qwSitesInfo))

siteTable <- rbind(qwSitesInfo,stageSitesInfo)
siteTable$offsetLat <- rep(0,nrow(siteTable))
siteTable$offsetLon <- rep(0,nrow(siteTable))
siteTable$offsetLineLat <- rep(0,nrow(siteTable))
siteTable$offsetLineLon <- rep(0,nrow(siteTable))

stageData <- readNWISdv(sitesStage, "00065", "2013-10-01", "2014-09-30")
qwDataNWIS <- readNWISqw(sites, pcodes, "2013-10-01", "2014-09-30")
qwDataWQP <- readWQPqw(paste0("USGS-",sites), pcodes, "2013-10-01", "2014-09-30")

library(USGSHydroTools)
#Map boundaries:
xmin <- -93
xmax <- -86.6
ymin <- 42
ymax <- 47.1
#Legend placement:
xleft <- -92.8
ytop <- 42.8

#There will be some futzing to get the labels right, probably easiest to do in excel:
write.csv(siteTable, file="siteTable.csv", row.names=FALSE)
siteTable <- read.csv("siteTable.csv", stringsAsFactors=FALSE)

MapSizeColor(siteTable, colorVar="type",sizeVar=NA,
             latVar = "dec_lat_va", lonVar = "dec_long_va",
             xmin=xmin, xmax=xmax,
             ymin=ymin, ymax=ymax,
             xleft=xleft,ytop=ytop,
             colVector=c("red","blue"),
             includeLabels=TRUE,
             colText=expression(bold("EXPLANATION")),
             LegCex=0.6,
             offsetLat="offsetLat",offsetLon="offsetLon",
             offsetLineLat="offsetLineLat",offsetLineLon="offsetLineLon",
             labels="map_nm"
             )

# Can Table 2 be generated from web services? Not fully....
pCodeInfo <- readNWISpCode(pcodes)
table2 <- pCodeInfo[,c("parameter_nm","parameter_units","casrn","parameter_cd")]
names(table2) <- c("Parameter Name", "Units", "CAS Number", "Parameter Code")
write.csv(table2, file="table2.csv",row.names=FALSE)
table2 <- read.csv("table2.csv",stringsAsFactors=FALSE)

library(reshape2)
for(i in sites){
  qwDataSite <- subset(qwDataWQP,MonitoringLocationIdentifier==paste0("USGS-",i))
  qwDataSiteShort <- qwDataSite[,c("ActivityStartDate",
                                    "ActivityDepthHeightMeasure.MeasureValue",
                                    "ResultDetectionConditionText",
                                    "CharacteristicName",
                                    "USGSPCode",
                                    "ResultMeasureValue",
                                    "ResultMeasure.MeasureUnitCode",
                                    "MeasureQualifierCode",
                                    "DetectionQuantitationLimitTypeName",
                                    "DetectionQuantitationLimitMeasure.MeasureValue",
                                    "DetectionQuantitationLimitMeasure.MeasureUnitCode"
                              )]
  noDepthData <- qwDataSiteShort[is.na(qwDataSiteShort$ActivityDepthHeightMeasure.MeasureValue),]
  subData <- qwDataSiteShort[!is.na(qwDataSiteShort$ActivityDepthHeightMeasure.MeasureValue),]
  
  
  numGraphs <- length(unique(subData$ActivityStartDate))
  
  
  #See if you want to futz with this...
  if(numGraphs > 10) {
    numRows <- ceiling(numGraphs/5)
    numCol <- 5
    
  } else if (numGraphs <= 5) {
    numRows <- 1
    numCol <- numGraphs
  } else if (numGraphs > 5 & numGraphs <= 10){
    numRows <- 2
    numCol <- ceiling(numGraphs/2)
  }
  yLabIndex <- seq(1,by = numCol, length.out = numRows)
  
  setPDF(layout = "landscape", basename = paste0(i,"LAKE_DEPTH_PROFILES"))
  layoutResponse <- setLayout(num.rows=numRows,num.cols = numCol, 
                              num.graphs = numGraphs)
  for(dateIndex in 1:numGraphs){
    date <- unique(subData$ActivityStartDate)[dateIndex]
    subDataDate <- subset(subData, ActivityStartDate==date)
    wTemp <- which(subDataDate$USGSPCode %in% "00010")
    doInext <- which(subDataDate$USGSPCode %in% "00300")
    graph1 <- setGraph(dateIndex, layoutResponse)
    graph1[3] <- -2
    yLabel <- ifelse(dateIndex %in% yLabIndex,"DEPTH, IN METERS","")
    plotReturn <- xyPlot(subDataDate$ResultMeasureValue[wTemp], 
           subDataDate$ActivityDepthHeightMeasure.MeasureValue[wTemp], 
           Plot=list(what="line",type="dashed"),xtitle="",
           ytitle=yLabel,xaxis.range=c(0,30),margin=graph1)
    
    addXY(subDataDate$ResultMeasureValue[doInext], 
          subDataDate$ActivityDepthHeightMeasure.MeasureValue[doInext], 
          new.axis="top",new.title=date)
    if(dateIndex == 1){
      addTitle(Main = paste0("Lake-Depth Profiles, ", 
                             paste(range(unique(subData$ActivityStartDate)),collapse=" to ")))
      addExplanation(plotReturn, where="ul")
    }
    
  }
  graphics.off()
#   qwDataSite <- qwDataNWIS[,c("sample_dt","parm_cd","remark_cd","result_va")]
#   qwDataSite <- qwDataSite[qwDataSite$parm_cd %in% c()]
#   longDF <- melt(qwDataSite, c("sample_dt","parm_cd"))
#   wideData <- dcast(longDF, formula = ... ~ variable + parm_cd)
}
