# UI definition for shiny
# Edited by Evelyn Lu on 08/20/2020

library(shiny)
library(leaflet)
library(RColorBrewer)
library(sf)
library(tidyverse)
library(readxl)
library(googleway)
library(shinydashboard)
library(shiny.router)
library(bootstraplib)

# Create pages

home_page <- fluidPage(
  withTags({
  div(class = "center w-60-ns",
    h1("Welcome to the East Oakland Land Use Inventory"),
    p("Use this page to research a facility in East Oakland."),
    p("Select an option below to get started."),
    div(class = "flex justify-between container-fluid mv4",
      tags$a(class = "btn btn-lg btn-dark w-50 ws-normal mr2", href = "/#!/search", "I have a facility I want to research by address"),
      tags$a(class = "btn btn-lg btn-dark w-50 ws-normal ml2", href = "/#!/search", "I want to explore facilities by neighborhood"),
    )
  )
  })
)

search_page <- fluidPage(
  tags$a(class = "btn btn-default", href = "/#!/details", "Go to details"),
  tags$p("
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas bibendum tincidunt consequat. Nunc tortor nulla, ornare vitae dictum eu, vestibulum et quam. Morbi sagittis nisi ac neque elementum accumsan. Vestibulum nec justo ut urna viverra malesuada. Nam sem ipsum, suscipit efficitur congue ut, efficitur sed erat. Pellentesque gravida lectus at velit cursus dignissim. Aliquam maximus nisl nec tellus consequat pellentesque. Pellentesque malesuada ipsum eget sollicitudin imperdiet. Quisque egestas fringilla tempus. Vestibulum dignissim risus sed imperdiet placerat. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Quisque in magna faucibus dolor fermentum aliquam. Nunc diam ipsum, vulputate eget egestas ac, volutpat quis dui. Donec pulvinar facilisis est eget dictum.
    Praesent sollicitudin venenatis magna, eget aliquet dolor vestibulum vel. Suspendisse mattis rhoncus libero, ac molestie turpis vehicula in. Suspendisse malesuada eu urna in congue. Integer vitae diam sit amet libero vestibulum molestie. Praesent vel imperdiet sem. Nunc at maximus arcu. Nullam in tellus nulla. Etiam porttitor molestie pretium. Morbi at facilisis nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Etiam id accumsan augue. Mauris suscipit quis tellus quis fringilla. Duis vel vulputate ante, non iaculis nunc. Aenean molestie libero at odio aliquam aliquet.
    Mauris pulvinar lacus felis, eget efficitur enim venenatis eget. Aliquam magna massa, rhoncus vitae ornare ornare, posuere in felis. Sed ullamcorper, mi quis sollicitudin euismod, magna mi ullamcorper sapien, eget suscipit arcu erat ac erat. Aliquam erat volutpat. Cras maximus ante sed tempor sodales. Maecenas pellentesque nisl sit amet purus tincidunt, vitae congue neque ornare. Pellentesque id mollis risus. Vestibulum sed erat eget sem malesuada imperdiet. Suspendisse quis iaculis lectus. Donec condimentum molestie odio eu mattis. Ut accumsan nulla imperdiet dictum tincidunt. Cras ac odio a turpis ultricies ornare at vel nunc. Etiam fermentum turpis interdum dui sodales, et molestie erat pharetra.
    Phasellus id nisi suscipit, fermentum nisl nec, aliquet nunc. Proin justo nisl, rhoncus rhoncus finibus sit amet, feugiat ac turpis. Donec ut pretium elit, vitae lobortis leo. Nam nec enim molestie, tempor odio varius, viverra massa. Nullam gravida luctus ex, eget tincidunt magna faucibus quis. Proin id lorem vulputate, consequat velit ac, varius arcu. Suspendisse potenti. Morbi dapibus nisi non mi pulvinar, eget maximus justo rhoncus. Nulla arcu tellus, porta ac diam feugiat, tincidunt volutpat quam. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Praesent tincidunt neque vel dolor interdum, eget facilisis nisi ullamcorper. Morbi et eros et nisl sodales semper eu non odio. Quisque finibus eros nunc, et molestie sapien blandit hendrerit.
    Nulla ultrices viverra purus, sit amet tincidunt lorem euismod ac. Sed at velit finibus, volutpat lacus eget, dignissim turpis. Nam tempus iaculis ex, id faucibus turpis volutpat quis. Donec vulputate ipsum convallis, convallis leo pretium, hendrerit erat. Morbi consequat dui eu nisi vestibulum, vitae volutpat velit sagittis. Mauris efficitur id est id accumsan. Nam et urna arcu.
    Ut euismod placerat felis at imperdiet. Praesent tristique, nulla non lacinia scelerisque, odio lectus fringilla tellus, eget eleifend quam odio vitae libero. Donec faucibus est et nisl tincidunt, euismod tempus ante bibendum. Fusce vehicula et diam quis rutrum. Nulla luctus nulla id tortor vulputate, non dictum metus volutpat. Praesent ultrices efficitur sapien non ultricies. Donec ullamcorper tincidunt justo, ultricies aliquet ex maximus at. Donec faucibus feugiat nisl, tincidunt suscipit justo commodo vel. Integer porta mi eu ullamcorper euismod. Aenean ornare, magna ut dictum hendrerit, ex arcu congue sem, non interdum lectus eros vel turpis. Phasellus imperdiet nisi orci, vitae iaculis elit porta at. Nam fermentum est sit amet suscipit pretium.
    Nulla porttitor odio eu est dapibus, eget auctor massa eleifend. Etiam cursus eros mauris. Nulla vitae orci at nisl convallis gravida eget eget dolor. Mauris dignissim metus vel fermentum pulvinar. Phasellus sit amet vulputate leo, eu fringilla mauris. Cras mattis facilisis nisi, ut dictum erat sollicitudin sit amet. Sed luctus enim sed justo rutrum, id posuere diam elementum. Integer condimentum odio ac purus bibendum scelerisque. Nullam a convallis erat, a lobortis lorem. Interdum et malesuada fames ac ante ipsum primis in faucibus. Sed dictum luctus diam sit amet pellentesque. Maecenas porttitor pharetra faucibus. Sed vitae ligula non magna fermentum iaculis. Curabitur ut iaculis nisi. Integer dapibus nisi eu congue fringilla. Fusce aliquam, tortor sagittis tincidunt porta, ipsum massa bibendum nulla, at egestas diam diam a mauris.
    Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Etiam vel lectus mauris. Sed egestas sollicitudin facilisis. Phasellus vel massa in odio cursus pretium. Nulla congue justo in velit ullamcorper ornare. Pellentesque sodales odio ut purus scelerisque ultricies quis consequat nisi. Vivamus viverra nibh eu augue luctus, vitae porttitor nunc finibus. Vivamus venenatis, nisl vitae lacinia fringilla, leo massa scelerisque metus, et tincidunt diam eros vitae dolor. Cras ac tellus sed lectus tempus feugiat id et leo.
    Etiam vulputate arcu a mauris sodales, quis semper felis vulputate. Vivamus lacinia libero ullamcorper rutrum lobortis. Quisque lobortis mauris non vestibulum luctus. In feugiat bibendum nulla sed porta. Fusce consectetur tincidunt dictum. Fusce urna justo, posuere sit amet arcu quis, condimentum luctus libero. Nulla ultrices suscipit turpis vel consectetur. Proin viverra in diam nec pulvinar. Vivamus nulla elit, ornare non accumsan et, tempus vitae libero. In a dui eget lorem efficitur scelerisque. Suspendisse potenti. Praesent sagittis, nibh nec pellentesque semper, augue quam tristique leo, finibus tincidunt leo leo ut orci. Nam et dictum est, et pulvinar nulla. Aenean mattis lacus dolor, sit amet consectetur tortor eleifend ut.
    Cras lectus elit, viverra in lobortis nec, iaculis id est. Aenean bibendum purus ut bibendum dictum. Sed eu leo cursus, consectetur lectus nec, dapibus enim. Nam vitae posuere nulla, at lobortis sem. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque velit quam, efficitur vitae hendrerit rhoncus, accumsan vitae orci. Lorem ipsum dolor sit amet, consectetur adipiscing elit.
  ")
)

details_page <- fluidPage(
  tags$a(class = "btn btn-default", href = "/#!/search", "Back to search")
)

about_page <- fluidPage(
  withTags({
  div(class = "center w-60-ns",
    div(class = "row align-items-center mx-0",
      div(class = "col-2 px-0",
        img(class = "w-100", src="assets/cbe_logo.jpeg"),
      ),
      div(class = "col-10",
        h1(class = "ws-normal", "About Communities for a Better Environment")
      ),
    ),
    p("Communities for a Better Environment is a grassroots environmental justice organization that works in four communities across CA, including East Oakland."),
    p("This website is intended to be a resource for East Oakland community members to better understand nearby facilities and their impacts."),
    p("Learn more at: ", a("http://www.cbecal.org/", href = "http://www.cbecal.org/"))
  )
  })
)

faq_page <- fluidPage(
  withTags({
  div(class = "center w-60-ns",
    div(class = "row align-items-center mx-0",
      div(class = "col-2 px-0",
        img(class = "w-100", src="assets/cbe_logo.jpeg"),
      ),
      div(class = "col-10",
        h1(class = "ws-normal", "How Can I Get Involved?")
      ),
    ),
    p("Communities for a Better Environment is a grassroots environmental justice organization that works in four communities across CA, including East Oakland. We’re always looking for more passionate people to join our effort towards a cleaner, healthier, and more just world. Reach out to one of our organizers to get involved:"),
    p("Angela", br(), "Cindy"),
    p("Not ready to jump in yet? That’s okay, there’s a number of other ways to help out...")
  )
  })
)

# Footer

footerbar <- withTags({
  div(class = "bg-primary w-100 pv3",
    div(class = "row align-items-center w-100 px-2 mx-0",
      div(class = "col-md-2 text-center text-md-left p-0",
        a(class = "btn btn-outline-light btn-sm ml-md-3 dib", href = "http://www.cbecal.org/", "Contact Us")
      ),
      div(class = "col-md-10 text-center text-md-right p-0",
        p(class = "text-white mb0 mt2 mt0-ns mr3-ns", "Maintained by Communities for a Better Environment and Supporters")
      )
    )
  )
})

# Routing

router <- make_router(
  default = route("/", home_page),
  route("/", home_page),
  route("search", search_page),
  route("details", details_page),
  route("about", about_page),
  route("faq", faq_page)
)

# Server

server <- shinyServer(function(input, output, session) {
  router(input, output, session)

})

# UI

bs_theme_new(bootswatch = "cosmo")
bs_theme_add_variables(
  "font-size-base" = "1.1rem",
)

ui <- shinyUI(
  fluidPage(class = "p-0 m-0 h-100",
    bootstrap(),
    tags$link(rel = "stylesheet", href = "https://unpkg.com/tachyons@4.12.0/css/tachyons.min.css"),
    # Insert <meta> for responsiveness
    tags$script(HTML("$('head').append('<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, shrink-to-fit=no\">');")),
    tags$style("html, body { height: 100%; }"),
    tags$div(class = "wrapper d-flex flex-column h-100",
      tags$div(class = "content flex-grow-1 flex-shrink-0",
        includeHTML("navbar.html"),
        router_ui()
      ),
      tags$div(class = "footer-box flex-shrink-0",
        footerbar
      ),
    )
  )
)

shinyApp(ui, server)