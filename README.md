
# autoembed

<!-- badges: start -->
<!-- badges: end -->

The goal of autoembed is to generate temporal lead or lag embeddings of features 
observed over time. The embeddings can be inputs to downstream models for 
predicting, forecasting, hindcasting, or interpolating.

## Installation

You can install the development version of autoembed from [GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("schafer-research-lab/autoembed")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(autoembed)
library(randomForest)

dat = data.frame(
  time = 1:10,
  longitude = c(0, -2, 1, -1, 0, 2, 3, 6, 7, 4),
  latitude = c(0, -1, 0, 1, 0, 0, -1, 0, 1, 0),
  height = c(10, 8, 9, 10, 10, 15, 18, 20, 25, 20)
)

# create lag columns for all variables other than time
auto.out = autoembed::data.frame_lag_lead(
  dataframe = dat,
  covariates = colnames(dat)[-1],
  nlags = 1
)

dat = auto.out$dataframe

# fitting RF model with data excluding rows with NAs for lagged variables
randomForest(
  x = dat[-1, auto.out$new.covariates],
  y = dat[-1, "longitude"],
  ntree = 50
)
```

## Citation

Acosta, J. P. C., Park, S. W., Stewart, D. G., Lozano-Cavazos, E. A., Webb, S. L., and Schafer, T. L. J. 2026. "Comparison of machine learning interpolation models for movement trajectories of desert bighorn sheep." _Environmental and Ecological Statistics_ (2026). https://doi.org/10.1007/s10651-026-00713-w
