get_quos_names <- function(quos) {
  vapply(quos, quo_name, character(1))
}

all_are_predicate <- function(x, p) {
  all(vapply(x, p, logical(1)))
}

all_are_function <- function(x) {
  all_are_predicate(x, is_function)
}

is_plibble <- function(x) inherits(x, "tbl_pl")

all_are_plibble <- function(x) {
  all_are_predicate(x, is_plibble)
}


get_reactive_expr <- function(x) {
  attr(x, "expr")
}

has_reactive_attr <- function(x) {
  !is.null(get_reactive_expr(x))
}

is_list_col_reactive <- function(x) {
  if (is.list(x)) 
    return(shiny::is.reactivevalues(x[[1]]))
  FALSE
}

which_signals <- function(x) {
  unlist(
    lapply(x, 
           function(.) any(grepl("signal", names(get_pipeline(.))))
    )
  )
}

which_encodings <- function(x) {
  vapply(x,
        function(.) any(grepl("^aes", names(.))),
        logical(1)
  )
  
}