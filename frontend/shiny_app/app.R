# UI definition for shiny

library(shiny)
library(leaflet)
library(RColorBrewer)
library(sf)
library(tidyverse)
library(readxl)
library(googleway)
library(shinydashboard)
library(shiny.router)
# library(bootstraplib) 

# Pages

root_page <- navbarPage(
  title = "East Oakland Facility Inventory",
  id = "nav",
  fluid = TRUE,
  collapsible = TRUE,
  theme = "flatly.min.css",
  tabPanel("Home", 
    withTags({
      div(class = "home__div",
        h1("Welcome to the East Oakland Land Use Inventory"),
        p("Use this page to research a facility in East Oakland."),
        p("Select an option below to get started."),
        actionButton("goToSearchbyAddress", "I have a facility I want to research by address"),
        actionButton("goToSearchbyNeighborhood", "I want to explore facilities by neighborhood"),
        style(type='text/css', ".home__div { width: 60%; margin: auto; min-width: 20em; }")
      )
    })
  ),
  tabPanel("Search",
    actionButton("hideTab", "Hide 'Details' tab"), 
    actionButton("goToDetails", "Go to 'Details' tab")
  ),
  tabPanel("Details", 
    titlePanel("Details page"),
    actionButton("goToSearch", "Back")
  ),
  tabPanel("Glossary"),
  tabPanel("About"),
  tabPanel("FAQ"), 
  footer = withTags({
    div(class = "footer row bg-primary container",
      div(class="col-md-3 center-block", 
        a(class = "btn btn-info btn-sm", href="https://shiny.rstudio.com/", "Contact Us")
      ),
      p(class = "col-md-6 text-center", "Maintained by Communities for a Better Environment and Supporters"),
      style(type='text/css', " .footer { width: 100%; position: fixed; bottom: 0; padding-top: 1em; }")
    )
  })
)

other_page <- fluidPage(
  titlePanel("the Other page says hi!")
)

# Routing
router <- make_router(
  default = route("/", root_page),
  route("/", root_page),
  route("other", other_page)
)

# Server
server <- shinyServer(function(input, output, session) {
  router(input, output, session)

  observeEvent(input$hideTab, {
    hideTab(inputId = "nav", target = "Details")
  }, ignoreNULL = FALSE)

  observeEvent(input$goToDetails, {
    showTab("nav", "Details")
    updateTabsetPanel(session, "nav", "Details")
  })

  observeEvent(input$goToSearch, {
    updateTabsetPanel(session, "nav", "Search")
  })

  observeEvent(input$goToSearchbyAddress, {
    updateTabsetPanel(session, "nav", "Search")
  })

})

# UI
ui <- shinyUI(
  router_ui()
)

shinyApp(ui, server)
