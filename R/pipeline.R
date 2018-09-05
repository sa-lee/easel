new_funlist <- function(x) {
  if (!is_list(x) || !all_are_function(x)) {
    stop("Expected a list of functions.")
  }
  structure(x,
            class = "function_list",
            names = names2(x))
}

is_funlist <- function(x) inherits(x, "function_list")

as_funlist <- function(x) {
  x <- lapply(x, as_function)
  new_funlist(x)
}

modify_funlist <- function(x, name, new_fun) {
  x[[name]] <- new_fun
  x
}

`[<-.function_list` <- function(x, i, value) {
  value <- list(rlang::as_function(value))
  NextMethod()
}

#' @export
`[.function_list` <- function(x, i) {
  structure(NextMethod(), class = "function_list")
}
#' @export
c.function_list <- function(..., recursive = FALSE) {
  new_funlist(NextMethod())
}

invoke_pipeline <- function(.data) UseMethod("invoke_pipeline")

invoke_pipeline.tbl_pl <- function(.data) {
  pipeline <- get_pipeline(.data)
  for (fun in pipeline) {
    .data <- fun(.data)
  }
  .data
}

invoke_pipeline.tbl_pl_list <- function(.data) {
    lapply(.data, invoke_pipeline)
}



