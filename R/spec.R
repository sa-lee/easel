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
       width = NULL, 
       height = NULL,
       signals = list(),
       data = list(),
       scales = list(),
       axes = list(),
       marks = list()
       )
}

# a very minimal vega spec, for a single layer only!
to_vg_spec <- function(.tbl) {
  scaffold <- vg_scaffold()
  
  signals_loc <- which_signals(.tbl)

  signals_data <- .tbl[signals_loc]
  
  scaffold$signals <- lapply(seq_along(signals_data),
            function(i) get_pipeline(signals_data[[i]])$signal()
    
  )

  scaffold$signals <- unlist(scaffold$signals, recursive = FALSE)
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
    
    # any other opts?
    opts_data <- dplyr::select(signal_marks_data[[i]], 
                               dplyr::starts_with("opts"))
    if (ncol(opts_data) > 0) {
      names(opts_data) <- gsub("opts_", "", names(opts_data))
      opts_list <- lapply(names(opts_data),
                          function(col) {
                           list(value = opts_data[[col]][1])
                          })
      names(opts_list) <- names(opts_data)
      signal_encoding <- c(signal_encoding, opts_list)
    }
    
    
    
    signal_marks[[i]] <- list(
      type = signal_marks_data[[i]]$geom[1],
      encode = list(update = signal_encoding)
    )
  }

  data_marks <- which_encodings(.tbl)
  
  if (sum(data_marks) != 1) {
    stop("multiple layers not currently supported")
  }
  
  layer <- .tbl[data_marks][[1]]
  
  scaffold$data[[1]] <- list(
    name = "source",
    values = dplyr::select(layer, dplyr::starts_with("aes"))
  )
  
  aes_nms <- names(scaffold$data[[1]]$values)
  geoms <- layer$geom[1]
  scaffold$scales <- vector("list", length(setdiff(aes_nms,c("aes_x", "aes_x"))))
  encodings <- vector("list", length(aes_nms))
  names(encodings) <- gsub("aes_", "", aes_nms)
  
  
  # only works for continuous scales at the moment
  for (i in seq_along(aes_nms)) {
    current_aes <- aes_nms[[i]]
    if (current_aes %in% c("aes_x", "aes_y")) {
      scaffold$scales[[i]] <- list(name = current_aes,
                                   type = "linear",
                                   round = TRUE,
                                   nice = TRUE,
                                   domain = list(data = "source", field = current_aes),
                                   range = vg_range(current_aes))
      encodings[[i]] <- list(scale = current_aes, 
                             field = current_aes)
    } else {
      encodings[[i]] <- list(field = current_aes)
    }
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