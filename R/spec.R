geom_to_vg_mark <- function(geom) {
  # so far only point needs to be mapped to symbol
  if (geom == "point") return("symbol")
  return(geom)
}

vg_range <- function(nm) {
  if (grepl("x", nm)) return("width")
  return("height")
}

aes_to_vg_encode <- function(mappings, geom) {
  
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
  
  signals_loc <- unlist(
    lapply(.tbl, 
           function(.x) any(vapply(.x, is_list_col_reactive, logical(1)))
    )
  )

  signals_data <- .tbl[signals_loc]
  
  scaffold$signals <- lapply(seq_along(signals_data),
            function(i) get_pipeline(signals_data[[i]])$signal()
    
  )
  names(scaffold$signals) <- NULL
  
  
  signal_update_marks <- vapply(seq_along(signals_data), 
                           function(i) "geom" %in% names(signals_data[[i]]),
                           logical(1))
  signal_marks <- vector("list", length = sum(signal_update_marks))
  
  signal_marks_data <- signals_data[signal_update_marks]
  # any marks triggered by signals
  for (i in seq_along(signal_marks_data)) {
    
    mapping <- get_mapping(signal_marks_data[[i]])
    signal_encoding <- lapply(mapping, 
                              function(.) 
                                list(signal = paste0("drag.", rlang::quo_name(.)))
    )
    
    signal_marks[[i]] <- list(
      type = signal_marks_data[[i]]$geom[1],
      encode = list(update = signal_encoding)
    )
  }

  
  scaffold$data[[1]] <- list(
    name = "source",
    values = dplyr::select(.tbl$layer, dplyr::starts_with("aes"))
  )
  
  aes_nms <- names(scaffold$data[[1]]$values)
  geoms <- .tbl$layer$geom[1]
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
    type = "symbol",
    from = list(data = scaffold$data[[1]]$name),
    encode = list(update = encodings)
  )
  
  scaffold$marks <- c(signal_marks, scaffold$marks)
  
  return(scaffold)
} 