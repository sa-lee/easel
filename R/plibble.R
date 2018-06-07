#' @export 
visualise <- function(.data, ...) {
  plibble(.data, ...)
}

aes_plibble <- function(tbl_pl)  attr(tbl_pl, "aes") 

build_plibble <- function(aes_tbl, aes_vars) {
  tibble::new_tibble(
    aes_tbl,
    aes = aes_vars,
    subclass = "tbl_pl"
  )
}

#' @export 
plibble <- function(.data, ...) { UseMethod("plibble") }

#' @method plibble data.frame
#' @export 
plibble.data.frame <- function(.data, ...) {
  aes_vars <- rlang::enquos(..., .named = TRUE)
  aes_tbl <- purrr::map_dfc(aes_vars, rlang::eval_tidy, data = .data)
  build_plibble(aes_tbl, aes_vars)
}

#' @method print tbl_pl
#' @export
print.tbl_pl <- function(x, ...) {
  print(render(x))
}