# aggregations and stats
#' @importFrom dplyr summarise
#' @export
dplyr::summarise

group_by_aesthetics <- function(.tbl, aes_var_names, summ_var_names) {
  other_vars <- setdiff(aes_var_names, summ_var_names)
  if (length(other_vars) > 0) {
    group_vars <- rlang::syms(other_vars)
    return(dplyr::group_by(.tbl, rlang::UQS(group_vars)))
  } 
  .tbl
}
# only operates on aesthetics
# not exposed to the user necessarily
#' @method summarise tbl_pl
#' @export
summarise.tbl_pl <- function(.data, ...) {
  aes_var_names <- names(.data)[grep("^aes", names(.data))]
  summ_vars <- rlang::enquos(..., .named = TRUE)
  summ_var_names <- names(summ_vars)
  stopifnot(summ_var_names %in% aes_var_names)
  .tbl <- group_by_aesthetics(.data, 
                              aes_var_names, 
                              summ_var_names)
  .tbl <- dplyr::summarise(.tbl, ...)
  build_plibble(.tbl, get_mapping(.data), get_pipeline(.data))
}

bin_interval <- function(x, nbins) {
  rng <- range(x, na.rm = TRUE, finite = TRUE)
  findInterval(x, seq(rng[1], rng[2], length.out = nbins + 1), 
               rightmost.closed = TRUE,
               all.inside = TRUE
  )
}
#' Naive histogram algorithm, defaults to width 1
#' @export
summarise_bins <- function(.data, nbins) {
  fun <- function(.data, nbins) {
    aes_var_names <- names(.data)[grep("^aes", names(.data))]
    stopifnot(aes_var_names %in% "aes_x")
    .data <- dplyr::add_count(.data, 
                              bin = bin_interval(aes_x, rlang::UQ(nbins)))
    
    .data <- dplyr::group_by(.data, bin)
    .data <- dplyr::filter(.data, dplyr::row_number(mpg) == 1L)
    .data <- dplyr::ungroup(.data)
    .data <- dplyr::transmute(.data,
                           aes_xmin = aes_x,
                           aes_xmax = aes_x + 1,
                           aes_ymin = 0L,
                           aes_ymax = n)
    .data
  }
  fn_fmls(fun)[2] <- list(nbins = nbins)
  set_pipeline(.data, list(summarise_bins = fun))
}


#' @export
summarise_mean_2d <- function(.data, na.rm = TRUE) {
  fun <- function(.data, na.rm) {
    summarise(.data, 
              aes_x = mean(aes_x, na.rm = rlang::UQ(na.rm)), 
              aes_y = mean(aes_y, na.rm = rlang::UQ(na.rm)))
  }
  fn_fmls(fun)[2] <- list(na.rm = na.rm)
  set_pipeline(.data, list(summarise_mean_2d = fun))
}

#' getting fitted values from a model is more of a transform?
#' @export
summarise_lm <- function(.tbl_pl, formula = y~x, ...) {
  aes_vars <- get_aes(.tbl_pl)
  stopifnot(any(aes_vars %in% c("x", "y")))
  
  .tbl <- dplyr::bind_rows(.tbl_pl$aes)
  .tbl <- group_by_aesthetics(.tbl, aes_vars, c("x", "y"))
  if (inherits(.tbl, "grouped_df")) {
    .tbl <- tidyr::nest(.tbl)
    .tbl <- mutate(.tbl, .y = purrr::map(data, ~fitted(lm(formula, data = .)))) 
    .tbl <- tidyr::unnest(.tbl)
  } else {
    .tbl <- mutate(.tbl, .y = fitted(lm(formula, data = .tbl)))
  }
  .tbl <- dplyr::select(.tbl, -y)
  .tbl <- dplyr::rename(.tbl, y = .y)
  build_plibble(tidyr::nest(.tbl, .key = "aes"), attr(.tbl_pl, "aes_vars"))
}