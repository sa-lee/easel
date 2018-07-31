# currently using mvc
# need to break up into more modular code, i.e pipeline stages

vl_types <- function(x) {
  switch(class(x)[1],
         "numeric" = "quantitative",
         "integer" = "ordinal",
         "factor" = "nominal",
         "ordered" = "ordinal",
         "character" = "nominal",
         )
}

vg_range <- function(nm) {
  if (grepl("x", nm)) return("width")
  return("height")
}

# a very minimal vega spec
to_vg_spec <- function(.data) {
  plot_data <- dplyr::select(.data, dplyr::starts_with("aes"))
  mark <- .data[["geom"]][1]
  aes_nms <- names(plot_data)
  scales <- vector("list", ncol(plot_data))
  encodings <- scales
  for (i in seq_along(scales)) {
    scales[[i]] <- list(name = aes_nms[[i]],
                        type = "linear",
                        round = TRUE,
                        nice = TRUE,
                        domain = list(data = "source", field = aes_nms[[i]]),
                        range = vg_range(aes_nms[[i]]))
    encodings[[i]] <- list(scale = aes_nms[[i]],
                           field = aes_nms[[i]])
  }
  names(encodings) <- c("x", "y")
  
  axes <- list(
    list(orient = "bottom", grid = TRUE, scale = "aes_x"),
    list(orient = "left", grid = TRUE, scale = "aes_y")
  )
  marks <- list(
    name = "layer",
    type = "symbol",
    from = list(data = "source"),
    encode = list(update = encodings)
  )
  
  list(data = list(list(name = "source", values = plot_data)),
       scales = scales,
       axes = axes,
       marks = list(marks)
       )
} 


render_shiny <- function(x) {
  pipeline <- attr(x$.tbl, "pipeline")
  n_stages <- length(pipeline)
  layers <- grep("draw", names(pipeline))
  controls <- grep("control", names(pipeline))
  
}