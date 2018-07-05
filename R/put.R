#' Mutate in place
#' 
#' The pin allows a tibble to become mutable, and in order to update values
#' inside of this new mutable tibble, we need to 'put' values in there.
#' 
#' put is essentially a call to mutate but is based on the condition that a
#' event has taken place (hence it uses dplyr's case_when function)
#' we need to think of a way of providing sensible defaults with the possible
#' things that could be modified here (i.e. colour or shape or other features)
#' could aesthetic variables be placed here (maybe with the aes_ modifier?)?
put_values <- function(.data, vals) {
  cols <- names(vals)
  na_vals <- lapply(vals, typeof)
  for (col in cols) {
    .data <- mutate(.data, 
                    UQ(col) := dplyr::case_when(
                      event == TRUE ~ UQ(vals[[col]]),
                      event == FALSE ~ "black"
                    ))
  }
  .data
}

put <- function(.data, ...) {
  vals <- rlang::dots_list(...)
  fun <- put_values
  fn_fmls(fun)[2] <- list(vals = vals)
  .data$.tbl <- set_pipeline(.data$.tbl, list(put_values = fun))
  .data
}