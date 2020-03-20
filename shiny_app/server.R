library(shiny)
library(leaflet)
library(RColorBrewer)
library(sf)
library(tidyverse)
library(readxl)
library(googleway)
library(shinydashboard)

eo_parcels_sf <- st_read("./../data/shiny_in/eo_assess_parcels_sf.shp") %>%
  mutate(addr_full = paste0(st_no," ",st_name)) %>%
  rename(apn_sort = apn_srt)

oak_bus_license <- read.csv("./../data/shiny_in/business_data.csv")

map_key <- "AIzaSyBqD0BnsyzQEmLtbe6egspJ-ljHsZ63zoU"

server <- function(input, output, session) {
  
  output$streeview <- renderUI({
    tags$img(src = google_streetview(location = paste0(input$search_addr," Oakland, CA"),
                                     size = c(350,350), output = "html",
                                     key = map_key),  width = "100%", height = "100%")
  })
  
  # Incremental changes to the map (in this case, replacing the
  # circles when a new color is chosen) should be performed in
  # an observer. Each independent set of things that can change
  # should be managed in its own observer.
  
  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    bbox <- st_bbox(eo_parcels_sf) %>% as.vector()
    leaflet() %>% addTiles() %>% addProviderTiles('Esri.WorldImagery') %>%
      fitBounds(bbox[1], bbox[2], bbox[3], bbox[4])
  })
  
  output$assessor_dt <- renderTable({
    #filter() automatically 'quotes' arguments. To use variables, we quote manually using sym() in the local environment
    #unquote with !!() to evaluate as variables
    field = sym(input$search_by)
    value = ""
    if (input$search_by=="addr_full") {value = input$search_addr}
    if (input$search_by=="apn_sort") {value = input$search_apn}
    
    eo_parcels_sf %>% filter(!!(field) == value) %>% 
      st_drop_geometry() %>%
      select(apn_sort, use_cod, ma_addr, m_cty_s, ma_zip, owner, us_cd_c, addr_full) %>%
      mutate('Mailing Address' = paste0(ma_addr, ", ", m_cty_s, " ", ma_zip)) %>%
      rename('APN' = apn_sort, 'Use Code' = use_cod, 'Owner' = owner, 'Use Code Description' = us_cd_c,'Address' = addr_full) %>%
      select(-c(ma_addr, m_cty_s, ma_zip))
  })
  
  output$businesses_dt <- renderTable({
    #filter() automatically 'quotes' arguments. To use variables, we quote manually using sym() in the local environment
    #unquote with !!() to evaluate as variables
    field = sym(input$search_by)
    value = ""
    if (input$search_by=="addr_full") {value = input$search_addr}
    if (input$search_by=="apn_sort") {value = input$search_apn}
    
    apn_list <- (eo_parcels_sf %>% filter(!!(field) == value))$apn_sort
    oak_bus_license %>% filter(apn_sort %in% apn_list) %>%
      select(acct_no, dba, owner, sic_code, sic_desc, dist_parc_to_sales) %>%
      rename("Account No." = acct_no,"Business Name" = dba, "Owner" = owner, "SIC Code" = sic_code, "SIC Description" = sic_desc,"Matching Distance" = dist_parc_to_sales)
  })
  
  reactMap <- reactive({
    #filter() automatically 'quotes' arguments. To use variables, we quote manually using sym() in the local environment
    #unquote with !!() to evaluate as variables
    field = sym(input$search_by)
    value = ""
    if (input$search_by=="addr_full") {value = input$search_addr}
    if (input$search_by=="apn_sort") {value = input$search_apn}
    
    eo_parcels_sf %>% filter(!!(field)==value)
  })
  
  observe({
    bbox <- st_bbox(reactMap()) %>% as.vector()
    
    proxy <- leafletProxy("map", data = reactMap()) %>%
      clearShapes() %>%
      addPolygons(weight = 1) %>%
      fitBounds(bbox[1], bbox[2], bbox[3], bbox[4])
  })
}