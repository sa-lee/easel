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

right_na <- function(type) {
  switch(type,
         character = NA_character_,
         double = NA_real_,
         integer = NA_integer_,
         logical = NA,
         complex = NA_complex_)
}

is_list_col_reactive <- function(x) {
  if (is.list(x)) 
    return(shiny::is.reactive(x[[1]]))
  FALSE
}


inside <- function(x, y, control) {
  if (is_list_col_reactive(control)) {
    vals <- try(control[[1]](), silent = TRUE)
    if (inherits(vals, "try-error")) {
      return(FALSE)
    }
    dplyr::between(x, vals$xmin, vals$xmax) &&
      dplyr::between(y, vals$ymin, vals$ymax)
  }
  
}