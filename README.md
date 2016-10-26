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
| `plotNames` | string value or vector | the name of the plot type you would like to produce [options: `ghtable`, `stagehydrograph`, `qwtable`, `depthprofiles`, `qwtimeseries`, `auto`] |
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

Dubgging
--------------------------

1. Decide which plot/report type you are going to be debugging.
2. Open `workflow-functions.R`, `functions-[plotname].R`, and `[plotname].Rmd` files.
3. Source `workflow-functions.R` and `functions-[plotname].R` using the source button at the top right of your scripts window.
4. Create the `wy` (numeric) and `siteNumber` (character) objects. You should debug using only one site at a time.
5. Run all of the `library()` calls in the first chunk of `[plotname].Rmd`.
6. You should now be able to step through each R chunk (greyed out box) of your `[plotname].Rmd` file.
7. Should you come across a function that you would like to investigate, CTRL+Click the name of the function to navigate there. Then add `browser()` on the line you would like to stop. Save the file and source it again. Be careful with placing `browser()` inside `if-else` structures, unless you truly want to only pause when it meets that specific condition.
8. Use the `Next`, `Continue`, and `Stop` buttons in the `Console` pane to navigate when in debug mode.
9. Should you make any changes to the code, make sure to save and source the file. If you make changes to `[plotname].Rmd`, you will only need to save that file and rerun the lines of code.
10. Before committing your changes, try running the overall report using `makeReports` and check that it looks as you would expect it to.

Committing Changes
--------------------------

*New to this repo? Fork the master repository and setup remotes before trying to follow these directions.*

1. Always start by making sure your local code matches what is upstream (ideally, this would happen before you make changes to avoid any merge conflicts). Use `git fetch upstream master` and then `git merge upstream/master` to pull remote changes to your local repository.
2. Use the "commit" button in your RStudio Git tab. Make sure you have checked the boxes of what you would like to commit. Then select "Commit". Type a message describing the changes, then click "Commit".
3. Using the green up arrow, "push" your changes to your remote fork (online).
4. Using a web browser, navigate to **your** remote fork.
5. Select "New Pull Request", and then "Create Pull Request"
6. Give your pull request (PR) a subject and a small description as necessary. If you are fixing a specific issue, reference that issue using `#` in the body of your PR. Then click "Create Pull Request".
7. If you would like someone to review, call them out in a comment using `@` or assign the PR to them. Otherwise, click "Merge".

##Disclaimer
This software is in the public domain because it contains materials that originally came from the U.S. Geological Survey, an agency of the United States Department of Interior. For more information, see the [official USGS copyright policy](http://www.usgs.gov/visual-id/credit_usgs.html#copyright/ "official USGS copyright policy")

Although this software program has been used by the U.S. Geological Survey (USGS), no warranty, expressed or implied, is made by the USGS or the U.S. Government as to the accuracy and functioning of the program and related program material nor shall the fact of distribution constitute any such warranty, and no responsibility is assumed by the USGS in connection therewith.

This software is provided "AS IS."

 [
    ![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png)
  ](http://creativecommons.org/publicdomain/zero/1.0/)
