ui <- shinydashboard::dashboardPage(
  
  title = "SafeGoOut",
  skin = "red",
  
  #HEADER
  shinydashboard::dashboardHeader(
    title = "How safe am I ?"
    ),

  #SIDEBAR
  shinydashboard::dashboardSidebar(
    collapsed = FALSE,
    shinydashboard::sidebarUserPanel("",
                     subtitle = a(href = "#", icon("circle", class = "text-success"), "SafeGoOut"),
                     # Image file should be in www/ subdir
                     image = "logo.png"),
    shinydashboard::sidebarSearchForm(textId = "searchText",
                      buttonId = "searchButton",
                      label = "Enter Postcode"),
    div(class = "spacing", "or"),
    selectInput("force", "Force",
                choices = as.list(
                  setNames(ukpolice::ukc_forces()$id,
                           ukpolice::ukc_forces()$name)
                )),
    selectInput("neighbourhood", "Neighbourhood",
                choices = NULL),
    
    shinyWidgets::airDatepickerInput("date",
                       label = "Start month",
                       value = find_available_dates()$max,
                       maxDate = find_available_dates()$max,
                       minDate = find_available_dates()$min,
                       view = "months", # editing what the popup calendar shows when it opens
                       minView = "months", # shortest period visible is month not day
                       dateFormat = "yyyy-MM"
    )
    
  ),
  
  #BODY
  shinydashboard::dashboardBody(
    
    includeCSS("www/style.css"),
    fluidPage(
      fluidRow(
      column(
      4,
      shinydashboard::box(
        h2("Interactive Crime Map"),
        p("Discover your region of interest with our interactive UK crime map. We've compiled data from records spanning all police forces in the UK, offering localized insights into public safety concerns at the street level"),
        background = "light-blue",
        solidHeader = TRUE,
        height = 800,
        width = "100%",
        leaflet::leafletOutput("map", height = 600)
      )
    ),
    column(
      8,
      #
      # textOutput("officer_number"),
      # br(),
      # br(),
      #
      shinydashboard::box(
        uiOutput("region"),
        #uiOutput("neighbourhood"),
        h4("Sheffield City Centre"),
        p("Crime hotspots, maps, charts, data tables and analysis, customised to each neighbourhood to uncover crime trends in England"),
        background = "light-blue",
        solidHeader = FALSE,
        height = 800,
        width = "100%",
        fluidRow(column(
          6,
          bslib::value_box(
            value = textOutput("most_common_crime"),
            title = "Most common crime",
            theme_color = "info",
            max_height = "75px",
            showcase = bsicons::bs_icon("exclamation-triangle")
          ),
        ),
        column(
          6,
          bslib::value_box(
            value = textOutput("crime_number"),
            title = "Total number of crimes",
            theme_color = "success",
            max_height = "75px",
            showcase = bsicons::bs_icon("bar-chart")
          )
        )),
        br(),
        shinydashboard::tabBox(
          #title = "Crime Analysis",
          id = "crime_analysis",
          width = "100%",
          tabPanel("Crime Statistics",
                   fluidRow(
                     column(5,
                            plotly::plotlyOutput("crimes_resolution", height = 200)),
                     column(7,
                            plotly::plotlyOutput("crimes_per_date", height = 200))
                   ),
                   br(),
                   fluidRow(column(
                     10,
                     plotly::plotlyOutput("type_of_crimes", height = 300)
                   ))),
          tabPanel("Emergency Contacts",
                   # Dynamic infoBoxes
                   fluidRow(
                     column(6,
                            div(class = 'contactinfo',
                                h5("In case of emergency, dial 999, For non-emergencies, dial 101"),
                            )),
                     column(4,
                            align = 'right',
                            actionButton("downloadContact", "Download Contact", icon = icon("download"))
                     )
                   ),
                   br(),
                   fluidRow(
                     column(10, shinydashboard::infoBoxOutput("contactBox", width = 10))
                   ),
                   fluidRow(
                     column(10,shinydashboard::infoBoxOutput("emailBox", width = 10))
                   ),
                   fluidRow(
                     column(10,shinydashboard::infoBoxOutput("facebookBox", width = 10))
                   ),
                   fluidRow(
                     column(10,shinydashboard::infoBoxOutput("twitterBox", width = 10))
                   ),
                   fluidRow(
                     column(10,shinydashboard::infoBoxOutput("youtubeBox", width = 10))
                   )
                   # h4("Police"),
                   # p("In case of emergency, dial 999"),
                   # p("For non-emergencies, dial 101"),
                   # p("To report a crime, dial 0800 555 111"),
                   # p("To report a crime anonymously, dial 0800 555 111"),
                   # p("To report a crime online, visit www.police.uk")
                   
          ))
        #br()
        # fluidRow(
        #   column(1, uiOutput("facebook")),
        #   column(1, uiOutput("twitter"))
        # )
      )
    ))
    )
  )
)
