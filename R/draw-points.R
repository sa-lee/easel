#' @export
draw_points <- function(.data, ...) {
  point_opts <- rlang::enquos(...)
  current_aes <- aes_plibble(.data)
  
  if (rlang::is_empty(point_opts)) {
    mutate(.data, geom = "point")
  } else {
    # override aes if point opts coincide with it
    is_overlap <- names(current_aes) %in% names(point_opts)
    if (any(is_overlap)) {
      current_aes <- current_aes[!is_overlap]
      .data <- build_plibble(.data, current_aes)
    }
    mutate(.data, geom = "point", rlang::UQS(point_opts))
  }
}