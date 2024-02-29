server <- function(input, output) {

  thematic::thematic_shiny()
  
  observeEvent(input$force,{
    if(is.null(latitude)){
      updateSelectInput(inputId = "neighbourhood",
                        choices = as.list(
                          setNames(
                            ukpolice::ukc_neighbourhoods(input$force)$id,
                            ukpolice::ukc_neighbourhoods(input$force)$name
                          )
                        ))
    }
   
  })
  
  crime_data <- eventReactive(list(input$force, input$date, input$searchButton), {
    get_crime_data(input$force, 
                   date = input$date,
                   latitude = latitude,
                   longitude = longitude)
  })
  
  graph_data <- eventReactive(list(input$force, input$date, input$searchButton), {
    get_graph_data(input$force,
                   date = input$date,
                   latitude = latitude,
                   longitude = longitude)
  })
  
  
  output$crime_number <- renderText({
    crime_number(crime_data())
  })
  

  output$facebook <- renderUI({
    shinydashboardPlus::socialButton(
      href = "https://dropbox.com",
      icon = icon("facebook")
    )
  })
  
  output$twitter <- renderUI({
    shinydashboardPlus::socialButton(
      href = "https://github.com",
      icon = icon("twitter")
    )
  })
  
  output$most_common_crime <- renderText({
    if (is.null(crime_data()) | nrow(crime_data()) == 0) {
      crime_name <- "No data available"
    } else {
      crime_name <- most_common_crime(crime_data())
    }
    
    crime_name
  })
  
  output$crimes_per_date <- plotly::renderPlotly({
    if (is.null(graph_data()) | nrow(graph_data()) == 0) {
      plot <- empty_plot("No data available")
    } else {
      plot <- number_of_crimes_per_date_graph(graph_data())
    }
    
    plot
    
  })
  
  output$type_of_crimes <- plotly::renderPlotly({
    if (is.null(crime_data()) | nrow(crime_data()) == 0) {
      plot <- empty_plot("No data available")
    } else {
      plot <- type_of_crime_graph(crime_data())
    }
    
    plot
    
  })
  
  output$crimes_resolution <- plotly::renderPlotly({
    
    if (is.null(graph_data()) | nrow(graph_data()) == 0) {
      plot <- empty_plot("No data available")
    } else {
      plot <- crime_resolution_graph_plotly(graph_data())
    }
    
    plot
    
  })
  
  
 #Search by postcode
  observeEvent(input$searchButton, {
    
    #Get the lat and lng of the postcode
    postcode_info <- tmaptools::geocode_OSM(input$searchText)
    
    latitude <<- postcode_info$coords[['y']]
    longitude <<- postcode_info$coords[['x']]
    
    #Identify the neighbourhood name from the co-ordinates
    postcode_neighbourhood <-
      ukpolice::ukc_neighbourhood_location(lat = latitude , 
                                           lng = longitude)
    
    #Identify the force name and neighbourhood name
    force <- postcode_neighbourhood$force
    neighbourhood <- postcode_neighbourhood$neighbourhood
    
    #update the filters with the selected force 
    updateSelectInput(session = getDefaultReactiveDomain(),
                      inputId = "force",
                      selected = force)
    
    #Get the neighbourhoods for the selected force
    all_neighbourhood <- get_neighbourhoods(force)
    
    #Get the selected neighbourhood
    selected_neighbourhood <-  all_neighbourhood %>%
      filter(id == neighbourhood)
    
    #update the neighbourhood filter
    updateSelectInput(
      session = getDefaultReactiveDomain(),
      inputId = "neighbourhood",
      choices = as.list(setNames(
        all_neighbourhood$id,
        all_neighbourhood$name
      )),
      selected = as.list(
        setNames(selected_neighbourhood$id,
                 selected_neighbourhood$name)
      )
    )
    
  })
  
  observeEvent(c(input$neighbourhood, input$date),
               {

                 # #Street crime data
                 street_crime <-  get_street_crime(input$force, input$neighbourhood, input$date, latitude, longitude)
                 
                 #Police force contact information
                 police_force_contact <- get_police_contact(input$force)
                 neighbourhood_contact <- get_neighbourhood_contact(input$force, input$neighbourhood)
                 
                 if (!is.null(police_force_contact) | nrow(police_force_contact) > 0) {
                   facebook_url <- police_force_contact$url[grep('facebook', police_force_contact$title, ignore.case = TRUE)]
                   twitter_url <- police_force_contact$url[grep('twitter', police_force_contact$title, ignore.case = TRUE)]
                   youtube_url <- police_force_contact$url[grep('youtube', police_force_contact$title, ignore.case = TRUE)]
                   flickr_url <- police_force_contact$url[grep('flickr', police_force_contact$title, ignore.case = TRUE)]
                 }
                 
                 if(!is.null(neighbourhood_contact) | nrow(neighbourhood_contact) > 0){
                   email <- neighbourhood_contact$Value[neighbourhood_contact$Contact == "email"]
                   telephone <- neighbourhood_contact$Value[neighbourhood_contact$Contact == "telephone"]
                   n_twitter <- neighbourhood_contact$Value[neighbourhood_contact$Contact == "twitter"]
                   n_facebook <- neighbourhood_contact$Value[neighbourhood_contact$Contact == "facebook"]
                 }
                 
                 output$map <- leaflet::renderLeaflet({
                   if (!is.null(street_crime) | nrow(street_crime > 0)) {
                     map <- street_crime_summary_map(street_crime)
                   }
                   map
                 })
                 
                 # output$heat_map <- leaflet::renderLeaflet({
                 #   if (!is.null(street_crime) | nrow(street_crime > 0)) {
                 #     map <- street_crime_heat_map(street_crime)
                 #   }
                 #   map
                 # })
                 # 
                 output$region <- renderUI({
                   h2(forces$name[forces$id == input$force])
                 })
                 
                 output$neighbourhood <- renderUI({
                   h4(input$neighbourhood)
                 })
                 
                 if(length(telephone) > 0) {
                   if(!telephone == "101"){
                     output$contactBox <- shinydashboard::renderInfoBox({
                       shinydashboard::infoBox(
                         "Telephone", 
                         value = div( p(strong("Neighbourhood "), telephone)),
                         icon = icon("phone"),
                         color = "light-blue",
                         fill = TRUE
                       )
                     })
                   }
                   
                 }
                 
                 if(length(email) > 0 ) {
                   output$emailBox <- shinydashboard::renderInfoBox({
                     shinydashboard::infoBox(
                       "Email", 
                       value = div( p(strong("Neighbourhood "), email)),
                       icon = icon("envelope"),
                       color = "light-blue",
                       fill = TRUE
                     )
                   })
                 }
                 
                 
                 #if facebook url is not empty or null render the facebook info box
                 if (!is.null(facebook_url) | length(n_facebook) > 0 ) {
                   output$facebookBox <- shinydashboard::renderInfoBox({
                     shinydashboard::infoBox(
                       "Facebook", 
                       value = div( p(strong("Police "), facebook_url),
                                    p(strong("Neighbourhood "), n_facebook)
                       ), 
                       icon = icon("facebook"),
                       color = "light-blue",
                       fill = TRUE
                     )
                   })
                 }
                 
                 if(!is.null(twitter_url) | length(n_twitter) > 0 ) {
                   output$twitterBox <- shinydashboard::renderInfoBox({
                     shinydashboard::infoBox(
                       "Twitter", 
                       value = div( p(strong("Police "), twitter_url),
                                    p(strong("Neighbourhood "), n_twitter)
                       ), 
                       icon = icon("twitter"),
                       color = "light-blue",
                       fill = TRUE
                     )
                   })
                 }
                 
                 if(!is.null(youtube_url)) {
                   output$youtubeBox <- shinydashboard::renderInfoBox({
                     shinydashboard::infoBox(
                       "Youtube", 
                       value = div( p(strong("Police "), youtube_url)),
                       icon = icon("youtube"),
                       color = "light-blue",
                       fill = TRUE
                     )
                   })
                 }
                 
                 latitude <<- NULL
                 longitude <<- NULL
                 
               },
               ignoreNULL = TRUE,
               ignoreInit = TRUE)
  
  # create a modal to ask the user if is sure to send location to the police
  observeEvent(input$send_location, {
    showModal(modalDialog(
      title = "Send location to the police",
      "Are you sure ?",
      footer = tagList(
        modalButton("Cancel"),
        modalButton("Yes")
      )
    ))
  })
  
  # create a modal to ask the user if is sure to call the police
  observeEvent(input$call_police, {
    showModal(modalDialog(
      title = "Call the police",
      "Are you sure ?",
      footer = tagList(
        modalButton("Cancel"),
        modalButton("Yes")
      )
    ))
  })
  
  # create a modal to ask the user if is sure to message the emergency contacts
  observeEvent(input$message_contacts, {
    showModal(modalDialog(
      title = "Message my emergency contacts",
      "Are you sure ?",
      footer = tagList(
        modalButton("Cancel"),
        modalButton("Yes")
      )
    ))
  })
  
  # create a reactive to store the contacts added by the user
  my_relatives <- reactiveVal(data.frame(
    Name = character(),
    Phone = character(),
    Relationship = character()
  ))
  
  # update the my relatives reactivValue with the contacts added by the user when
  # the add contact button is used
  
  observeEvent(input$add_contact, {
    
    my_relatives(rbind(my_relatives(), 
                          data.frame(
                            Name = input$relative_name,
                            Phone = input$relative_number,
                            Relationship = input$relative_relationship
                          )))
  })
  
  
  output$contacts_table <- DT::renderDataTable({
    # display each contact added by the user
    # make sure we can delete rows
    
    DT::datatable(my_relatives()
    )


  })
  
  
  
  # output$officer_number <- renderText({
  #   data <- get_officer_data(input$force, input$neighbourhood)
  #   nrow(data)
  # })
}