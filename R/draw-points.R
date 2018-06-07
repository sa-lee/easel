#' @export
draw_points <- function(.data, ...) UseMethod("draw_points")

draw_points.tbl_pl <- function(.data, ...) {
  point_opts <- rlang::enquos(...)
  if (rlang::is_empty(point_opts)) {
    .data <- mutate(.data, geom = "point")
  } else {
    .data <- mutate(.data, geom = "point", opts = list(rlang::UQS(point_opts)))
  }
  .data
}

draw_points.tbl_pl_list <- function(x, ...) NULL