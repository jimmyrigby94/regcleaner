regcleaner: Quick Survey Cleaning and Reliability Analysis using Regular
Expressions
================

`regcleaner` is an R package intended to automate data cleaning and item
analysis for multi-item scales often collected via surveys. Data
cleaning is typicallly the most time consuming part of any analytic
endeavor. The philosophy of this package is to capitalize on the
information stored in column names to minimize the number of times
researchers need to manipulate the data by hand. This speeds up the
cleaning process and minimizes the number of errors committed.

## Installation

To install regcleaner run the following code.

``` r
devtools::install_github("jimmyrigby94/regcleaner")
```

## A Few Quick Examples

Currently `regcleaner` has two primary functions. The first is
`scale_scores`, a function that uses regular expressions to identify
multi-item scales and creates scale scores, or composite scores, by
averaging the items for each observation. The other function,
`alpha_regex`, facilitates item analysis and reliability analysis by
capitalizing on information inherently stored in column names.

### Naming Conventions

All functions in regcleaner use two regular expressions to identify
scales and differentiate between items. The argument `scale_regex` pulls
information from column names associated with the different measurements
within a data frame. The argument `item_regex` pulls information from
column names associated with the item in the sub scale.

Consider the `bfi` data set from the `psych` package. Each column is
associated with an item that belongs to a sub scale. Information, or
metadata, is stored within the column names that ties each item to a
scale. Columns that belong to a multi-item scale end with a number,
unique to the item, and begin with a letter unique to the scale.
regcleaner extracts this information to create scale scores and run item
analysis while ignoring columns that do not match these patterns.

``` r
library(tidyverse)
library(regcleaner)

bfi<-psych::bfi

glimpse(bfi)
```

    ## Observations: 2,800
    ## Variables: 28
    ## $ A1        <int> 2, 2, 5, 4, 2, 6, 2, 4, 4, 2, 4, 2, 5, 5, 4, 4, 4, 5...
    ## $ A2        <int> 4, 4, 4, 4, 3, 6, 5, 3, 3, 5, 4, 5, 5, 5, 5, 3, 6, 5...
    ## $ A3        <int> 3, 5, 5, 6, 3, 5, 5, 1, 6, 6, 5, 5, 5, 5, 2, 6, 6, 5...
    ## $ A4        <int> 4, 2, 4, 5, 4, 6, 3, 5, 3, 6, 6, 5, 6, 6, 2, 6, 2, 4...
    ## $ A5        <int> 4, 5, 4, 5, 5, 5, 5, 1, 3, 5, 5, 5, 4, 6, 1, 3, 5, 5...
    ## $ C1        <int> 2, 5, 4, 4, 4, 6, 5, 3, 6, 6, 4, 5, 5, 4, 5, 5, 4, 5...
    ## $ C2        <int> 3, 4, 5, 4, 4, 6, 4, 2, 6, 5, 3, 4, 4, 4, 5, 5, 4, 5...
    ## $ C3        <int> 3, 4, 4, 3, 5, 6, 4, 4, 3, 6, 5, 5, 3, 4, 5, 5, 4, 5...
    ## $ C4        <int> 4, 3, 2, 5, 3, 1, 2, 2, 4, 2, 3, 4, 2, 2, 2, 3, 4, 4...
    ## $ C5        <int> 4, 4, 5, 5, 2, 3, 3, 4, 5, 1, 2, 5, 2, 1, 2, 5, 4, 3...
    ## $ E1        <int> 3, 1, 2, 5, 2, 2, 4, 3, 5, 2, 1, 3, 3, 2, 3, 1, 1, 2...
    ## $ E2        <int> 3, 1, 4, 3, 2, 1, 3, 6, 3, 2, 3, 3, 3, 2, 4, 1, 2, 2...
    ## $ E3        <int> 3, 6, 4, 4, 5, 6, 4, 4, NA, 4, 2, 4, 3, 4, 3, 6, 5, ...
    ## $ E4        <int> 4, 4, 4, 4, 4, 5, 5, 2, 4, 5, 5, 5, 2, 6, 6, 6, 5, 6...
    ## $ E5        <int> 4, 3, 5, 4, 5, 6, 5, 1, 3, 5, 4, 4, 4, 5, 5, 4, 5, 6...
    ## $ N1        <int> 3, 3, 4, 2, 2, 3, 1, 6, 5, 5, 3, 4, 1, 1, 2, 4, 4, 6...
    ## $ N2        <int> 4, 3, 5, 5, 3, 5, 2, 3, 5, 5, 3, 5, 2, 1, 4, 5, 4, 5...
    ## $ N3        <int> 2, 3, 4, 2, 4, 2, 2, 2, 2, 5, 4, 3, 2, 1, 2, 4, 4, 5...
    ## $ N4        <int> 2, 5, 2, 4, 4, 2, 1, 6, 3, 2, 2, 2, 2, 2, 2, 5, 4, 4...
    ## $ N5        <int> 3, 5, 3, 1, 3, 3, 1, 4, 3, 4, 3, NA, 2, 1, 3, 5, 5, ...
    ## $ O1        <int> 3, 4, 4, 3, 3, 4, 5, 3, 6, 5, 5, 4, 4, 5, 5, 6, 5, 5...
    ## $ O2        <int> 6, 2, 2, 3, 3, 3, 2, 2, 6, 1, 3, 6, 2, 3, 2, 6, 1, 1...
    ## $ O3        <int> 3, 4, 5, 4, 4, 5, 5, 4, 6, 5, 5, 4, 4, 4, 5, 6, 5, 4...
    ## $ O4        <int> 4, 3, 5, 3, 3, 6, 6, 5, 6, 5, 6, 5, 5, 4, 5, 3, 6, 5...
    ## $ O5        <int> 3, 3, 2, 5, 3, 1, 1, 3, 1, 2, 3, 4, 2, 4, 5, 2, 3, 4...
    ## $ gender    <int> 1, 2, 2, 2, 1, 2, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 2, 1...
    ## $ education <int> NA, NA, NA, NA, NA, 3, NA, 2, 1, NA, 1, NA, NA, NA, ...
    ## $ age       <int> 16, 18, 17, 17, 17, 21, 18, 19, 19, 17, 21, 16, 16, ...

