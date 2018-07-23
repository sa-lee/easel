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

# a very minimal vegalite spec
to_vl_spec <- function(.data) {
  plot_data <- dplyr::select(.data, dplyr::starts_with("aes"))
  mark <- .data[["geom"]][1]
  encodings <- vector("list", ncol(plot_data))
  names(encodings) <- sub("aes_", "", names(plot_data))
  for (i in seq_along(encodings)) {
    encodings[[i]] <- list(field = names(plot_data)[[i]], 
                           type = vl_types(plot_data[[i]]))
  }
  list(data = list(values = plot_data),
       mark = mark,
       encoding = encodings)
} 


render_shiny <- function(x) {
  pipeline <- attr(x$.tbl, "pipeline")
  n_stages <- length(pipeline)
  layers <- grep("draw", names(pipeline))
  controls <- grep("control", names(pipeline))
  
  plot_div <- "pl"
  if (any(names(pipeline) == "control_click")) {
    click <- tags$script(click_handler_js(plot_div))
  } else {
    click <- NULL
  } 
  
  if (any(names(pipeline) == "control_drag")) {
    drag <- tags$script(drag_handler_js(plot_div))
  } else {
    drag <- NULL
  }
  
  require(htmltools)
  static_plot <- render(x$.tbl)
  dir <- tempdir()
  tmp <- tempfile(fileext = ".png")
  img <- ggplot2::ggsave(tmp, 
                         static_plot,
                         path = dir,
                         width = 6, 
                         height = 4, 
                         units = "cm", 
                         dpi = 320)
  
  doc <- 
    tags$div(
      tags$canvas(id = plot_div),
      tags$script(
        add_img_canvas(plot_div, tmp)
      )
    )
  save_html(doc, file = paste0(dir, "/index.html"))
  
  servr::httd(dir = dir)
}