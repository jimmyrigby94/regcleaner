% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/scale_scores.R
\name{scale_scores}
\alias{scale_scores}
\title{scale_scores: Automated Scale Score Calculations}
\usage{
scale_scores(data, ..., completed_thresh = 0.75, scales_only = FALSE,
  scale_regex = "^[A-Za-z[:punct:]]*",
  item_regex = "[0-9]+$|[0-9]+r$|[0-9]+_r")
}
\arguments{
\item{data}{A data frame that has been renamed in a way that the column names contain information about the scale and the item number.}

\item{...}{Variables that share the naming convention of a subscale but should be dropped from scale calculations. These may include attention check items or raw scores for reverse coded items.}

\item{completed_thresh}{The proportion of scale items that must be completed to calculate scale scores. Defaults to .75}

\item{scales_only}{A logical value indicating whether only the scales should be returned. Defaults to FALSE where scales are bound to the original data frame as new columns.}

\item{scale_regex}{A regular expression that is associated with the scale naming conventions. Defaults to the first capitalized or uncapitalized alphabetic characterers or punctuation.}

\item{item_regex}{A regular expression that is associated with the item naming conventions. Defaults to the last numeric values, r, or _r.}
}
\value{
Data frame containing scale scores.
}
\description{
Uses regular expressions and tidyeval to calculate the composite scores for multi-item survey scales. Uses regular expressions to identify scales and items. Calculates the mean of the items given that respondents completed the requisite number of items.
}
\examples{

# Example utlizes the bfi data that loads with the psych package
library(tidyverse)
bfi<-psych::bfi

# Several of the items need to be reverse coded.
# I do this by creating new items but retain the old columns in the complete data frame.
personality<-bfi\%>\%
              mutate_at(vars(A1, E1, E2, O2, O5, C4, C5),
                        .funs = list(r = function(x){7-x}))

cleaned<-scale_scores(data = personality, A1, E1, E2, O2, O5, C4, C5)
}