### Creating Scale Scores

The bfi naming convention happily align with the defaults for
`scale_regex` and `item_regex` already. However, some items in the bfi
data set need to be reverse coded. This can be done using dplyr. In
order to keep a paper trail of the manipulations done to my data, I keep
the raw non reverse coded columns in my data frame along with the new
reverse coded items. The columns that have been reverse coded have "\_r"
appended to their original column names. Note that “r” and "\_r" are
handled by the item\_regex.

``` r
personality<-bfi%>%
              mutate_at(vars(A1, E1, E2, O2, O5, C4, C5),
                        .funs = list(r = function(x){7-x}))
```

After handling the reverse coded items, I can create scale scores using
the `scale_scores` function. To do this, I pass the data that contains
the item data. The data frame contains some extra information that
matches the regular expressions\! Because I retained the raw non reverse
coded items, `scale_scores` will use them to calculate the composite
score unless they are dropped. Note that education, age, and gender do
not need to be dropped because they don’t match the `item_regex`. The
new data frame contains the original items with the scale scores
appended as additional columns.

``` r
cleaned<-scale_scores(data = personality, A1, E1, E2, O2, O5, C4, C5)
```

    ## Scale scores created for 5 scales.
    ## Scale Names:
    ## A C E N O

``` r
glimpse(cleaned)
```

    ## Observations: 2,800
    ## Variables: 40
    ## $ A1        <int> 2, 2, 5, 4, 2, 6, 2, 4, 4, 2, 4, 2, 5, 5, 4, 4, 4, 5...
    ## $ A2        <int> 4, 4, 4, 4, 3, 6, 5, 3, 3, 5, 4, 5, 5, 5, 5, 3, 6, 5...
    ## $ A3        <int> 3, 5, 5, 6, 3, 5, 5, 1, 6, 6, 5, 5, 5, 5, 2, 6, 6, 5...
    ## $ A4        <int> 4, 2, 4, 5, 4, 6, 3, 5, 3, 6, 6, 5, 6, 6, 2, 6, 2, 4...
    ## $ A5        <int> 4, 5, 4, 5, 5, 5, 5, 1, 3, 5, 5, 5, 4, 6, 1, 3, 5, 5...
    ## $ C1        <int> 2, 5, 4, 4, 4, 6, 5, 3, 6, 6, 4, 5, 5, 4, 5, 5, 4, 5...
    ## $ C2        <int> 3, 4, 5, 4, 4, 6, 4, 2, 6, 5, 3, 4, 4, 4, 5, 5, 4, 5...
    ## $ C3        <int> 3, 4, 4, 3, 5, 6, 4, 4, 3, 6, 5, 5, 3, 4, 5, 5, 4, 5...
    ## $ C4        <int> 4, 3, 2, 5, 3, 1, 2, 2, 4, 2, 3, 4, 2, 2, 2, 3, 4, 4...
    ## $ C5        <int> 4, 4, 5, 5, 2, 3, 3, 4, 5, 1, 2, 5, 2, 1, 2, 5, 4, 3...
    ## $ E1        <int> 3, 1, 2, 5, 2, 2, 4, 3, 5, 2, 1, 3, 3, 2, 3, 1, 1, 2...
    ## $ E2        <int> 3, 1, 4, 3, 2, 1, 3, 6, 3, 2, 3, 3, 3, 2, 4, 1, 2, 2...
    ## $ E3        <int> 3, 6, 4, 4, 5, 6, 4, 4, NA, 4, 2, 4, 3, 4, 3, 6, 5, ...
    ## $ E4        <int> 4, 4, 4, 4, 4, 5, 5, 2, 4, 5, 5, 5, 2, 6, 6, 6, 5, 6...
    ## $ E5        <int> 4, 3, 5, 4, 5, 6, 5, 1, 3, 5, 4, 4, 4, 5, 5, 4, 5, 6...
    ## $ N1        <int> 3, 3, 4, 2, 2, 3, 1, 6, 5, 5, 3, 4, 1, 1, 2, 4, 4, 6...
    ## $ N2        <int> 4, 3, 5, 5, 3, 5, 2, 3, 5, 5, 3, 5, 2, 1, 4, 5, 4, 5...
    ## $ N3        <int> 2, 3, 4, 2, 4, 2, 2, 2, 2, 5, 4, 3, 2, 1, 2, 4, 4, 5...
    ## $ N4        <int> 2, 5, 2, 4, 4, 2, 1, 6, 3, 2, 2, 2, 2, 2, 2, 5, 4, 4...
    ## $ N5        <int> 3, 5, 3, 1, 3, 3, 1, 4, 3, 4, 3, NA, 2, 1, 3, 5, 5, ...
    ## $ O1        <int> 3, 4, 4, 3, 3, 4, 5, 3, 6, 5, 5, 4, 4, 5, 5, 6, 5, 5...
    ## $ O2        <int> 6, 2, 2, 3, 3, 3, 2, 2, 6, 1, 3, 6, 2, 3, 2, 6, 1, 1...
    ## $ O3        <int> 3, 4, 5, 4, 4, 5, 5, 4, 6, 5, 5, 4, 4, 4, 5, 6, 5, 4...
    ## $ O4        <int> 4, 3, 5, 3, 3, 6, 6, 5, 6, 5, 6, 5, 5, 4, 5, 3, 6, 5...
    ## $ O5        <int> 3, 3, 2, 5, 3, 1, 1, 3, 1, 2, 3, 4, 2, 4, 5, 2, 3, 4...
    ## $ gender    <int> 1, 2, 2, 2, 1, 2, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 2, 1...
    ## $ education <int> NA, NA, NA, NA, NA, 3, NA, 2, 1, NA, 1, NA, NA, NA, ...
    ## $ age       <int> 16, 18, 17, 17, 17, 21, 18, 19, 19, 17, 21, 16, 16, ...
    ## $ A1_r      <dbl> 5, 5, 2, 3, 5, 1, 5, 3, 3, 5, 3, 5, 2, 2, 3, 3, 3, 2...
    ## $ E1_r      <dbl> 4, 6, 5, 2, 5, 5, 3, 4, 2, 5, 6, 4, 4, 5, 4, 6, 6, 5...
    ## $ E2_r      <dbl> 4, 6, 3, 4, 5, 6, 4, 1, 4, 5, 4, 4, 4, 5, 3, 6, 5, 5...
    ## $ O2_r      <dbl> 1, 5, 5, 4, 4, 4, 5, 5, 1, 6, 4, 1, 5, 4, 5, 1, 6, 6...
    ## $ O5_r      <dbl> 4, 4, 5, 2, 4, 6, 6, 4, 6, 5, 4, 3, 5, 3, 2, 5, 4, 3...
    ## $ C4_r      <dbl> 3, 4, 5, 2, 4, 6, 5, 5, 3, 5, 4, 3, 5, 5, 5, 4, 3, 3...
    ## $ C5_r      <dbl> 3, 3, 2, 2, 5, 4, 4, 3, 2, 6, 5, 2, 5, 6, 5, 2, 3, 4...
    ## $ A         <dbl> 4.0, 4.2, 3.8, 4.6, 4.0, 4.6, 4.6, 2.6, 3.6, 5.4, 4....
    ## $ C         <dbl> 2.8, 4.0, 4.0, 3.0, 4.4, 5.6, 4.4, 3.4, 4.0, 5.6, 4....
    ## $ E         <dbl> 3.80, 5.00, 4.20, 3.60, 4.80, 5.60, 4.20, 2.40, 3.25...
    ## $ N         <dbl> 2.8, 3.8, 3.6, 2.8, 3.2, 3.0, 1.4, 4.2, 3.6, 4.2, 3....
    ## $ O         <dbl> 3.0, 4.0, 4.8, 3.2, 3.6, 5.0, 5.4, 4.2, 5.0, 5.2, 4....

