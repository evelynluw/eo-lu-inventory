# server file for shiny

library(shiny)
library(leaflet)
library(RColorBrewer)
library(sf)
library(tidyverse)
library(readxl)
library(googleway)
library(shinydashboard)
library(shiny.router)

# the server function
function(input, output, session) {
  router(input, output)
}