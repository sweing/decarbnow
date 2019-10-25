loadPackages = function(requiredPackages) {
    installPackages = requiredPackages[!(requiredPackages %in% installed.packages()[,"Package"])]
    if(length(installPackages) > 0)
        install.packages(installPackages)
    
    invisible(lapply(requiredPackages, library, character.only = TRUE))
}

loadData = function(fileName)   {
    if (endsWith(fileName, ".dta")) {
        data = as.data.table(read.dta13(fileName))
    } else {
        load(fileName); 
    }
    return(data) 
}

saveData = function(data, fileName) { 
    if (endsWith(fileName, ".dta")) {
        write.dta(data, fileName)
    } else if (endsWith(fileName, ".csv")){
        write.csv(data, fileName)
    } else {
        save(data, file=fileName)
    }
}
