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
