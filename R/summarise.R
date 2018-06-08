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
#' @export
summarise.tbl_pl <- function(.data, ...) {
  aes_vars <- attr(.data, "aes_vars")
  aes_var_names <- names(aes_vars)
  summ_vars <- rlang::enquos(..., .named = TRUE)
  summ_var_names <- names(summ_vars)
  stopifnot(summ_var_names %in% aes_var_names)
  .tbl <- tidyr::unnest(.data)
  .tbl <- group_by_aesthetics(.tbl, aes_var_names, summ_var_names)
  .tbl <- dplyr::summarise(.tbl, ...)
  # # switch quos order
  # summ_names <- get_quos_names(aes_vars)[names(.tbl)]
  # summ_syms <- rlang::syms(names(.tbl))
  # names(summ_syms) <- summ_names
  # print(.tbl)
  # .tbl <- dplyr::rename(.tbl, rlang::UQS(summ_syms))
  .tbl <- tidyr::nest(.tbl, .key = "aes")
  build_plibble(.tbl, aes_vars)
}


#' @export
summarise_mean_2d <- function(.tbl_pl, na.rm = TRUE) {
  aes_vars <- get_aes(.tbl_pl)
  stopifnot(any(aes_vars %in% c("x", "y")))
  summarise(.tbl_pl, 
            x = mean(x, na.rm = rlang::UQ(na.rm)), 
            y = mean(y, na.rm = rlang::UQ(na.rm)))
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