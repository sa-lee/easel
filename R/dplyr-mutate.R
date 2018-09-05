# mutate.R
#' @importFrom dplyr mutate
#' @export
dplyr::mutate 

#' @importFrom dplyr transmute
#' @export
dplyr::transmute

mutate_eager <- function(.data, ...) UseMethod("mutate_eager")

mutate_eager.tbl_pl <- function(.data, ...) {
  class(.data) <- class(.data)[-1]
  update <- mutate(.data, ...)
  update_plibble(update, get_mapping(.data), get_pipeline(.data))
}

mutate_deferred <- function(.data, ...) UseMethod("mutate_deferred")

mutate_deferred.tbl_pl <- function(.data, ...) {
  dots <- rlang::enquos(..., .named = TRUE)
  .mutate <- function(.data, dots) {
    mutate_eager(.data, !!!dots)
  }
  rlang::fn_fmls(.mutate)[2] <- list(dots = dots)
  set_pipeline(.data, list(mutate = .mutate))
} 

#' @method mutate tbl_pl
#' @export
mutate.tbl_pl <- mutate_deferred.tbl_pl

#' @method transmute tbl_pl
transmute.tbl_pl <- function(.data, ...) {
  update <- NextMethod()
  build_plibble(update, get_mapping(.data), get_pipeline(.data))
}

mutate_layer <- function(.data, layer, ...) UseMethod("mutate_layer")

mutate_layer.tbl_pl <- function(.data, layer, ...) {

}

# modify a specific layer in place
mutate_at_layer <- function(.data, node, ...) {
  env <- as_environment(.data, caller_env())
  new_cols <- enquos(..., .named = TRUE)
  new_cols <- lapply(new_cols, quo_set_env, env = env)
  .data[[node]] <- mutate(.data[[node]], !!!new_cols)
  .data
}