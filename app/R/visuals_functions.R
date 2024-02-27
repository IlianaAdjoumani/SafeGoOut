get_crime_data <- function(force, 
                           crime_category,
                           date) {
  
  if (missing(crime_category) & missing(date)) {
    crime_data <- ukpolice::ukc_crime_no_location(force)
  } else {
    if (missing(date) | missing(crime_category)) {
      if (missing(crime_category)) {
        latest_date <- find_available_dates()$max
        # find all the months between date and latest date
        all_dates <- seq(as.Date(date), as.Date(latest_date), by = "month")
        crime_data <- tibble::tibble()
        for (i in 1:length(all_dates)) {
          crime_data <- rbind(crime_data, 
                              ukpolice::ukc_crime_no_location(force, date = all_dates[i]))
        }
      } else if (missing(date)) {
        crime_data <- ukpolice::ukc_crime_no_location(force, crime_category)
      }
    } else {
      crime_data <- ukpolice::ukc_crime_no_location(force, crime_category, date)
    }
  }
  return(crime_data)
}

get_graph_data <- function(force, date) {
  
  if(missing(date)) {
    graph_data <- ukpolice::ukc_stop_search_no_location(force)
  } else {
    latest_date <- find_available_dates()$max
    # find all the months between date and latest date
    all_dates <- seq(as.Date(date), as.Date(latest_date), by = "month")
    graph_data <- tibble::tibble()
    for (i in 1:length(all_dates)) {
      graph_data <- rbind(graph_data, 
                          ukpolice::ukc_stop_search_no_location(force, date = all_dates[i]))
    }
  }
  
  return(graph_data)
}

# Write a function that takes data and return the number of crimes

crime_number <- function(data) {
  
  crime_number <- nrow(data)
  
  return(crime_number)
}

most_common_crime <- function(data) {
  
  most_common_crime_id <- data %>% 
    dplyr::group_by(category) %>% 
    dplyr::summarise(n = n()) %>% 
    dplyr::arrange(desc(n)) %>% 
    dplyr::pull(category) %>%
    head(1)
  
  crimes_categories <- ukpolice::ukc_crime_category()
  
  most_common_crime <- crimes_categories$name[crimes_categories$url == most_common_crime_id]
  
  return(most_common_crime)
}


# write a function to summarise officer data by force and optionally by neighbourhood

get_officer_data <- function(force, 
                             neighbourhood) {
  
  if (missing(neighbourhood)) {
    officer_data <- ukpolice::ukc_officers(force)
  } else {
    officer_data <- ukpolice::ukc_officers(force, neighbourhood)
  }
  
  return(officer_data)
}


# function that takes data and returns a graph of number of crimes per date

# most likely day to commit a crime


number_of_crimes_per_date_graph <- function(data) {
  
  graph_data <- data %>% 
    dplyr::mutate(day = substr(datetime, 1, 10)) %>%
    dplyr::mutate(day = as.Date(day)) %>%
    dplyr::group_by(day) %>%
    dplyr::summarise(n = n())
  
  graph <- ggplot2::ggplot(data = graph_data, 
                           ggplot2::aes(x = day, 
                                        y = n)) +
    ggplot2::geom_line(color = "#e60082") +
    ggplot2::labs(#title = "Number of crimes per date",
                  x = "Date",
                  y = "Number of crimes") +
    ggplot2::theme_minimal() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(face="bold", color="#ff0593", 
                                                       angle=45),
                   axis.text.y = ggplot2::element_text(face="bold", color="#ff0593"),
                   axis.line = ggplot2::element_line(colour = "pink", 
                                                     linetype = "solid")) +
    ggplot2::geom_area(fill = "pink", alpha = 0.5)
  
  
  # make the previous graph using plotly
  plotly_graph <- plotly::ggplotly(graph)
  
  return(plotly_graph)
  
}

empty_plot <- function(title = NULL){
  p <- plotly::plotly_empty(type = "scatter", mode = "markers") %>%
    plotly::config(
      displayModeBar = FALSE
    ) %>%
    plotly::layout(
      title = list(
        text = title,
        yref = "paper",
        y = 0.5
      )
    )
  return(p)
} 

