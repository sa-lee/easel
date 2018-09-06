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


#' persistent mutation (occurs at run time)
mutate_persistent <- function(.data, ...) UseMethod("mutate_persistent")

mutate_persistent.tbl_pl <- function(.data, ...) {
  dots <- rlang::enquos(..., .named = TRUE)
  .mutate <- function(.data, dots) {
    mutate_eager(.data, !!!dots)
  }
  rlang::fn_fmls(.mutate)[2] <- list(dots = dots)
  
  set_pipeline(.data, list(mutate_persistent = .mutate))

}