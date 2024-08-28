source("signup.R")
source("vacationRegister.R")
source("vacationEdit.R")
source("home.R")
shiny::fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", href = "https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css"),
    tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.2.0/css/all.min.css")
  ),
  
  navbarPage(
    id = "tabs", 
    "SNUBH DCT",
    header = div(class = "pull-right", shinyauthr::logoutUI(id = "logout")),
    tabPanel("Home",
      icon = icon("home"),
      homeUI("home"),
      shinyauthr::loginUI(id = "login", additional_ui = actionButton("signup_btn", "Sign Up")), 
    ),
    # uiOutput("vac_tabs"),
    tabPanel("휴가 등록",  
      div(
        vacRegUI("vac_reg"),
        br(),
        calendarUI("vac_cal")),

      ),
    tabPanel("휴가 변경", 
      vacEditUI("vac_edit")
    ),
    
  ),

)