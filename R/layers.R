# a list of layers ...
plibble_list <- function(x) {
  stopifnot(all(vapply(x, is_plibble, logical(1))),
            is.list(x))
  structure(x, class = "tbl_pl_list", names = names(x))
}

# put them together with mesh 
#' @export 
mesh <- function(...) {
  plibble_list(list(...))
}

#' @export
`[.tbl_pl_list` <- function(x, i) {
  structure(NextMethod(), class = "tbl_pl_list")
}
#' @export
c.tbl_pl_list <- function(..., recursive = FALSE) {
  plibble_list(NextMethod())
}