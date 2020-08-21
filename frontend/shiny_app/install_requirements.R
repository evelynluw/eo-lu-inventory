# running this script might take a long time! 
# update current packages
# from https://www.r-bloggers.com/update-all-user-installed-r-packages-again/
#install.packages( 
#    lib  = lib <- .libPaths()[1],
#    pkgs = as.data.frame(installed.packages(lib), stringsAsFactors=FALSE)$Package,
#    type = 'source'
#)

# install required packages
#ipak <- function(pkg){
#    new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
#    if (length(new.pkg)) 
#        install.packages(new.pkg, dependencies = TRUE)
#    sapply(pkg, require, character.only = TRUE)
#}

# from https://stackoverflow.com/questions/52574339/best-way-to-install-required-packages-in-r
pkgs <- c("shiny", "leaflet", "RColorBrewer", "sf", "tidyverse", "readxl", "googleway", "shinydashboard")
install.packages(pkgs)
lapply(pkgs, require, character.only = TRUE)

