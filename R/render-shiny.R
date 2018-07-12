# currently using mvc
# need to break up into more modular code, i.e pipeline stages

render_shiny <- function(x) {
  require(shiny)
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
  
  ui <- basicPage(
    click,
    drag,
    plotOutput(plot_div),
    tableOutput("info")
  )
  
  
  server <- function(input, output, session) {
    # compute plot data
    print(layers)
    print(controls)
    static_layer_pipeline <- pipeline[1:layers[layers < controls]]
    attr(x$.tbl, "pipeline") <- static_layer_pipeline
    static_data <- eval_pipeline(x$.tbl)
    
    interactive_layer <- pipeline[controls]
    print(interactive_layer)
    output$info <- renderTable(interactive_layer$control_drag(static_data, input$drag))
    
    output[[plot_div]] <- renderPlot({
      render(x$.tbl) 
    })
    onStop(function() attr(x$.tbl, "pipeline") <- pipeline)
  }
  shinyApp(ui, server)
  
}