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
  
  signals <- vg_signals()
  
  
  axes <- list(
    list(orient = "bottom", grid = TRUE, scale = "aes_x"),
    list(orient = "left", grid = TRUE, scale = "aes_y")
  )
  marks <- list(
    list(name = "layer",
         type = "symbol",
         from = list(data = "source"),
         encode = list(update = encodings)
    ),
    list(name = "brush",
         type = "rect",
         encode = list(enter = 
                         list(fill = list(value = "transparent")),
                       update = 
                         list("x" = list(signal = "brushX[0]"),
                              "x2" = list(signal = "brushX[1]"),
                              "y" = list(signal = "brushY[0]"),
                              "y2" = list(signal = "brushY[1]"),
                              "stroke" = list(value = "black"),
                              "strokeWidth" = list(value = 1))))
    )
  
  list(`$schema` =  "https://vega.github.io/schema/vega/v4.json",
       width = 200,
       height = 200,
       padding = 5,
       data = list(list(name = "source", values = plot_data)),
       signals = signals,
       scales = scales,
       axes = axes,
       marks = marks
       )
} 


render_shiny <- function(x) {
  pipeline <- attr(x$.tbl, "pipeline")
  n_stages <- length(pipeline)
  layers <- grep("draw", names(pipeline))
  controls <- grep("control", names(pipeline))
  
}