# rendering function

render <- function(.tbl_pl, backend = "ggplot2") {
  
  aes_quos <- attr(.tbl_pl, "aes")
  aes_cols <- names(aes_quos)
  if (length(.tbl_pl[["geom"]]) == 0L) {
    geom <- "blank"
  } else {
    geom <- unique(.tbl_pl[["geom"]])
    geom_opts <- dplyr::select(.tbl_pl,
                               -c(aes_cols, "geom"))
    geom_opts <- dplyr::distinct(geom_opts)
    geom_opts <- rlang::as_list(geom_opts)
  }
  
  # for some weird reason `aes`` takes x, and y as it's first arguments
  # so we need to splice those out

  if (!rlang::is_empty(aes_quos[["x"]])) x <- rlang::sym("x")
  if (!rlang::is_empty(aes_quos[["y"]]))  y <- rlang::sym("y")
  leftovers <- setdiff(names(aes_quos), c("x", "y"))
  aes_dots <- rlang::syms(leftovers)
  names(aes_dots) <-  leftovers
  if (backend == "ggplot2") {
    loadNamespace("ggplot2")
    geom_fun <- match.fun(paste0("geom_", geom))
    aes_layer <- aes(rlang::UQ(x), rlang::UQ(y), rlang::UQS(aes_dots))
    
    gg_call <- rlang::call2(
      "ggplot", data = .tbl_pl
    )
    
    layer_call <- rlang::call2(
      geom_fun, mapping = aes_layer, rlang::splice(geom_opts)
    )
    
    labels <- rlang::call2(
      "labs", aes_quos
    )
    ggplot_eval <- lapply(list(gg_call, layer_call, labels), rlang::eval_tidy)
    
    Reduce("+", ggplot_eval)
  }
}