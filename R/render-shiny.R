render_shiny <- function(x) {
  
  load_shiny <- require("shiny", quietly = TRUE) || 
    stop("Please install shiny...")
  
  plot_div <- "pl"
  
  pipeline <- attr(x$.tbl, "pipeline")
  n_stages <- length(pipeline)
  layers <- grep("draw", names(pipeline))
  
  controls <- grep("control", names(pipeline))
  
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
    
  ui <- shiny::basicPage(
    vegaliteSpecOutput('pl'),
    tags$script(click_handler_js())
  )
  
  server <- function(input, output) {
    
    spec <- to_vl_spec(eval_pipeline(x$.tbl))
    output$pl <- renderVegaliteSpec(vl)
    observe({if(!is.null(input$click)) print(input$click)})
    
  }
  shiny::shinyApp(ui, server)
}