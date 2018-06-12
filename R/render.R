# rendering function
#' @export
render <- function(x) {
  UseMethod("render")
}

#' @export
render.tbl_pl <- function(x) {
  gg_call <- rlang::call2("ggplot", .ns = "ggplot2")
  layer_call <- render_layer(x)
  aes_quos <- attr(x, "mapping")
  labels <- rlang::call2("labs", aes_quos, .ns = "ggplot2")
  rlang::eval_tidy(gg_call) + rlang::eval_tidy(layer_call) + rlang::eval_tidy(labels)
}

#' @export
render.tbl_pl_list <- function(x) {
  
  gg_call <- rlang::call2("ggplot", .ns = "ggplot2")
  layer_calls <- lapply(x, render_layer)
  all_labs <- lapply(x, get_mapping)
  max_labs <- which.max(lengths(all_labs))
  aes_quos <- all_labs[[max_labs]]
  labels <- rlang::call2("labs", aes_quos, .ns = "ggplot2")
  layer_eval <- Reduce("+", lapply(c(gg_call, layer_calls, labels), 
                                   rlang::eval_tidy))
  layer_eval
}

eval_pipeline <- function(x) {
  pipeline <- attr(x, "pipeline")
  for (i in seq_along(pipeline)) {
    x <- pipeline[[i]](x)
  }
  x
}

render_layer <- function(x) {
  aes_current <- names(get_mapping(x))
  x <- eval_pipeline(x)
  plot_data <- dplyr::select(x, dplyr::starts_with("aes"))

  if (length(x[["geom"]]) == 0L) {
    geom <- "blank"
    geom_opts <- list()
  } else {
    geom <- x[["geom"]][1]
    geom_opts <- x[1, grep("^opts_", names(x))]
    if (ncol(geom_opts) == 0) {
      geom_opts <- list()
    } else {
      names(geom_opts) <- sub("^opts_", "", names(geom_opts))
      geom_opts <- rlang::as_list(geom_opts)
    }
  }
  # for some weird reason `aes`` takes x, and y as it's first arguments
  # so we need to splice those out
  if (any(aes_current %in% "x")) .x <- rlang::sym("aes_x")
  if (any(aes_current %in% "y"))  .y <- rlang::sym("aes_y")
  leftovers <- setdiff(aes_current, c("x", "y"))
  if (length(leftovers)) {
    aes_dots <- rlang::syms(paste0("aes_", leftovers))
    names(aes_dots) <-  leftovers
  } else {
    aes_dots <- list()
  }

  aes_layer <- ggplot2::aes(rlang::UQ(.x), rlang::UQ(.y), rlang::UQS(aes_dots))
  
  geom_fun <- paste0("geom_", geom)
  layer_call <- rlang::call2(
    geom_fun, 
    data = plot_data,
    mapping = aes_layer, 
    rlang::splice(geom_opts),
    .ns = "ggplot2"
  )
  
  layer_call
}