# currently using mvc
# need to break up into more modular code, i.e pipeline stages

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
  tmp <- "temp.png"
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