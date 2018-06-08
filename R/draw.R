#' The API for drawing is quite simple:
#' It takes a plot tibble and appends a graphical primitive + 
#' any additional options to to the plot, layers are then built
#' up using bind. 

set_opts <- function(.data, ..., geom) {
  point_opts <- rlang::dots_list(...)
  if (rlang::is_empty(point_opts)) {
    mutate(.data, geom = rlang::UQ(geom))
  } else {
    # override aes if point opts coincide with it
    current_aes <- get_aes(.data)
    is_overlap <- names(current_aes) %in% names(point_opts)
    if (any(is_overlap)) {
      current_aes <- current_aes[!is_overlap]
      .data <- build_plibble(.data, current_aes)
    }
    mutate(.data, geom = rlang::UQ(geom), opts = list(point_opts))
  }
}

#' @export
draw_points <- function(.data, ...) UseMethod("draw_points")

#' probably could hard code options here
#' @export
draw_points.tbl_pl <- function(.data, ...) {
  set_opts(.data, ..., geom = "point")
}

#'@export
draw_lines <- function(.data, ...) UseMethod("draw_lines")

#' @export
draw_lines.tbl_pl <- function(.data, ...) {
  set_opts(.data, ..., geom = "line")
}

