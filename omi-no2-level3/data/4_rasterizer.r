# ----------------------------------------------
# BASE
# ----------------------------------------------
rm(list=ls())
source("./base/init.r", chdir=TRUE)
loadPackages(c("lubridate", "zoo", "raster", "leaflet"))
# ----------------------------------------------

processedPath = file.path(folders$data, "selected", "cs")
plant = "Europe"
plotPath = file.path(folders$tmp, "plots", "cs", plant)
dir.create(plotPath, showWarnings = FALSE, recursive=TRUE)

baseData = loadData(file.path(processedPath, paste0(plant, ".rData")))
baseData = baseData[no2tropo > 0]
baseData[, day := yday(baseData$date)]
baseData[, year := year(baseData$date)]
meanData = baseData[day > 120 | day < 274]
meanData = meanData[, .(value = mean(no2tropo, na.rm=TRUE)), by=c("X", "Y")]

dfr = rasterFromXYZ(meanData)  #Convert first two columns as lon-lat and third as value                
crs(dfr) = sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

#TEST WITH LEAFLET
leaflet() %>% addProviderTiles("CartoDB.Positron") %>%
    addRasterImage(dfr, colors = "Spectral", opacity = 0.5)

dfr_pg = rasterToPolygons(dfr)

writeOGR(dfr_pg, file.path(folders$data, "selected", "cs", paste0(plant, "_rastered.geojson")), layer="dfr_pg", driver="GeoJSON")
saveData(dfr, file.path(folders$data, "selected", "cs", paste0(plant, "_rastered.rData")))
