# ref: https://stackoverflow.com/questions/52574339/best-way-to-install-required-packages-in-r

# uncomment following lines to update R

# install.packages("installr", repos = "https://cran.case.edu/")
# library(installr)
# updateR()

# install dependencies

pkgs <- c("shiny", "leaflet", "RColorBrewer", "sf", "tidyverse", "readxl", "googleway", "shinydashboard", "remotes", "shiny.router")
install.packages(pkgs, repos = "https://cran.case.edu/")
lapply(pkgs, require, character.only = TRUE)
remotes::install_github("rstudio/bootstraplib")
