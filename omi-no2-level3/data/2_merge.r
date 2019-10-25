# ----------------------------------------------
# BASE
# ----------------------------------------------
rm(list=ls())
source("./base/init.r", chdir=TRUE)
loadPackages(c("h5", "raster"))
# ----------------------------------------------

# ----------------------------------------------
# CONFIG
# ----------------------------------------------
#REMOVE RAW FILE AFTER PROCESSING?
removeRawFile = FALSE
cloudScreened = TRUE
# ----------------------------------------------

# ----------------------------------------------
# PREPARATION / LOAD FILE LISTS
# ----------------------------------------------
rawPath = file.path(folders$data, "raw")
hdf5Saved = list.files(rawPath, pattern = "\\.he5$", recursive=TRUE)
# ----------------------------------------------

years = unique(substr(hdf5Saved, 20, 23))
months = unique(substr(hdf5Saved, 25, 26))

if(cloudScreened){
    columnNames = c("ColumnAmountNO2TropCloudScreened", "ColumnAmountNO2CloudScreened")
} else {
    columnNames = c("ColumnAmountNO2Trop", "ColumnAmountNO2")
}

for(year in years){
    if(year == 2019)
        next
    if(cloudScreened){
        savePath = file.path(folders$data, "processed", "cs")
    } else {
        savePath = file.path(folders$data, "processed", "ncs")
    }
    if(!file.exists(file.path(savePath, year)))
        dir.create(file.path(savePath, year), showWarnings = FALSE, recursive=TRUE)
    for(month in months){
        if(file.exists(file.path(savePath, year, paste0(month, ".rData"))))
            next
        
        tmpMonth = list()
        for(i in 1:length(hdf5Saved)){
            hdf5File = hdf5Saved[i]
            if(substr(hdf5File, 20, 23) != year)
                next
            if(substr(hdf5File, 25, 26) != month)
                next
            
            #LOAD HDF5 FILE
            prec = h5file(file.path(rawPath, hdf5File))
            
            #REMOVE RAW FILE, EVENTUALLY
            if(removeRawFile)
                file.remove(file.path(rawPath, hdf5File))
            print(hdf5File)
            
            no2tropo = prec["HDFEOS"]["GRIDS"]["ColumnAmountNO2"]["Data Fields"][columnNames[1]][]
            no2 = prec["HDFEOS"]["GRIDS"]["ColumnAmountNO2"]["Data Fields"][columnNames[2]][]
            h5close(prec)
            
            r <- raster(nrow=nrow(no2tropo), ncol=ncol(no2tropo))
            lons <- init(r, 'x')
            lats <- init(r, 'y')

            tmp <- data.table(X=as.vector(lons), 
                              Y=as.vector(rev(lats)),
                              no2=as.vector(t(no2)),
                              no2tropo=as.vector(t(no2tropo)))
            
            tmp$date = as.Date(paste(substr(hdf5File, 20, 23), substr(hdf5File, 25, 26), substr(hdf5File, 27, 28), sep = "-"))

            #SAVE/RM DATA
            tmpMonth[[i]] = tmp
            rm(tmp)
        }
        tmpMonth = rbindlist(tmpMonth)
        saveData(tmpMonth, file.path(savePath, year, paste0(month, ".rData")))
        print("Saved.")
        rm(tmpMonth)
        gc()
    }
}




