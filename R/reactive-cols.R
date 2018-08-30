#' Typed columns that contain a reactive expression

as_reactive_logical <- function(x, expr) {
  UseMethod("as_reactive_logical")
}

new_reactive_lgl  <- function(x, expr) {
  stopifnot(rlang::is_expression(expr))
  structure(x, 
            class = c("reactive_lgl", "logical"),
            expr = expr)
}

as_reactive_logical.logical <- function(x, expr) {
  new_reactive_lgl(x, expr)
}


as_reactive_numeric <- function(x, expr) {
  UseMethod("as_reactive_numeric")
}

new_reactive_num <- function(x, expr) {
  stopifnot(rlang::is_expression(expr))
  structure(x, 
            class = c("reactive_num", "numeric"),
            expr = expr)
}

as_reactive_numeric.numeric <- function(x, expr) {
  new_reactive_num(x, expr)
}
