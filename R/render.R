# rendering function
render <- function(x) {
  UseMethod("render")
}

render.tbl_pl <- function(x) {
  gg_call <- rlang::call2("ggplot", .ns = "ggplot2")
  layer_call <- render_layer(x)
  rlang::eval_tidy(gg_call) + rlang::eval_tidy(layer_call)
}

render_layer <- function(x) {
  
  if (length(x[["geom"]]) == 0L) {
    geom <- "blank"
    geom_opts <- list()
  } else {
    geom <- x[["geom"]][1]
    geom_opts <- x[["opts"]][[1]]
    if (length(geom_opts) == 0) {
      geom_opts <- list()
    } else {
      geom_opts <- rlang::as_list(geom_opts)
    }
  }
  # for some weird reason `aes`` takes x, and y as it's first arguments
  # so we need to splice those out
  aes_current <- get_aes(x)
  if (any(aes_current %in% "x")) .x <- rlang::sym("x")
  if (any(aes_current %in% "y"))  .y <- rlang::sym("y")
  leftovers <- setdiff(aes_current, c("x", "y"))
  aes_dots <- rlang::syms(leftovers)
  names(aes_dots) <-  leftovers
  aes_layer <- ggplot2::aes(rlang::UQ(.x), rlang::UQ(.y), rlang::UQS(aes_dots))
  
  geom_fun <- paste0("geom_", geom)
  layer_call <- rlang::call2(
    geom_fun, 
    data = get_layer_data(x),
    mapping = aes_layer, 
    rlang::splice(geom_opts),
    .ns = "ggplot2"
  )
  
  layer_call
}