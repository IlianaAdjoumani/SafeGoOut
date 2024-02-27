find_available_dates <- function() {
  
  dates <- ukpolice::ukc_available() %>%
    dplyr::mutate(date = paste0(date, "-01")) %>%
    dplyr::mutate(date = as.Date(date, format="%Y-%m-%d")) 
  
  max <- head(dates$date, 1)
  min <- tail(dates$date, 1)
  
  return(list(min = min, 
              max = max))
}


