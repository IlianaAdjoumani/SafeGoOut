server <- function(input, output) {

  thematic::thematic_shiny()
  
  observe({
    updateSelectInput(inputId = "neighbourhood",
                      choices = as.list(
                        setNames(
                          ukpolice::ukc_neighbourhoods(input$force)$id,
                          ukpolice::ukc_neighbourhoods(input$force)$name
                        )
                      ))
  })
  
  crime_data <- reactive({
    get_crime_data(input$force, 
                   date = input$date,)
  })
  
  graph_data <- reactive({
    get_graph_data(input$force,
                   date = input$date)
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
  
  observeEvent(input$neighbourhood,
               {
                 street_crime <-  get_street_crime(input$force, input$neighbourhood)
                 
                 output$map <- leaflet::renderLeaflet({
                   if (!is.null(street_crime) | !nrow(street_crime == 0)) {
                     map <- street_crime_summary_map(street_crime)
                   }
                   map
                 })
                 
                 output$heat_map <- leaflet::renderLeaflet({
                   if (!is.null(street_crime) | !nrow(street_crime == 0)) {
                     map <- street_crime_heat_map(street_crime)
                   }
                   map
                 })
                 
                 output$region <- renderUI({
                   h2(forces$name[forces$id == input$force])
                 })
                 
                 output$neighbourhood <- renderUI({
                   h4(input$neighbourhood)
                 })
                 
                 
               },
               ignoreNULL = TRUE,
               ignoreInit = TRUE)
  
  
  # output$officer_number <- renderText({
  #   data <- get_officer_data(input$force, input$neighbourhood)
  #   nrow(data)
  # })
}