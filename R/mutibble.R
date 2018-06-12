#' A mutable tibble
#' 
#'

.mutibble <- function(.data) {
  # create a data mask with active bindings from the top environment
  mask <- rlang::as_data_mask(.data, parent = rlang::empty_env())
  nms <- names(.data)
  binding_funs <- lapply(nms, binder, .env = mask)
  names(binding_funs) <- nms
  for (name in nms) {
    makeActiveBinding(name, binding_funs[[name]], mask)
  }
  mask
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