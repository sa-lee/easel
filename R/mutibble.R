#' A mutable tibble
#' 
#'
mutibble <- function(.data) {
  # create a data mask with base environment as parent 
  mask <- rlang::as_data_mask(.data)
  tibble::new_tibble(
    .data,
    mask = mask,
    subclass = "mutibble"
  )
}

get_mask <- function(.data) {
  attr(.data, "mask")
}

get_mask_top <- function(.data) {
  attr(.data, "mask")$.top_env
}

mutate.mutibble <- function(.data, ...) {
  vars <- rlang::enquos(..., .named = TRUE)
  var_names <- names(vars)
  
  mask <- get_mask(.data)
  nr <- nrow(.data)
  
  for (i in length(vars)) {
    var <- eval_tidy(vars[[i]], data = mask)
    nm <- sym(var_names[[i]])
    stopifnot(length(var) == nr | length(var) == 1L)
    env_bind(mask, !!nm := var)
  }
  .data
}
