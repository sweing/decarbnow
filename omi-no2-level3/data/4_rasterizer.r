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
quantile_selection = c(0, 0.4, 0.6, 0.8, 0.85, 0.92, 0.95, 0.97, 0.99, 0.995)
#quantile_selection = c(0, 0.4, 0.8, 0.95, 0.97)
crumps = c(10000, 5000, 4000, 3000, 2000, 1800, 1600, 200, 200, 200)
#crumps = c(10000, 5000, 1800, 1000, 200)
f_holes = c(3001, 3000, 2000, 1000, 1000, 1000, 1000, 1000, NA, NA)
#f_holes = c(3001, 3000, 2000, 1000, NA)

opast = c(0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2)
border_smooth = 3
simplify_tol = 0.02
years = c(2018)
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
gc()
for(yr in years){

        #yr = 2008
    tmpData = baseData[year == yr]
    #gc()
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
    northData = tmpData[day > 130 & day < 260 & Y > 0]
    southData = tmpData[day < 80 | day > 310 & Y < 0]
    tmpData = rbind(northData, southData)
    gc()
    meanData = tmpData[, .(mValue = median(no2tropo, na.rm=FALSE)), by=c("X", "Y")]
    rm(tmpData, northData, southData)
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
    poly_colors = c("brown", "purple", "red", "green", "blue", "yellow", "black", "gray", "white", "orange")
    
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
    
    writeOGR(final_poly, file.path(folders$data, "selected", "cs", paste0(place, "_", yr, "_rastered.geojson")), layer="dfr_pg", driver="GeoJSON", overwrite_layer = TRUE)
    # ----------------------------------------------
    rm(meanData, raster, t, polys, final_poly)
    gc()
}

