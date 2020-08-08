# server file for shiny

library(shiny)
library(leaflet)
library(RColorBrewer)
library(sf)
library(tidyverse)
library(readxl)
library(googleway)
library(shinydashboard)

# tables preprocessing... this is also in ui.R file. 
eo_parcels_sf <- st_read("./data/eo_parcels.shp") %>%
  mutate(addr_full = sts_ddr) %>%
  rename(apn_sort = apn_srt)

assessor <- read_csv("./data/assessor.csv") %>%
  mutate(addr_full = paste0(street_no," ",street_name," ",city," ",zip))

bus_licenses <- read_csv("./data/bus_licenses.csv") %>%
  mutate(addr_full2 = paste0(addr," ",city_st))


# the server function
function(input, output, session) {
  # output$addr_col <- reactive({eo_parcels_sf$addr_full})
  # output$apn_numbers <- reactive({eo_parcels_sf$apn_sort})

  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    bbox <- st_bbox(eo_parcels_sf) %>% as.vector()
    leaflet() %>% addTiles() %>% addProviderTiles('Esri.WorldImagery') %>%
      fitBounds(bbox[1], bbox[2], bbox[3], bbox[4])
  })
  
  output$assessor_dt <- renderTable({
    assessor %>% filter(addr_full == input$search_addr & owner_name == input$search_owner) %>% 
      select(apn_sort, ma_street_addr, ma_street_no, ma_city_st, ma_zip, owner_name, addr_full) %>%
      mutate('Mailing Address' = paste0(ma_street_addr, ", ", ma_city_st, " ", ma_zip)) %>%
      rename('APN' = apn_sort, 'Owner' = owner_name, 'Address' = addr_full) %>%
      select(-c(ma_street_addr, ma_street_no, ma_city_st, ma_zip))
  })
  
  output$bus_licenses_dt <- renderTable({
    bus_licenses %>% 
      select(apn_sort, sic_desc, owner, addr_full2, exp_date) %>%
      rename('APN' = apn_sort, 'Owner' = owner, 'Address' = addr_full2, 'SIC' = sic_desc, 'Expiration' = exp_date)
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