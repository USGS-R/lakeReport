library(smwrGraphs)
load("oneSite.RData")

i <- "455638089034501"
numGraphs <- length(unique(subData$ActivityStartDate))

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

baseName <- paste0(i,"LAKE_DEPTH_PROFILES")
setSweave(file.path("figure",baseName),11,8)
layoutResponse <- setLayout(num.rows=numRows,num.cols = numCol, 
                            num.graphs = numGraphs)
for(dateIndex in 1:numGraphs){
  date <- unique(subData$ActivityStartDate)[dateIndex]
  subDataDate <- subset(subData, ActivityStartDate==date)
  wTemp <- which(subDataDate$USGSPCode %in% "00010")
  doInext <- which(subDataDate$USGSPCode %in% "00300")
  graph1 <- setGraph(dateIndex, layoutResponse)
  graph1 <- setTopMargin(graph1)
  yLabel <- ifelse(dateIndex %in% yLabIndex,"DEPTH, IN METERS","")
  
  plotReturn <- xyPlot(subDataDate$ResultMeasureValue[wTemp], 
                         subDataDate$ActivityDepthHeightMeasure.MeasureValue[wTemp], 
                         Plot=list(name="Water Temperature (C)", what="line",type="dashed"),xtitle="",
                         ytitle=yLabel,xaxis.range=c(0,30),margin=graph1)
    
  plotReturn <- addXY(subDataDate$ResultMeasureValue[doInext], 
          subDataDate$ActivityDepthHeightMeasure.MeasureValue[doInext],
          Plot=list(name="Dissolved Oxygen"),
          new.axis="top",new.title=date, current=plotReturn)
  if(dateIndex == 1){
    addTitle(Main = paste0("Lake-Depth Profiles, ", 
                  paste(range(unique(subData$ActivityStartDate)),collapse=" to ")))
          addExplanation(plotReturn, where="ul")
  }
  
}
graphics.off()
