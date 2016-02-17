`Lake Report`
=============

Scripts and report generator for Wisconsin Lake Reports.

Workflow
--------------------------

1. Open RStudio & the `lakeReport` project
2. Source the `workflow-functions.R` script
3. Specify inputs to `makeReports` (see below)
4. Run `makeReports`


**Required Inputs for `makeReports` function**

| Input | Type | Description |
| --- | --- | --- |
| `siteNumber` | string value or vector | the USGS station number OR `auto` |
| `wy` | numeric value | water year |
| `plotNames` | character value or vector | the name of the plot type you would like to produce [options: `ghtable`, `stagehydrograph`, `qwtable`, `depthprofiles`, `qwtimeseries`, `auto`] |
| `output` | string value | the format you would like the file saved as [options: `pdf` or `word`] |


**Optional Inputs for `makeReports` function with `stagehydrograph`**

| Input | Type | Description |
| --- | --- | --- |
| `filepath` | string value | indicates where your csv is located |
| `dateTime` | string value | indicates the column name in your csv where dates are stored |
| `gageHeight` | string value | indicates the column name in your csv where gage heights are stored |


Workflow Examples
--------------------------

More examples located in `workflow-examples.R`.

``` r
# single site, single report
wy <- 2014
siteNumber <- '05390500'
plotNames <- 'ghtable'
output <- 'pdf'
makeReports(siteNumber, wy, plotNames, output)

# single site, multiple reports as word
wy <- 2014
siteNumber <- '455638089034501'
plotNames <- c('qwtable', 'depthprofiles', 'qwtimeseries')
output <- 'word'
makeReports(siteNumber, wy, plotNames, output)

# get all plotNames from `plotNames_by_site.csv` for a single site
wy <- 2014
siteNumber <- '05390500'
plotNames <- 'auto'
output <- 'word'
makeReports(siteNumber, wy, plotNames, output)

# run all possible site and plotName combinations from `plotNames_by_site.csv`  
# currently makes all 89 combinations in ~ 6 minutes
wy <- 2014
siteNumber <- 'auto'
plotNames <- 'auto'
output <- 'word'
makeReports(siteNumber, wy, plotNames, output)

# use data from a file for stagehydrograph (not using dataRetrieval)
wy <- 2014
siteNumber <- '05390500'
plotNames <- 'stagehydrograph'
makeReports(siteNumber, wy, plotNames, 'pdf', 
            filePath = 'myfilepath',
            dateTime = 'sample_dt',
            gageHeight = 'result_va')
```


##Disclaimer
This software is in the public domain because it contains materials that originally came from the U.S. Geological Survey, an agency of the United States Department of Interior. For more information, see the [official USGS copyright policy](http://www.usgs.gov/visual-id/credit_usgs.html#copyright/ "official USGS copyright policy")

Although this software program has been used by the U.S. Geological Survey (USGS), no warranty, expressed or implied, is made by the USGS or the U.S. Government as to the accuracy and functioning of the program and related program material nor shall the fact of distribution constitute any such warranty, and no responsibility is assumed by the USGS in connection therewith.

This software is provided "AS IS."

 [
    ![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png)
  ](http://creativecommons.org/publicdomain/zero/1.0/)
