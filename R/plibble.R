# simple approach just augment the data with aesthetics
# could do this either via nesting calls or tacking on 
# aesthetics to the input tibble/data.frame
build_plibble <- function(aes_tbl, aes_vars, call_list) {
  tibble::new_tibble(
    aes_tbl,
    mapping = aes_vars,
    signals = list(),
    pipeline = new_funlist(call_list),
    subclass = "tbl_pl"
  )
}

update_plibble <- function(x, mapping, call) {
  build_plibble(x, mapping, call)
}

get_signals <- function(x) attr(x, "signals")

#' @export
get_mapping <- function(x) { attr(x, "mapping") }
set_mapping <- function(x, mapping) { 
  current <- get_mapping(x)
  attr(x, "mapping") <- c(current, mapping)
  x
}

set_pipeline <- function(x, call) {
  pipeline <- attr(x, "pipeline")
  pipeline <- c(pipeline,  call)
  attr(x, "pipeline") <- pipeline
  x
}

get_pipeline <- function(x) {
  attr(x, "pipeline")
}

strip_mapping <- function(x) { sub("aes_", "", x) }
