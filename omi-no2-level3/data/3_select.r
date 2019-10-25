# ----------------------------------------------
# BASE
# ----------------------------------------------
rm(list=ls())
source("./base/init.r", chdir=TRUE)
# ----------------------------------------------

# ----------------------------------------------
# SETUP
# ----------------------------------------------
plants = list(
    Europe = list(
        minX = -13.1,
        maxX = 28.7,
        minY = 34.67,
        maxY = 72.12
    ),
    CentralEurope = list(
        minX = 5,
        maxX = 20,
        minY = 45,
        maxY = 55
    ),
    World = list(
        minX = -180,
        maxX = 180,
        minY = -90,
        maxY = 90
    ),
    China = list(
        minX = 73,
        maxX = 145,
        minY = 20,
        maxY = 54
    ),
    Austria = list(
        minX = 9,
        maxX = 17.2,
        minY = 46,
        maxY = 49.1
    ),
    USA = list(
        minX = -124.5,
        maxX = -66,
        minY = 24,
        maxY = 48
    )
    
)

plant = "Europe"
# ----------------------------------------------

# ----------------------------------------------
# PREPARATION / LOAD FILE LISTS
# ----------------------------------------------
processedPath = file.path(folders$data, "processed", "cs")
savedFiles = list.files(processedPath, pattern = "\\.rData$", recursive=TRUE)
# ----------------------------------------------

baseData = list()
for(i in 1:length(savedFiles)){
    savedFile = savedFiles[i]
    print(savedFile)
    tmp = loadData(file.path(processedPath, savedFile))
    tmp = tmp[X > plants[[plant]]$minX & X < plants[[plant]]$maxX & Y > plants[[plant]]$minY & Y < plants[[plant]]$maxY]
    baseData[[i]] = tmp
    rm(tmp)
    gc()
}
# ----------------------------------------------

# ----------------------------------------------
# Save
# ----------------------------------------------
finalData = rbindlist(baseData)
saveData(finalData, file.path(folders$data, "selected", "cs", paste0(plant, ".rData")))
# ----------------------------------------------

