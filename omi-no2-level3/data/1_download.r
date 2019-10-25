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
removeRawFile = FALSE
years = c(2019)
# ----------------------------------------------

# ----------------------------------------------
# PREPARATION / LOAD FILE LISTS
# ----------------------------------------------
rawPath = file.path(folders$data, "raw")
dir.create(rawPath, showWarnings = FALSE, recursive=TRUE)
hdf5Files = read.table(file.path(folders$tmp, "subset_OMNO2d_003_20190918_103218.txt"), stringsAsFactors = FALSE)
hdf5Saved = list.files(savePath, pattern = "\\.rData$", recursive=TRUE)
# ----------------------------------------------

no2Data = list()
for(i in 1:nrow(hdf5Files)){
    #i=5002
    hdf5File = hdf5Files[i,]
    hdf5FileName = sub('.*\\/', '', hdf5File)
    #FOR NOW, ONLY 2018 DATA
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
}

