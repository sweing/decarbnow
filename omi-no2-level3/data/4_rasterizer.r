# ----------------------------------------------
# BASE
# ----------------------------------------------
rm(list=ls())
source("./base/init.r", chdir=TRUE)
loadPackages(c("raster", 
               "leaflet", 
               "rgdal", 
               "smoothr", 
               "units", 
               "lwgeom", 
               "rgeos", 
               "sf"))

# ----------------------------------------------

# ----------------------------------------------
# SETUP
# ----------------------------------------------
place = "World"
quantile_selection = c(0, 0.4, 0.8, 0.93)
crumps = c(10000, 5000, 1800, 1000)
f_holes = c(3001, 3000, 2000, NA)
opast = c(0.2, 0.2, 0.2, 0.2)
border_smooth = 3
simplify_tol = 0.02
# ----------------------------------------------

# ----------------------------------------------
# LOAD & PRESELECT TO SAVE MEMORY
# ----------------------------------------------
processedPath = file.path(folders$data, "selected", "cs")

plotPath = file.path(folders$tmp, "plots", "cs", place)
dir.create(plotPath, showWarnings = FALSE, recursive=TRUE)

baseData = loadData(file.path(processedPath, paste0(place, ".rData")))

baseData = baseData[no2tropo > 0]
baseData[, day := yday(baseData$date)]
baseData[, year := year(baseData$date)]
baseData = baseData[year > 2008]
# ----------------------------------------------

# ----------------------------------------------
# CALCULATE DIFFERENCE ANOTHER TIME
# ----------------------------------------------
# diffData = baseData[year == 2010 | year == 2018]
# diffData = diffData[day > 120 & day < 274]
# diffData = diffData[, .(value = mean(no2tropo, na.rm=TRUE)), by=c("year", "X", "Y")]
# diffData = dcast(diffData, X + Y ~ year, value.var = "value")
# setnames(diffData, c("X", "Y", "start", "end"))
# diffData[, diff := end - start]
# ----------------------------------------------

# ----------------------------------------------
# SUMMER TIME AVERAGES 2009-2018, SELECT HOTSPOTS
# ----------------------------------------------
baseData = baseData[day > 130 & day < 260]
meanData = baseData[, .(mValue = mean(no2tropo, na.rm=FALSE)), by=c("X", "Y")]
gc()

meanData = meanData[mValue >= quantile(meanData$mValue, 0.90)]
meanData[, q := rank(mValue)/nrow(meanData)]

l = length(quantile_selection) 

for (i in 1:l) {
    meanData[q >= quantile_selection[i], g := i]
}

meanData = meanData[, .(X, Y, g)]

rasters = list()

for (i in 1:l) {
    print(i)
    t = meanData[g >= i, .(X, Y, trans = opast[i])]
    tt = rasterFromXYZ(t)  #Convert first two columns as lon-lat and third as value                
    crs(tt) = sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
    print("Drop Crumps")
    tt = drop_crumbs(rasterToPolygons(tt, dissolve=TRUE), 
                     set_units(crumps[i], km^2))
    rasters[i] = tt
} 

polys = list()
for (i in 1:l) {
    tt = rasters[[i]]

    print("Fill Holes")
    if(!is.na(f_holes[i]))
        tt = fill_holes(tt, set_units(f_holes[i], km^2))
    print("Smooth")
    tt = smooth(tt, method = "ksmooth", smoothness=border_smooth)
    print("Simplify")
    ttd = data.frame(tt)
    tt = gSimplify(tt, tol = simplify_tol, topologyPreserve=TRUE)
    tt = SpatialPolygonsDataFrame(tt, ttd)
    polys[i] = tt
} 

# ----------------------------------------------

# ----------------------------------------------
# SHOW IN LEAFLET MAP
# ----------------------------------------------
poly_colors = c("red", "green", "blue", "yellow", "black", "white")

leaflet_map = leaflet() %>% addProviderTiles("CartoDB.Positron") 

for(i in 1:length(polys)){
    leaflet_map = leaflet_map %>% 
        addPolygons(data = polys[[i]], color = poly_colors[i])
}

leaflet_map
# ----------------------------------------------

# ----------------------------------------------
# RBIND, SAVE
# ----------------------------------------------
final_poly = do.call( rbind, polys )

writeOGR(final_poly, file.path(folders$data, "selected", "cs", paste0(place, "_rastered.geojson")), layer="dfr_pg", driver="GeoJSON", overwrite_layer = TRUE)
# ----------------------------------------------