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
# bootstrap("cosmo"),
  title = "East Oakland Facility Inventory",
  id = "nav",
  fluid = TRUE,
  collapsible = TRUE,
  theme = "flatly.min.css",
  selected = "Home",
  tags$link(rel = "stylesheet", href = "https://unpkg.com/tachyons@4.12.0/css/tachyons.min.css"),
  tabPanel("Home",
    withTags({
      div(class = "center w-60-ns",
        h1("Welcome to the East Oakland Land Use Inventory"),
        p("Use this page to research a facility in East Oakland."),
        p("Select an option below to get started."),
        div(class = "flex justify-between container-fluid mv4",
          actionButton(class = "btn-lg btn-success w-50 ws-normal mr2", "goToSearchbyAddress", "I have a facility I want to research by address"),
          actionButton(class = "btn-lg btn-success w-50 ws-normal ml2", "goToSearchbyNeighborhood", "I want to explore facilities by neighborhood"),
        )
      )
    })
  ),
  tabPanel("Search",
    actionButton("hideTab", "Hide 'Details' tab"),
    actionButton("goToDetails", "Go to 'Details' tab")
  ),
  tabPanel("Details",
    titlePanel("Details page"),
    actionButton("backToSearchbyAddress", "Back")
  ),
  tabPanel("Glossary"),
  tabPanel("About",
    withTags({
      div(class = "center w-60-ns",
        div(class = "row",
          img(class = "col-xs-2 mv4 pr0", src="https://s3.amazonaws.com/onepercent-production-member-logos/communities-for-a-better-environment/1568175015594.jpeg"),
          h1(class = "col-xs-10", "About Communities for a Better Environment")
        ),
        p("Communities for a Better Environment is a grassroots environmental justice organization that works in four communities across CA, including East Oakland."),
        p("This website is intended to be a resource for East Oakland community members to better understand nearby facilities and their impacts."),
        p("Learn more at: ", a("http://www.cbecal.org/", href = "http://www.cbecal.org/"))
      )
    })
  ),
  tabPanel("FAQ",
    withTags({
      div(class = "center w-60-ns",
        div(class = "row",
          img(class = "col-xs-2 mv4 pr0", src="https://s3.amazonaws.com/onepercent-production-member-logos/communities-for-a-better-environment/1568175015594.jpeg"),
          h1(class = "col-xs-10", "How Can I Get Involved?")
        ),
        p("Communities for a Better Environment is a grassroots environmental justice organization that works in four communities across CA, including East Oakland. We’re always looking for more passionate people to join our effort towards a cleaner, healthier, and more just world. Reach out to one of our organizers to get involved:"),
        p("Angela", br(), "Cindy"),
        p("Not ready to jump in yet? That’s okay, there’s a number of other ways to help out...")
      )
    })
  ),
  footer = withTags({
    div(class = "bg-primary w-100 fixed bottom-0 pv3",
      div(class = "row",
        div(class = "col-md-2 tc tl-l",
          a(class = "btn btn-info btn-sm ml4-l", href = "http://www.cbecal.org/", "Contact Us")
        ),
        div(class = "col-md-10 tc tr-l pr5-ns mt2",
          p(class = "text-white", "Maintained by Communities for a Better Environment and Supporters")
        )
      )
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
  route("other", other_page),
  route("search", root_page),
  route("details", root_page)
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

  observeEvent(input$backToSearchbyAddress, {
    updateTabsetPanel(session, "nav", "Search")
    hideTab(inputId = "nav", target = "Details")
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
