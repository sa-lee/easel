# currently using mvc
# need to break up into more modular code, i.e pipeline stages


render_shiny <- function(x) {
  require(shiny)
  
  
  pipeline <- attr(x$.tbl, "pipeline")
  has_click_event <- names(pipeline) == "control_click"
  has_drag_event <- names(pipeline) == "control_drag"
  
  if (any(has_click_event)) {
    click_handler <- pipeline[has_click_event][[1]]
    click <- clickOpts("click")
  } else {
    click <- NULL
  } 
  
  if (any(has_drag_event)) {
    drag_handler <- pipeline[has_drag_event][[1]]
    drag <- brushOpts("drag")
  } else {
    drag <- NULL
  }
  
  
  ui <- basicPage(
    plotOutput("plot1", click = click, brush = drag),
    verbatimTextOutput("info")
  )
  
  
  server <- function(input, output, session) {
    # compute plot data
    output$info <- renderPrint({
      handlers()
      print(filter(eval_pipeline(x$.tbl), event == TRUE))
      print(input$drag)
    })
    
    
    handlers <- reactive({
      if (any(has_click_event)) {
        attr(x$.tbl, "pipeline") <- modify_funlist(attr(x$.tbl, "pipeline"),
                                                   "control_click",
                                                   function(.data) {
                                                     click_handler(.data, input$click)
                                                   })  
      }
      
      if (any(has_drag_event)) {
        attr(x$.tbl, "pipeline") <- modify_funlist(attr(x$.tbl, "pipeline"),
                                                   "control_drag",
                                                   function(.data) {
                                                     drag_handler(.data, input$drag)
                                                   })  
      }
    })
    # modify click event function
    
    output$plot1 <- renderPlot({
      handlers()
      render(x$.tbl)
    })
    
    onStop(function() attr(x$.tbl, "pipeline") <- pipeline)
  }

  shinyApp(ui, server)
}