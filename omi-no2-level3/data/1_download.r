# ----------------------------------------------
# BASE
# ----------------------------------------------
rm(list=ls())
source("./base/init.r", chdir=TRUE)
# ----------------------------------------------

# ----------------------------------------------
# CONFIG
# ----------------------------------------------
#REMOVE RAW FILE AFTER DOWNLOAD?
years = c(2007:2017)
# ----------------------------------------------

# ----------------------------------------------
# PREPARATION / LOAD FILE LISTS
# ----------------------------------------------
rawPath = file.path(folders$data, "raw")
dir.create(rawPath, showWarnings = FALSE, recursive=TRUE)
hdf5Files = read.table(file.path(folders$tmp, "subset_OMNO2d_003_20200106_095620.txt"), stringsAsFactors = FALSE)
hdf5Saved = list.files(rawPath, pattern = "\\.he5$", recursive=TRUE)
# ----------------------------------------------

for(i in 1:nrow(hdf5Files)){
    #i=5500
    hdf5File = hdf5Files[i,]
    hdf5FileName = sub('.*\\/', '', hdf5File)
    
    if(!(substr(hdf5FileName, 20, 23) %in% years))
        next
    
    if(file.exists(file.path(rawPath, hdf5FileName)))
        next
    
    print(hdf5File)

    url=paste0(hdf5File)
    download.file(url,
                  destfile = file.path(rawPath, hdf5FileName),
                  quiet = TRUE,
                  method="wget",
                  extra=paste0("--user=", authUser, " --password=", authPassword))
    
    print("Downloading completed. Next.")
    gc()
}

