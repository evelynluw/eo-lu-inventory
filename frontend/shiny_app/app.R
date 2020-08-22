# # UI definition for shiny

# library(shiny)
# library(leaflet)
# library(RColorBrewer)
# library(sf)
# library(tidyverse)
# library(readxl)
# library(googleway)
# library(shinydashboard)
# library(shiny.router)
# # library(bootstraplib) 

# # Pages

# # root_page <- navbarPage(
# #   title = "East Oakland Facility Inventory",
# #   fluid = TRUE,
# #   collapsible = TRUE,
# #   theme = "flatly.min.css",
# #   tabPanel("Plot"),
# #   tabPanel("Summary"),
# #   tabPanel("Table")
# # )

# root_page <- fluidPage(
#   titlePanel("Hello world!")
# )

# other_page <- fluidPage(
#   titlePanel("Another Hello world!")
# )

# # Routing
# router <- make_router(
#   default = route("/", root_page),
#   route("/", root_page),
#   route("/other", other_page)
# )

# # Server
# server <- shinyServer(function(input, output, session) {
#   router(input, output)
# })

# # UI
# ui <- shinyUI(
#   router_ui()
# )

# shinyApp(ui, server)


library(shiny)
#devtools::install_github("Appsilon/shiny.router")
library(shiny.router)

# This generates menu in user interface with links.
menu <- (
  tags$ul(
    tags$li(a(class = "item", href = "/", "Page")),
    tags$li(a(class = "item", href = "/other", "Other"))
  )
)

# This creates UI for each page.
page <- function(title, content) {
  div(
    menu,
    titlePanel(title),
    p(content)
  )
}

# Both sample pages.
root_page <- page("Home page", "Welcome on sample routing page!")
other_page <- page("Some other page", "Lorem ipsum dolor sit amet")

# Creates router. We provide routing path and UI for this page.
router <- make_router(
  route("/", root_page),
  route("/other", other_page)
)

# Creat output for our router in main UI of Shiny app.
ui <- shinyUI(fluidPage(
  router_ui()
))

# Plug router into Shiny server.
server <- shinyServer(function(input, output) {
  router(input, output)
})

# Run server in a standard way.
shinyApp(ui, server)