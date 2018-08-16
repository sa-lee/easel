# mutate.R
#' @importFrom dplyr mutate
#' @export
dplyr::mutate 

#' @importFrom dplyr transmute
#' @export
dplyr::transmute


#' @method mutate tbl_pl
#' @export
mutate.tbl_pl <- function(.data, ...) {
  update <- NextMethod()
  update_plibble(update, get_mapping(.data), get_pipeline(.data))
}

#' @method transmute tbl_pl
transmute.tbl_pl <- function(.data, ...) {
  update <- NextMethod()
  build_plibble(update, get_mapping(.data), get_pipeline(.data))
}

mutate_layer <- function(.data, layer, ...) UseMethod("mutate_layer")

mutate_layer.tbl_pl <- function(.data, layer, ...) {
  dots <- rlang::enquos(..., .named = TRUE)
  .mutate <- function(.data, layer, dots) {
    mutate_at_layer(.data, layer, !!!dots)
  }
  rlang::fn_fmls(.mutate)[c(2,3)] <- list(layer = layer, dots = dots)
  set_pipeline(.data, list(mutate_layer = .mutate))
}

# modify a specific layer in place
mutate_at_layer <- function(.data, node, ...) {
  .data[[node]] <- mutate(.data[[node]], ...)
  .data
}