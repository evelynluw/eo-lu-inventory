# UI definition for shiny

library(shiny)
library(leaflet)
library(RColorBrewer)
library(sf)
library(tidyverse)
library(readxl)
library(googleway)
library(shinydashboard)

# data downloading... should we create another function?
# moved here because ui seems to run first.
# only need to run once every certain amount of time

# unlink("data", recursive=TRUE)
# dir.create("data")
# download.file("https://eo-lu-inventory.s3-us-west-1.amazonaws.com/for_shiny/eo_parcels/EO_Parcels.shp",'./data/eo_parcels.shp', method = "wget", extra="--no-check-certificate")
# download.file("https://eo-lu-inventory.s3-us-west-1.amazonaws.com/for_shiny/eo_parcels/EO_Parcels.dbf",'./data/eo_parcels.dbf', method = "wget", extra="--no-check-certificate")
# download.file("https://eo-lu-inventory.s3-us-west-1.amazonaws.com/for_shiny/eo_parcels/EO_Parcels.prj",'./data/eo_parcels.prj', method = "wget", extra="--no-check-certificate")
# download.file("https://eo-lu-inventory.s3-us-west-1.amazonaws.com/for_shiny/eo_parcels/EO_Parcels.shx",'./data/eo_parcels.shx', method = "wget", extra="--no-check-certificate")
# download.file("https://eo-lu-inventory.s3-us-west-1.amazonaws.com/for_shiny/assessor/assessor_ownership.csv",'./data/assessor.csv', method = "wget", extra="--no-check-certificate")
# download.file("https://eo-lu-inventory.s3-us-west-1.amazonaws.com/for_shiny/business_licenses/bus_licenses.csv",'./data/bus_licenses.csv', method = "wget", extra="--no-check-certificate")


# these functions are also in server.R
# probably need to be refactored away


eo_parcels_sf <- st_read("./data/eo_parcels.shp") %>%
  mutate(addr_full = sts_ddr) %>%
  rename(apn_sort = apn_srt)

# The UI object being returned
# Define UI for application that draws a histogram
dashboardPage(
  dashboardHeader(title = "East Oakland Land Use Explorer"),
  dashboardSidebar(
      radioButtons("search_by", "Search By:", c("Address"="addr_full", "APN"="apn_sort")),
      conditionalPanel(condition="input.search_by == 'addr_full'",
        selectizeInput("search_addr","Search Address", eo_parcels_sf$addr_full, selected = NULL, multiple = FALSE, options = list(create = FALSE)),
      ),
      conditionalPanel(condition="input.search_by == 'apn_sort'",
        selectizeInput("search_apn","Search APN", eo_parcels_sf$apn_sort, selected = NULL, multiple = FALSE, options = list(create = FALSE))
      )
  ),
  dashboardBody(
    fluidRow(
      column(
        width = 8,
        box(
          solidHeader = TRUE,
          title = "Assessor",
          tableOutput('assessor_dt'),
          width = NULL,
          collapsible = TRUE
        )
      ),
      column(
        width = 4,
        box(
          solidHeader = TRUE,
          title = "Parcel Map",
          leafletOutput("map"),
          width = NULL
        )
      )
    )
  )
)

