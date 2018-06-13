#' The API for drawing is quite simple:
#' It takes a plot tibble and appends a graphical primitive + 
#' any additional options to to the plot, layers are then built
#' up using mesh.
#' 
#'  How to handle when options that overlap aesthetics?  
#'  1. Throw a warning/message?
#'  2. overwrite it?
set_opts <- function(.data, opts, geom) {
  
  if (rlang::is_empty(opts)) {
    mutate(.data, geom = rlang::UQ(geom))
  } else {
    # override aes if  opts coincide with it
    current_aes <- get_mapping(.data)
    is_overlap <- names(opts) %in% names(current_aes)
    if (any(is_overlap)) {
      message("updating aesthetics...")
      names(opts[is_overlap]) <- paste0("aes_", names(opts[is_overlap]))
    }
    names(opts)[!is_overlap] <- paste0("opts_", names(opts)[!is_overlap])
    mutate(.data, geom = rlang::UQ(geom), rlang::UQS(opts))
  }
}

draw_call <- function(.data, ..., geom) {
  opts <- rlang::dots_list(...)
  opts_fun <- set_opts
  if (length(opts) > 0) {
    fn_fmls(opts_fun)[c(2,3)] <- list(opts = opts, geom = geom)
  } else {
    fn_fmls(opts_fun)[c(2,3)] <- list(opts = list(), geom = geom)
  }
  opts_fun
}

#' @export
draw_points <- function(.data, ...) UseMethod("draw_points")

#' probably could hard code options here
#' @export
draw_points.tbl_pl <- function(.data, ...) {
  fun <- draw_call(.data, ..., geom = "point")
  set_pipeline(.data, list(draw_points = fun))
}

#'@export
draw_lines <- function(.data, ...) UseMethod("draw_lines")

#' @export
draw_lines.tbl_pl <- function(.data, ...) {
  fun <- draw_call(.data, ..., geom = "line")
  set_pipeline(.data, list(draw_lines = fun))
}


#'@export
draw_rect <- function(.data, ...) UseMethod("draw_rect")

#' @export
draw_rect.tbl_pl <- function(.data, ...) {
  fun <- draw_call(.data, ..., geom = "rect")
  set_pipeline(.data, list(draw_rect = fun))
}
