#' Title
#'
#' @param dataframe
#' @param covariates
#' @param lag
#' @param lead
#' @param nlags
#' @param nleads
#' @param vlags
#' @param vleads
#' @param grouping
#' @param skips
#'
#' @return
#' @export
#'
#' @examples
data.frame.lag.lead = function(dataframe, covariates, lag = FALSE, lead = FALSE,
                               nlags = 0, nleads = 0, vlags = c(), vleads = c(),
                               grouping = NA, skips = 1) {
  # INPUTS
  # dataframe: input data
  # covariates: vector of strings that specify covariates to lag in the dataframe
  # lag: determines if function will lag
  # lead: determines if function will lead
  # nlags: number of times to lag the covariates in the dataframe
  # nleads: number of times to lead the covariates in the dataframe
  # vlags: vector containing integers for more control of how many lags, overrides nlags & skips
  # vleads: vector containing integers for more control of how many leads, overrides nleads & skips
  # grouping: the column name to group data by to ensure that lagging does not go across groups
  # skips: number of entries to skip across each separate lag

  # OUTPUTS
  # dataframe : input data with new lagged/lead columns
  # new.covariates : vector of strings with new column names

  new.covariates = vector() # holds new column names
  group.count = 1 # number of groupings in the dataframe, such as separate idcollar groups

  if (lag & lead) {

    # recursively call function to lag and lead separately
    lagging = data.frame.lag.lead(dataframe, covariates, lag, lead = FALSE, nlags, nleads, vlags = vlags, vleads = c(), grouping, skips)
    leading = data.frame.lag.lead(lagging[[1]], covariates, lag = FALSE, lead, nlags, nleads, vlags = c(), vleads = vleads, grouping, skips)

    # return final data frame object and combine the lag & lead new.covariates vectors
    return(list(dataframe = leading[[1]],
                new.covariates = c(lagging[[2]], leading[[2]])))

  } else if (lag) {

    if (nlags == 0) return(list(dataframe, c())) # do nothing

    # give placeholder variables the appropriate lagging values
    func = dplyr::lag
    prefix = "prev"
    n.level = nlags
    vec = vlags

  } else if (lead) {

    if (nleads == 0) return(list(dataframe, c())) # do nothing

    # give placeholder variables the appropriate leading values
    func = dplyr::lead
    prefix = "next"
    n.level = nleads
    vec = vleads

  }

  if (!is.na(grouping)) {
    # use group_by so that when lagging & leading, groups do not interact with each other
    # in nonsensical ways, such as the last entry from animal 1 being included as a previous
    # entry for the first entry of animal 2
    dataframe = dataframe |>
      dplyr::group_by(!!rlang::sym(grouping))
    group.count = length(unique(dataframe[[grouping]]))
  }

  # prepare names to be used in mutate & lag/lead functions:

  if (length(vec) != 0) { #
    # vector of vlag/lead vec distances, repeated for each covariates
    lag.lead.distance = rep_len(x = vec,
                                length.out = length(covariates) * length(vec))
    # vector of specified/input covariates, repeated to be same length as lag.lead.distance
    repeated.covariates = rep(covariates, each=length(vec))
  } else {
    # vector of distance from current row to the lagged or lead row, repeated for each covariate
    lag.lead.distance = rep_len(x = seq(from=skips, to=skips*n.level,
                                        by=skips),
                                length.out = length(covariates)*n.level)
    # vector of specified/input covariates, repeated to be same length as lag.lead.distance
    repeated.covariates = rep(covariates, each=n.level)
  }

  # vector of new column names using prev/next classification, distance from current row, & covariate name
  new.covariates = paste0(prefix, lag.lead.distance, repeated.covariates)

  # iterate over the new vectors to mutate the appropriate lag/lead data & column names
  for (i in 1:length(new.covariates)) {
    dataframe = dataframe %>%
      dplyr::mutate(!!new.covariates[[i]] := func(!!rlang::sym(repeated.covariates[[i]]),
                                             n=lag.lead.distance[[i]]))
  }

  if (!is.na(grouping)) {
    dataframe = dataframe |>
      dplyr::ungroup()
  }

  # returns new, mutated dataframe and new column names
  return(list(dataframe = dataframe,
              new.covariates = new.covariates))

}


