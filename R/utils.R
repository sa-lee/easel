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