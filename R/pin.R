#' A mutable tibble/data.frame to enable a forward/reverse graphics pipeline
#' 
#' Here we simply just store the data in an envirionment then all
#' `dplyr` verbs just act on the data frame inside the environment, making
#' the data.frame/tibble inside a mutable object. We wrap this environment
#' into an s3 class called a 'mutibble'. 
#'
#' We need to make it obvious that we are using a mutable data structure,
#' so we use the verb `pin` to emphasise that we are 'pinning' down the input
#' data to an environment. 
#'
pin <- function(.data) { UseMethod("pin") }

pin.default <- function(.data) {
  new_mutibble(tibble::as_tibble(.data))
}

pin.tbl_df <- function(.data) {
  new_mutibble(.data)
}

new_mutibble <- function(.data) {
  structure(rlang::env(.tbl = .data), class = "mutibble")
}

print.mutibble <- function(x , ...) print(x$.tbl)


mutate.mutibble <- function(.data, ...) {
  .data$.tbl <- mutate(.data$.tbl, ...)
  .data
}

filter.mutibble <- function(.data, ...) {
  .data$.tbl <- filter(.data$.tbl, ...)
  .data
}

summarise.mutibble <- function(.data, ...) {
  .data$.tbl <- summarise(.data$.tbl, ...)
  .data
}
