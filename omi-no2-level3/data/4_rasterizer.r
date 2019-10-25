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
# baseData[, value := mean(no2tropo, na.rm=TRUE) - no2tropo, by=c("day", "X", "Y")]
# baseData[, rMean := rollmean(as.double(value), 7, fill=NA, align="right", na.rm=TRUE), by=c("X", "Y")]
# baseData = merge(baseData, baseData[, .(date = seq(min(baseData$date), max(baseData$date), by="days")), by=c("X", "Y")], by=c("X", "Y", "date"), all.y=TRUE)
# loadPackages("imputeTS")
# baseData[, rMean_imp := na.kalman(rMean), by=c("X", "Y")]
# 
# loadPackages("signal")
# bf <- butter(1, 0.003)  
# baseData[, filtered := sin(2*pi*rMean_imp*2.3) + 0.25*rnorm(length(rMean_imp))]
# baseData[, filtered := as.double(filter(bf, rMean_imp))]
# 
# baseData[!is.na(rMean), rMean_imp := NA]
# #baseData = melt(baseData, id.vars = c("X", "Y", "date", "year", "day"))
# rasterData = baseData[, .(X, Y, date, filtered)]



diffData = baseData[year == 2010 | year == 2018]
diffData = diffData[day > 120 | day < 274]
diffData = diffData[, .(value = mean(no2tropo, na.rm=TRUE)), by=c("year", "X", "Y")]
diffData = dcast(diffData, X + Y ~ year, value.var = "value")
setnames(diffData, c("X", "Y", "start", "end"))
diffData[, diff := end - start]

meanData = baseData[day > 120 | day < 274]
meanData = meanData[, .(value = mean(no2tropo, na.rm=TRUE)), by=c("X", "Y")]
#meanData = dcast(meanData, X + Y, value.var = "value")
#setnames(diffData, c("X", "Y", "start", "end"))

#rasterData = diffData[, .(X, Y, diff)]

dfr <- rasterFromXYZ(meanData)  #Convert first two columns as lon-lat and third as value                
crs(dfr) <- sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

leaflet() %>% addProviderTiles("CartoDB.Positron") %>%
    addRasterImage(dfr, colors = "Spectral", opacity = 0.5)

# loadPackages("rgdal")
# 
# 
# xy <- meanData[,c(1,2)]
# 
# spdf <- SpatialPointsDataFrame(coords = xy, data = meanData,
#                                proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))

dfr_pg = rasterToPolygons(dfr)
#class(dfr_pg)
writeOGR(dfr_pg, file.path(folders$data, "selected", "cs", paste0(plant, "_rastered.geojson")), layer="dfr_pg", driver="GeoJSON")

saveData(dfr, file.path(folders$data, "selected", "cs", paste0(plant, "_rastered.rData")))
