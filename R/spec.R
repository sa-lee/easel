geom_to_vg_mark <- function(geom) {
  # so far only point needs to be mapped to symbol
  if (geom == "point") return("symbol")
  return(geom)
}

vg_range <- function(nm) {
  if (grepl("x", nm)) return("width")
  return("height")
}

vg_scaffold <- function(width, height) {
  list(`$schema` = "https://vega.github.io/schema/vega/v4.json",
       width = width, 
       height = height,
       signals = list(),
       data = list(),
       scales = list(),
       axes = list(),
       marks = list()
       )
}

# a very minimal vega spec, for a single layer only!
to_vg_spec <- function(.tbl) {
  scaffold <- vg_scaffold(height = 200, width = 200)
  
  scaffold$signals <- attr(.tbl, "signal")
  
  scaffold$data[[1]] <- list(
    name = "source",
    values = dplyr::select(.tbl, dplyr::starts_with("aes"))
  )
  
  aes_nms <- names(scaffold$data[[1]]$values)
  scaffold$scales <- vector("list", length(aes_nms))
  encodings <- vector("list", length(aes_nms))
  names(encodings) <- gsub("aes_", "", aes_nms)
  
  
  # only works for continuous scales at the moment
  for (i in seq_along(aes_nms)) {
    scaffold$scales[[i]] <- list(name = aes_nms[[i]],
                        type = "linear",
                        round = TRUE,
                        nice = TRUE,
                        domain = list(data = "source", field = aes_nms[[i]]),
                        range = vg_range(aes_nms[[i]]))
    encodings[[i]] <- list(scale = aes_nms[[i]],
                                          field = aes_nms[[i]])
  }

  scaffold$axes[[1]] <- list(orient = "bottom", 
                             grid = TRUE, 
                             scale = "aes_x")
  scaffold$axes[[2]] <- list(orient = "left", 
                             grid = TRUE, 
                             scale = "aes_y")
  
  scaffold$marks[[1]] <- list(
    name = "layer",
    type = "symbol",
    from = list(data = "source"),
    encode = list(update = encodings)
  )
  
  return(scaffold)
} 