#' A mutable tibble
#' 
#'
mutibble <- function(.data) {
  # create a data mask with empty environment as parent 
  mask <- rlang::as_data_mask(.data, parent = rlang::empty_env())
  tibble::new_tibble(
    .data,
    mask = mask,
    subclass = "mutibble"
  )
}


binder <- function(.env, sym) {
  function(v) {
    if (missing(v)) {
      rlang::env_get(.env$.top_env, sym)
    } else {
      sym <- rlang::sym(sym)
      expr <- rlang::expr(!!sym <- v)
      rlang::eval_tidy(expr, data = .env)
    }
  }
}