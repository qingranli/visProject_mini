This visualization project was inspired by [the Reddit post by u/a__square__peg](https://www.reddit.com/r/dataisbeautiful/comments/miihce/oc_explaining_peak_cherry_blossom_with_warming/) on April 2, 2021. 

## Data source

The __cherry blossom peak bloom dates in Washington, D.C.__ are from the following sources.  
[data posted by EPA](https://www.epa.gov/climate-indicators/cherry-blossoms#tab-4)  
[data from National Park Service](https://www.nps.gov/subjects/cherryblossom/bloom-watch.htm)

The __air and soil temperatures__ are downloaded for the Powder Mill station (ID: 2049), which is published by SCAN. Station latitude = 39.02, longitude = -76.85. Daily sensors are placed with height = -2", -4", -8", -20", -40".  
[Soil Climate Analysis Network (SCAN)](https://www.wcc.nrcs.usda.gov/scan/)  
[Powder Mill station](https://wcc.sc.egov.usda.gov/nwcc/site?sitenum=2049)

The __Cherry blossom icon__ is downloaded from [emojipedia.org](https://emojipedia.org/twitter/twemoji-1.0/cherry-blossom/).


## Display of output
### blossom peak date vs. predicted soil temperature
![alt text](https://github.com/qingranli/visProject_mini/blob/main/Blossom_in_DC/Rplot_2021_peak.png)

### animation the R plot
![alt text](https://github.com/qingranli/visProject_mini/blob/main/Blossom_in_DC/Rplot_animate_peak.gif)

### regression model to predict soil temperature

![alt text](https://github.com/qingranli/visProject_mini/blob/main/Blossom_in_DC/Rplot_polyReg_result.png)