Some things to note about `scale_scores`. `scale_scores` contains an
argument called `completed_thresh` that specifies the number of items
within a scale the user must complete for the scale score to not be
returned as `NA`. Its default is .75. This means that in order for a
scale score to be calculated a respondent must complete 75% of the
items. This prevents extrapolation from partially complete composite
measures.

In addition there is an argument called `scales_only` which allows users
to request only the composite scores.

### Item Analysis

`alpha_regex` has an extremely similar function structure. It extracts
scales from a data frame and than conducts item analysis using `alpha`
from the psych package. Columns that match the regex patterns but should
not be included in reliability can be dropped using tidyeval. The
function defaults to returning a data frame summarizing the reliability
analysis. This data frame includes the following:

    raw_alpha: alpha based upon the covariances
    
    std.alpha: The standarized alpha based upon the correlations
    
    G6(smc): Guttman's Lambda 6 reliability
    
    average_r: The average interitem correlation
    
    median_r: The median interitem correlation
    
    mean: The mean of the scale formed by averaging items
    
    sd: The standard deviation of the total score

``` r
alpha_regex(cleaned, A1, E1, E2, O2, O5, C4, C5)
```

    ## Reliability analysis ran on 5 scales.
    ## Scale Names:
    ## A C E N O

    ##   scale raw_alpha std.alpha   G6(smc) average_r      S/N         ase
    ## 1     A 0.7030184 0.7130286 0.6827627 0.3319677 2.484668 0.008951774
    ## 2     C 0.7267350 0.7300726 0.6942276 0.3510454 2.704700 0.008116697
    ## 3     E 0.7617328 0.7617951 0.7265955 0.3901001 3.198066 0.007027046
    ## 4     N 0.8139629 0.8146747 0.7991260 0.4678539 4.395917 0.005607097
    ## 5     O 0.6001725 0.6072684 0.5681398 0.2362061 1.546268 0.011858651
    ##       mean        sd  median_r
    ## 1 4.652095 0.8984019 0.3376233
    ## 2 4.265732 0.9513469 0.3400043
    ## 3 4.145083 1.0609041 0.3817637
    ## 4 3.162268 1.1963314 0.4136794
    ## 5 4.586649 0.8083739 0.2261315

