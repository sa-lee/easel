#' @export
draw_points <- function(.data, ...) {
  point_opts <- rlang::enquos(...)
  if (rlang::is_empty(point_opts)) {
    mutate(.data, geom = "point")
  } else {
    mutate(.data, geom = "point", rlang::UQS(point_opts))
  }
}