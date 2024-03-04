ui <- shinydashboard::dashboardPage(
  
  title = "SafeGoOut",
  skin = "red",
  
  #HEADER
  shinydashboard::dashboardHeader(
    title = "How safe am I ?",
    
    # Dropdown menu for messages
    shinydashboard::dropdownMenu(type = "messages", badgeStatus = "success",
                 shinydashboard::messageItem("Dad",
                                             "Tried Calling you, call me back.",
                                             time = "2 hours"
                                 ),
                 shinydashboard::messageItem("SafeGoOut:NoReply",
                             "Location Shared with the police.",
                             time = "5 mins"
                 ),
                 shinydashboard::messageItem("Help",
                             "Can I get some help?",
                             time = "Today"
                 )
    ),
    
    # Dropdown menu for notifications
    shinydashboard::dropdownMenu(type = "notifications", badgeStatus = "warning",
                 shinydashboard::notificationItem(icon = icon("phone"), status = "info",
                                  "Emergency Conctats Added"
                 ),
                 shinydashboard::notificationItem(icon = icon("warning"), status = "danger",
                                  "Detected high crime rate"
                 ),
                 shinydashboard::notificationItem(icon = icon("user", lib = "glyphicon"),
                                  status = "danger", "You changed your username"
                 )
    ),
    
    # Dropdown menu for tasks, with progress bar
    shinydashboard::dropdownMenu(type = "tasks", badgeStatus = "danger",
                 shinydashboard::taskItem(value = 20, color = "aqua",
                          "Add Emergency Contacts"
                 ),
                 shinydashboard::taskItem(value = 60, color = "yellow",
                          "Readme"
                 )
    )
    ),

  #SIDEBAR
  shinydashboard::dashboardSidebar(
    collapsed = FALSE,
    shinydashboard::sidebarUserPanel("",
                     subtitle = a(href = "#", icon("circle", class = "text-success"), "SafeGoOut"),
                     # Image file should be in www/ subdir
                     image = "logo.png"),
    uiOutput("chatbot_link"),
    div(class = "spacing", "or"),
    shinydashboard::sidebarSearchForm(textId = "searchText",
                      buttonId = "searchButton",
                      label = "Enter Postcode"),
    div(class = "spacing", "or"),
    selectInput("force", "Region",
                choices = as.list(
                  setNames(ukpolice::ukc_forces()$id,
                           gsub("Police","", ukpolice::ukc_forces()$name))
                ),
                selected = "south-yorkshire"),
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
    ),
    div(class = "footer", "Source: data.police.uk", br(), "Open Government Licence v3.0.")
  ),
  
  #BODY
  shinydashboard::dashboardBody(
    includeCSS("www/style.css"),
    fluidPage(
      fluidRow(
      column(
      4,
      shinydashboard::box(
        h2("Safety Map"),
        div(class = "subheading",
            "Interactive and focused on your safety"),
        p("Discover your region of interest with our interactive safety focussed UK crime map. We've compiled data from records spanning all police forces in the UK, offering localized insights into public safety concerns at the street level"),
        background = "light-blue",
        solidHeader = TRUE,
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
        background = "light-blue",
        solidHeader = FALSE,
        width = "100%",
        fluidRow(
          column( 4,
                  uiOutput("region"),
                  div(class = "subheading",
                      textOutput("neighbourhood_name")),
                  p("Crime hotspots, charts, tables and analysis, tailored to each neighbourhood to uncover crime trends in England"),
                  ),
          column(
            8,
            shinydashboard::box(
              h3("Immediate Assistance", style="color:#e60082"),
              background = "maroon",
              solidHeader = TRUE,
              width = "100%",
              fluidRow(
                column(5,
                       # create a button to send localisation to the police
                       actionButton("send_location", "Send location to police", icon = icon("map-marker"))
                       ),
                column(2, 
                       # create a button to call the police 
                       actionButton("call_police", "Call police", icon = icon("phone"))
                       ),
                column(2,
                       offset = 1,
                       # create a button to message my emergency contacts
                       actionButton("message_contacts", "Message My Contacts", icon = icon("envelope"))
                       )
                )
              ),
            fluidRow(
              column(6, 
                     bslib::value_box(
                       value = textOutput("most_common_crime"),
                       title = "Most common crime",
                       theme_color = "info",
                       #height = "70px",
                       #max_height = "80px",
                       showcase = bsicons::bs_icon("exclamation-triangle")
                     )
                     ),
                column(6,
                       bslib::value_box(
                         value = textOutput("crime_number"),
                         title = "Total number of crimes",
                         theme_color = "success",
                         #height = "70px",
                         #max_height = "70px",
                         showcase = bsicons::bs_icon("bar-chart")
                       ) 
                       ))
            )
            
          ),
        br(),
        shinydashboard::tabBox(
          #title = "Crime Analysis",
          id = "crime_analysis",
          width = "100%",
          height = "100%",
          tabPanel("Crime Statistics",
                   fluidRow(
                     column(5,
                            #plotly::plotlyOutput("crimes_resolution", height = 200)),
                            plotly::plotlyOutput("crimes_resolution", height = "300px")),
                     column(7,
                            #plotly::plotlyOutput("crimes_per_date", height = 200))
                            plotly::plotlyOutput("type_of_crimes", height = "300px"))
                   ),
                   #br(),
                   fluidRow(column(
                     12,
                     #plotly::plotlyOutput("type_of_crimes", height = 300)
                     plotly::plotlyOutput("crimes_per_date", height = "300px")
                     
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
                            downloadButton("downloadContact", "Download Contact", icon = icon("download"))
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
                   
          ),
          
          tabPanel("My relatives",
                   # create input to enter relative name
                   textInput("relative_name", "Relative name"),
                   # create input to add relationship
                   textInput("relative_relationship", "Relationship"),
                   # create input to enter contact value
                   textInput("relative_number", "Number"),
                   # create button to add contact
                   actionButton("add_contact", "Add contact"),
                   # create table to display contacts and also remove them
                   br(),
                   br(),
                   DT::dataTableOutput("contacts_table"),
                   br(),
                   #add a text input for the message to send to my relatives
                   textAreaInput("message", "Message to send to my relatives",
                                 value = "I don't feel safe, call me..." ),
                   # create a button to message my emergency contacts
                   actionButton("tweet_msg", "Tweet Here", icon = icon("twitter"))
                
          ),
          
          tabPanel("Tips",
          # display list of tips to stay safe
          a("1.Ask for Angela in hospitality venues"),
          br(),
          a("2. Ask for ANI (which stands for 'action needed immediately') in a trained pharmacy "),
          br(),
          a("3. Put your palm up, tuck your thumb in, and close your fingers."),
                   ),
          
          tabPanel("Check my drink",
                   # create an image output to display the image of the drink
                   column(12,
                          imageOutput("drink_picture", height = "20%"),
                   #img(src = "drink.png", height = 200, width = 500),
                   br(),
                   # display an action button with camera icon to take a picture of the drink
                   actionButton("take_picture", "Capture", icon = icon("camera")),
                   align = "center"
                   ),
                   # display the result of the drink analysis
                   #display the result of the drink analysis in a box
                   br(),
                   h6(""),
                   # click a button to analyse the drink
                   actionButton("analyse_drink", "Analyse drink"),
                   # create a box to give advice on the drink
                   h6(""),
                   fluidRow(
                     column(6,
                       shinydashboard::box(
                         h2("Look out !", icon("lightbulb", class="fas fa-lightbulb")),
                         background = "light-blue",
                         #solidHeader = TRUE,
                         width = "100%",
                         # create a bullet list of advice
                         tags$div(
                           tags$ul(
                             tags$li("The color of your drink has changed")
                           )
                         ),
                         tags$div(
                           tags$ul(
                             tags$li("Your drink looks cloudy")
                           )
                         ),
                         tags$div(
                           tags$ul(
                             tags$li("Your drink has excessive bubbles")
                           )
                         ),
                         tags$div(
                           tags$ul(
                             tags$li("Your drink tastes a bitter or salty")
                           )
                         )
                       )
                     )
                   )
                   # create a list of tips to stay safe in a box
                   
                   
                   )
          
        )
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
