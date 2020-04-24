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
download.file("https://eo-lu-inventory.s3-us-west-1.amazonaws.com/for_shiny/business_licenses/bus_licenses.csv",'./data/bus_licenses.csv', method = "wget")

eo_parcels_sf <- st_read("./data/eo_parcels.shp") %>%
  mutate(addr_full = sts_ddr) %>%
  rename(apn_sort = apn_srt)

assessor <- read_csv("./data/assessor.csv") %>%
  mutate(addr_full = paste0(street_no," ",street_name," ",city," ",zip))

bus_licenses <- read_csv("./data/bus_licenses.csv") %>%
  mutate(addr_full2 = paste0(addr," ",city_st))

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


# Define UI for application that draws a histogram
ui <- dashboardPage(
  dashboardHeader(title = "East Oakland Land Use Explorer"),
  dashboardSidebar(
    selectizeInput("search_addr","Search Address",eo_parcels_sf$addr_full, selected = NULL, multiple = FALSE, options = list(create = FALSE)),
    selectizeInput("search_owner","Search Owner",eo_parcels_sf$owner_name, selected = NULL, multiple = FALSE, options = list(create = FALSE))
  ),
  dashboardBody(
    fluidRow(
      column(
        width = 6,
        box(
          solidHeader = TRUE,
          title = "Assessor",
          tableOutput('assessor_dt'),
          width = NULL,
          collapsible = TRUE
        )
      ),
      column(
        width = 6,
        box(
          solidHeader = TRUE,
          title = "Parcel Map",
          leafletOutput("map"),
          width = NULL
        )
      )),
    fluidRow(
      column(
        width = 10,
        box(
          solidHeader = TRUE,
          title = "Business Licenses",
          tableOutput('bus_licenses_dt'),
          width = NULL,
          collapsible = TRUE
        )
      )
    )
  )
)

shinyApp(ui = ui, server = server)
