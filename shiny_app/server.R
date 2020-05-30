library(shiny)
library(leaflet)
library(RColorBrewer)
library(sf)
library(tidyverse)
library(readxl)
library(googleway)
library(shinydashboard)

unlink("data", recursive=TRUE)
dir.create("data")
download.file("https://eo-lu-inventory.s3-us-west-1.amazonaws.com/for_shiny/eo_parcels/EO_Parcels.shp",'./data/eo_parcels.shp', method = "wget")
download.file("https://eo-lu-inventory.s3-us-west-1.amazonaws.com/for_shiny/eo_parcels/EO_Parcels.dbf",'./data/eo_parcels.dbf', method = "wget")
download.file("https://eo-lu-inventory.s3-us-west-1.amazonaws.com/for_shiny/eo_parcels/EO_Parcels.prj",'./data/eo_parcels.prj', method = "wget")
download.file("https://eo-lu-inventory.s3-us-west-1.amazonaws.com/for_shiny/eo_parcels/EO_Parcels.shx",'./data/eo_parcels.shx', method = "wget")

download.file("https://eo-lu-inventory.s3-us-west-1.amazonaws.com/for_shiny/assessor/assessor_ownership.csv",'./data/assessor.csv', method = "wget")

eo_parcels_sf <- st_read("./data/eo_parcels.shp") %>%
  mutate(addr_full = sts_ddr) %>%
  rename(apn_sort = apn_srt)

assessor <- read_csv("./data/assessor.csv") %>%
  mutate(addr_full = paste0(street_no," ",street_name," ",city," ",zip))

server <- function(input, output, session) {
  
  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    bbox <- st_bbox(eo_parcels_sf) %>% as.vector()
    leaflet() %>% addTiles() %>% addProviderTiles('Esri.WorldImagery') %>%
      fitBounds(bbox[1], bbox[2], bbox[3], bbox[4])
  })
  
  output$assessor_dt <- renderTable({
    assessor %>% filter(addr_full == input$search_addr) %>% 
      select(apn_sort, ma_street_addr, ma_street_no, ma_city_st, ma_zip, owner_name, addr_full) %>%
      mutate('Mailing Address' = paste0(ma_street_addr, ", ", ma_city_st, " ", ma_zip)) %>%
      rename('APN' = apn_sort, 'Owner' = owner_name, 'Address' = addr_full) %>%
      select(-c(ma_street_addr, ma_street_no, ma_city_st, ma_zip))
  })
  
  
  reactMap <- reactive({
    eo_parcels_sf %>% filter(addr_full == input$search_addr)
  })
  
  observe({
    bbox <- st_bbox(reactMap()) %>% as.vector()
    
    proxy <- leafletProxy("map", data = reactMap()) %>%
      clearShapes() %>%
      addPolygons(weight = 1) %>%
      fitBounds(bbox[1], bbox[2], bbox[3], bbox[4])
  })
}