If more information is needed, for example the drop one reliability, you
can request robust output which returns all the output from
`psych::alpha` in list format for each scale score.

``` r
alpha_regex(cleaned, A1, E1, E2, O2, O5, C4, C5, verbose_output = TRUE)
```

    ## Reliability analysis ran on 5 scales.
    ## Scale Names:
    ## A C E N O

    ## $A
    ## 
    ## Reliability analysis   
    ## Call: psych::alpha(x = .)
    ## 
    ##   raw_alpha std.alpha G6(smc) average_r S/N   ase mean  sd median_r
    ##        0.7      0.71    0.68      0.33 2.5 0.009  4.7 0.9     0.34
    ## 
    ##  lower alpha upper     95% confidence boundaries
    ## 0.69 0.7 0.72 
    ## 
    ##  Reliability if an item is dropped:
    ##      raw_alpha std.alpha G6(smc) average_r S/N alpha se  var.r med.r
    ## A1_r      0.72      0.73    0.67      0.40 2.6   0.0087 0.0065  0.38
    ## A2        0.62      0.63    0.58      0.29 1.7   0.0119 0.0169  0.29
    ## A3        0.60      0.61    0.56      0.28 1.6   0.0124 0.0094  0.32
    ## A4        0.69      0.69    0.65      0.36 2.3   0.0098 0.0159  0.37
    ## A5        0.64      0.66    0.61      0.32 1.9   0.0111 0.0126  0.34
    ## 
    ##  Item statistics 
    ##         n raw.r std.r r.cor r.drop mean  sd
    ## A1_r 2784  0.58  0.57  0.38   0.31  4.6 1.4
    ## A2   2773  0.73  0.75  0.67   0.56  4.8 1.2
    ## A3   2774  0.76  0.77  0.71   0.59  4.6 1.3
    ## A4   2781  0.65  0.63  0.47   0.39  4.7 1.5
    ## A5   2784  0.69  0.70  0.60   0.49  4.6 1.3
    ## 
    ## Non missing response frequency for each item
    ##         1    2    3    4    5    6 miss
    ## A1_r 0.03 0.08 0.12 0.14 0.29 0.33 0.01
    ## A2   0.02 0.05 0.05 0.20 0.37 0.31 0.01
    ## A3   0.03 0.06 0.07 0.20 0.36 0.27 0.01
    ## A4   0.05 0.08 0.07 0.16 0.24 0.41 0.01
    ## A5   0.02 0.07 0.09 0.22 0.35 0.25 0.01
    ## 
    ## $C
    ## 
    ## Reliability analysis   
    ## Call: psych::alpha(x = .)
    ## 
    ##   raw_alpha std.alpha G6(smc) average_r S/N    ase mean   sd median_r
    ##       0.73      0.73    0.69      0.35 2.7 0.0081  4.3 0.95     0.34
    ## 
    ##  lower alpha upper     95% confidence boundaries
    ## 0.71 0.73 0.74 
    ## 
    ##  Reliability if an item is dropped:
    ##      raw_alpha std.alpha G6(smc) average_r S/N alpha se  var.r med.r
    ## C1        0.69      0.70    0.64      0.36 2.3   0.0093 0.0037  0.35
    ## C2        0.67      0.67    0.62      0.34 2.1   0.0099 0.0056  0.34
    ## C3        0.69      0.69    0.64      0.36 2.3   0.0096 0.0070  0.36
    ## C4_r      0.65      0.66    0.60      0.33 2.0   0.0107 0.0037  0.32
    ## C5_r      0.69      0.69    0.63      0.36 2.2   0.0096 0.0017  0.35
    ## 
    ##  Item statistics 
    ##         n raw.r std.r r.cor r.drop mean  sd
    ## C1   2779  0.65  0.67  0.54   0.45  4.5 1.2
    ## C2   2776  0.70  0.71  0.60   0.50  4.4 1.3
    ## C3   2780  0.66  0.67  0.54   0.46  4.3 1.3
    ## C4_r 2774  0.74  0.73  0.64   0.55  4.4 1.4
    ## C5_r 2784  0.72  0.68  0.57   0.48  3.7 1.6
    ## 
    ## Non missing response frequency for each item
    ##         1    2    3    4    5    6 miss
    ## C1   0.03 0.06 0.10 0.24 0.37 0.21 0.01
    ## C2   0.03 0.09 0.11 0.23 0.35 0.20 0.01
    ## C3   0.03 0.09 0.11 0.27 0.34 0.17 0.01
    ## C4_r 0.02 0.08 0.16 0.17 0.29 0.28 0.01
    ## C5_r 0.10 0.17 0.22 0.12 0.20 0.18 0.01
    ## 
    ## $E
    ## 
    ## Reliability analysis   
    ## Call: psych::alpha(x = .)
    ## 
    ##   raw_alpha std.alpha G6(smc) average_r S/N   ase mean  sd median_r
    ##       0.76      0.76    0.73      0.39 3.2 0.007  4.1 1.1     0.38
    ## 
    ##  lower alpha upper     95% confidence boundaries
    ## 0.75 0.76 0.78 
    ## 
    ##  Reliability if an item is dropped:
    ##      raw_alpha std.alpha G6(smc) average_r S/N alpha se  var.r med.r
    ## E1_r      0.73      0.73    0.67      0.40 2.6   0.0084 0.0044  0.38
    ## E2_r      0.69      0.69    0.63      0.36 2.3   0.0095 0.0028  0.35
    ## E3        0.73      0.73    0.67      0.40 2.7   0.0082 0.0071  0.40
    ## E4        0.70      0.70    0.65      0.37 2.4   0.0091 0.0033  0.38
    ## E5        0.74      0.74    0.69      0.42 2.9   0.0078 0.0043  0.42
    ## 
    ##  Item statistics 
    ##         n raw.r std.r r.cor r.drop mean  sd
    ## E1_r 2777  0.72  0.70  0.59   0.52  4.0 1.6
    ## E2_r 2784  0.78  0.76  0.69   0.61  3.9 1.6
    ## E3   2775  0.68  0.70  0.58   0.50  4.0 1.4
    ## E4   2791  0.75  0.75  0.66   0.58  4.4 1.5
    ## E5   2779  0.64  0.66  0.52   0.45  4.4 1.3
    ## 
    ## Non missing response frequency for each item
    ##         1    2    3    4    5    6 miss
    ## E1_r 0.09 0.13 0.16 0.15 0.23 0.24 0.01
    ## E2_r 0.09 0.14 0.22 0.12 0.24 0.19 0.01
    ## E3   0.05 0.11 0.15 0.30 0.27 0.13 0.01
    ## E4   0.05 0.09 0.10 0.16 0.34 0.26 0.00
    ## E5   0.03 0.08 0.10 0.22 0.34 0.22 0.01
    ## 
    ## $N
    ## 
    ## Reliability analysis   
    ## Call: psych::alpha(x = .)
    ## 
    ##   raw_alpha std.alpha G6(smc) average_r S/N    ase mean  sd median_r
    ##       0.81      0.81     0.8      0.47 4.4 0.0056  3.2 1.2     0.41
    ## 
    ##  lower alpha upper     95% confidence boundaries
    ## 0.8 0.81 0.82 
    ## 
    ##  Reliability if an item is dropped:
    ##    raw_alpha std.alpha G6(smc) average_r S/N alpha se  var.r med.r
    ## N1      0.76      0.76    0.71      0.44 3.1   0.0075 0.0061  0.41
    ## N2      0.76      0.76    0.72      0.45 3.2   0.0073 0.0054  0.41
    ## N3      0.76      0.76    0.73      0.44 3.1   0.0077 0.0179  0.39
    ## N4      0.80      0.80    0.77      0.50 3.9   0.0064 0.0182  0.49
    ## N5      0.81      0.81    0.79      0.52 4.3   0.0059 0.0137  0.53
    ## 
    ##  Item statistics 
    ##       n raw.r std.r r.cor r.drop mean  sd
    ## N1 2778  0.80  0.80  0.76   0.67  2.9 1.6
    ## N2 2779  0.79  0.79  0.75   0.65  3.5 1.5
    ## N3 2789  0.81  0.81  0.74   0.67  3.2 1.6
    ## N4 2764  0.72  0.71  0.60   0.54  3.2 1.6
    ## N5 2771  0.68  0.67  0.53   0.49  3.0 1.6
    ## 
    ## Non missing response frequency for each item
    ##       1    2    3    4    5    6 miss
    ## N1 0.24 0.24 0.15 0.19 0.12 0.07 0.01
    ## N2 0.12 0.19 0.15 0.26 0.18 0.10 0.01
    ## N3 0.18 0.23 0.13 0.21 0.16 0.09 0.00
    ## N4 0.17 0.24 0.15 0.22 0.14 0.09 0.01
    ## N5 0.24 0.24 0.14 0.18 0.12 0.09 0.01
    ## 
    ## $O
    ## 
    ## Reliability analysis   
    ## Call: psych::alpha(x = .)
    ## 
    ##   raw_alpha std.alpha G6(smc) average_r S/N   ase mean   sd median_r
    ##        0.6      0.61    0.57      0.24 1.5 0.012  4.6 0.81     0.23
    ## 
    ##  lower alpha upper     95% confidence boundaries
    ## 0.58 0.6 0.62 
    ## 
    ##  Reliability if an item is dropped:
    ##      raw_alpha std.alpha G6(smc) average_r S/N alpha se  var.r med.r
    ## O1        0.53      0.53    0.48      0.22 1.1    0.014 0.0092  0.23
    ## O2_r      0.57      0.57    0.51      0.25 1.3    0.013 0.0076  0.22
    ## O3        0.50      0.50    0.44      0.20 1.0    0.015 0.0071  0.20
    ## O4        0.61      0.62    0.56      0.29 1.6    0.012 0.0044  0.29
    ## O5_r      0.51      0.53    0.47      0.22 1.1    0.015 0.0115  0.20
    ## 
    ##  Item statistics 
    ##         n raw.r std.r r.cor r.drop mean  sd
    ## O1   2778  0.62  0.65  0.52   0.39  4.8 1.1
    ## O2_r 2800  0.65  0.60  0.43   0.33  4.3 1.6
    ## O3   2772  0.67  0.69  0.59   0.45  4.4 1.2
    ## O4   2786  0.50  0.52  0.29   0.22  4.9 1.2
    ## O5_r 2780  0.67  0.66  0.52   0.42  4.5 1.3
    ## 
    ## Non missing response frequency for each item
    ##         1    2    3    4    5    6 miss
    ## O1   0.01 0.04 0.08 0.22 0.33 0.33 0.01
    ## O2_r 0.06 0.10 0.16 0.14 0.26 0.29 0.00
    ## O3   0.03 0.05 0.11 0.28 0.34 0.20 0.01
    ## O4   0.02 0.04 0.06 0.17 0.32 0.39 0.01
    ## O5_r 0.03 0.07 0.13 0.19 0.32 0.27 0.01

### Adapting Regular Expressions

The defaults for the item and stem regex were selected to match the most
common use cases. However, there is never a one size fits all default.
`item_regex` and `stem_regex` can be adapted in any way that matches
your needs. See `?regex` for a variety of patterns that can be used to
identify your scales and items.
