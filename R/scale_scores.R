#' scale_scores: Automated Scale Score Calculations
#'
#' @description Uses regular expressions and tidyeval to calculate the composite scores for multi-item survey scales. Uses regular expressions to identify scales and items. Calculates the mean of the items given that respondents completed the requisite number of items.
#' @param data A data frame that has been renamed in a way that the column names contain information about the scale and the item number.
#' @param ... Variables that share the naming convention of a subscale but should be dropped from scale calculations. These may include attention check items or raw scores for reverse coded items.
#' @param completed_thresh The proportion of scale items that must be completed to calculate scale scores. Defaults to .75
#' @param scale_regex A regular expression that is associated with the scale naming conventions. Defaults to the first capitalized or uncapitalized alphabetic characterers or punctuation.
#' @param item_regex A regular expression that is associated with the item naming conventions. Defaults to the last numeric values, r, or _r.
#' @param scales_only A logical value indicating whether only the scales should be returned. Defaults to FALSE where scales are bound to the original data frame as new columns.
#'
#' @return Data frame containing scale scores.
#' @import dplyr
#' @import tidyr
#' @importFrom magrittr %>%
#' @export
#'
#' @examples
#'
#' # Example utlizes the bfi data that loads with the psych package
#' library(tidyverse)
#' bfi<-psych::bfi
#'
#' # Several of the items need to be reverse coded.
#' # I do this by creating new items but retain the old columns in the complete data frame.
#' personality<-bfi%>%
#'               mutate_at(vars(A1, E1, E2, O2, O5, C4, C5),
#'                         .funs = list(r = function(x){7-x}))
#'
#' cleaned<-scale_scores(data = personality, A1, E1, E2, O2, O5, C4, C5)

scale_scores<-function(data, ..., completed_thresh = .75, scales_only = FALSE, scale_regex="^[A-Za-z[:punct:]]*", item_regex="[0-9]+$|[0-9]+r$|[0-9]+_r"){
  dropquo <- dplyr::enquos(...)


  scaled <- data %>%
    dplyr::mutate(.unique_row_id = 1:nrow(data))%>% # adds a row id (useful for maintaining observations later on)
    dplyr::select_if(function(x){is.numeric(x)|is.integer(x)}) # retains observations only if they are numeric to create scale scores

  if(length(dropquo>1)){
   scaled<- scaled%>%
     dplyr::select(-c(!!!dropquo)) # drops the specified columns if any are provided through dots
  }
  scaled<-scaled%>%
    tidyr::gather(key = key, value = value, -.unique_row_id)%>% # converts to long format. rows are now associated with person-record
    dplyr::filter(stringr::str_detect(key, item_regex))%>% # retains only observations that match regular expression
    dplyr::mutate(.scale = stringr::str_extract(key,  scale_regex))%>% # extracts the scale title
    dplyr::mutate(.scale = as.factor(.scale))%>% # converts to factor for grouping
    dplyr::group_by(.unique_row_id, .scale) %>% # groups by person scale
    dplyr::summarize(.scale_score = mean(value, na.rm = TRUE), # calculates average of completed data
                     na_prop = sum(is.na(value))/n())%>% # calculates missing proportion
    dplyr::mutate(.scale_score = dplyr::if_else((1-completed_thresh)>na_prop, # if missing proportion is greater than threshold returns na
                                 .scale_score,
                                 as.numeric(NA)))%>%
    dplyr::select(-na_prop)%>% # removes missing proportion
    dplyr::filter(!is.na(.scale))

  # prints verbose message
  message("Scale scores created for ", dplyr::n_distinct(scaled$.scale), " scales.\n",
          "Scale Names:\n",
          paste(unique(scaled$.scale), collapse = " "))

  # spreads so that rows are associted with original values and arranges so they are in teh same order
  scaled<-scaled%>%
    tidyr::spread(key = .scale, value = .scale_score)%>%
    dplyr::arrange(.unique_row_id)%>%
    dplyr::ungroup()

  # formats appropriately based on user arguments
  if(!scales_only){
    scaled<-scaled%>%
      dplyr::bind_cols(data)%>%
      dplyr::select(colnames(data), dplyr::everything(), -.unique_row_id)
  }else{
    scaled<-scaled%>%
      splyr::select(-.unique_row_id)
  }

    scaled
}