type_of_crime_graph <- function(data) {
  
  crimes_categories <- ukpolice::ukc_crime_category()
  graph_data <- data %>%
    dplyr::group_by(category) %>%
    dplyr::summarise(n = n()) %>%
    dplyr::left_join(crimes_categories, by = c("category" = "url")) %>%
    arrange(n) %>% 
    #head(-1) %>% 
    mutate(name = factor(name, levels = name)) # This trick update the factor levels
  
  graph <- ggplot2::ggplot(graph_data, ggplot2::aes(x = name, y = n)) +
    ggplot2::geom_segment( ggplot2::aes(xend = name, yend = 0)) +
    ggplot2::geom_point(size = 3, shape = 23, fill = "#e000bb") +
    ggplot2::coord_flip() +
    ggplot2::theme_minimal() +
    ggplot2::xlab("") +
    ggplot2::ylab("Number of crimes")
  
  plotly_graph <- plotly::ggplotly(graph)
  
  return(plotly_graph)
}

crime_resolution_graph <- function(data) {
  
  graph_data <- data %>%
    dplyr::group_by(outcome) %>%
    dplyr::summarise(n = n())
  
  # treemap
  graph <- treemap::treemap(graph_data,
                            index = "outcome",
                            vSize = "n",
                            type = "index",
                            title = "Crime outcome",
                            palette = "PiYG"
  )
  
  return(graph)
}

crime_resolution_graph_plotly <- function(data) {
  
  graph_data <- data %>%
    dplyr::group_by(outcome) %>%
    dplyr::summarise(n = n()) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(parent = "Crime outcome")
  
  plot <- plotly::plot_ly(
    type="treemap",
    labels=graph_data$outcome,
    parents=graph_data$parent,
    values=graph_data$n) %>%
    plotly::layout(treemapcolorway=c("pink", "deeppink","hotpink",
                                     "palevioletred", "mediumvioletred",
                                     "#F4D1FF","#F88379",
                                     "#FFDBD1","#F8F3EA"))
  return(plot)

}

#' Get street crime details for a specific neighbourhood
#'
#' @param force 
#' @param neighbourhood 
#'
#' @return street crime df
get_street_crime <- function(force, 
                            neighbourhood) {
  
  #if missing neighbourhood return empty dataframe if not get neighbourhood specific data
  if (missing(neighbourhood)) {
    street_crime <- data.frame()
  } else {
    neigbourhood_coordinates <- ukpolice::ukc_neighbourhood_specific(force, neighbourhood)$centre
    street_crime <- ukpolice::ukc_street_crime(neigbourhood_coordinates$latitude, 
                                                    neigbourhood_coordinates$longitude)
    
  }
}

#' Gets the street crime data and returns a summary to be displayed on the map
#'
#' @param street_crimes 
#'
#' @return street crime summary
street_crime_summary_map <- function(street_crimes) {
  
  #summarise
  street_crimes <- street_crimes %>% 
    group_by(category, latitude, longitude, street_name) %>% 
    summarise(count = n()) %>% 
    arrange(desc(count))
  
  street_crimes$latitude <- as.numeric(street_crimes$latitude)
  street_crimes$longitude <- as.numeric(street_crimes$longitude)
  
  # Normalize the crime rates for radius scaling
  normalized_radius <- sqrt(street_crimes$count / max(street_crimes$count))
  
  street_crime_map <- leaflet::leaflet(street_crimes) %>%
    leaflet::addProviderTiles("CartoDB.VoyagerLabelsUnder")%>%
    leaflet::addCircleMarkers(
      lat = ~latitude,
      lng = ~longitude,
      radius = ~12 * normalized_radius,  # Adjust the scaling factor as needed
      fillColor = ~leaflet::colorNumeric(palette = viridis::viridis(10), domain = street_crimes$count)(street_crimes$count),
      fillOpacity = 0.8,
      color = "white",
      stroke = TRUE,
      weight = 1,
      label = ~paste("Crime Rate:", count)
    ) %>%
    leaflet::addLegend(
      pal = leaflet::colorNumeric(palette = viridis::viridis(10), domain = street_crimes$count),
      values = ~count,
      title = "Crime Rate",
      position = "bottomright"
    )
  
  return(street_crime_map)
  
}

#' Display heat map of street crime
#'
#' @param street_crimes 
#'
#' @return street crime summary
street_crime_heat_map <- function(street_crimes) {
  
  #summarize
  street_crimes <- street_crimes %>% 
    group_by(category, latitude, longitude, street_name) %>% 
    summarise(count = n()) %>% 
    arrange(desc(count))
  
  street_crimes$latitude <- as.numeric(street_crimes$latitude)
  street_crimes$longitude <- as.numeric(street_crimes$longitude)

  heat_map <- leaflet::leaflet() %>%
    leaflet::addProviderTiles("Stadia.AlidadeSmooth")%>%
    leaflet.extras::addHeatmap(data = street_crimes ,
               lng = ~longitude, lat = ~latitude, intensity = ~count,
               blur = 20, max = 0.05, radius = 15
    )
  
  return(heat_map)
  
}