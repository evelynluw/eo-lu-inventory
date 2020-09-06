# Replace app.R with this to test the router. 
# Some quirks: 
# 1. Can't use '/' in the beginning of the route.
# 2. This demo's link is also broken-- have to use '/#!/other' instead.

library(shiny)
#devtools::install_github("Appsilon/shiny.router")
library(shiny.router)

# This generates menu in user interface with links.
menu <- (
  tags$ul(
    tags$li(a(class = "item", href = "/", "Page")),
    tags$li(a(class = "item", href = "/#!/other", "Other"))
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
  route("other", other_page)
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