render_shiny <- function(x) {
  require(shiny)
  
  pipeline <- attr(x$.tbl, "pipeline")
  has_click_event <- names(pipeline) == "control_click"
  click_handler <- pipeline[has_click_event][[1]]
  if (any(has_click_event)) click <- clickOpts(id = "control_click")
  
  
  ui <- basicPage(
    plotOutput("plot1", click = "hello"),
    verbatimTextOutput("info")
  )
  
  
  server <- function(input, output) {
    # compute plot data
    output$info <- renderPrint({
      filter(plot_data(), event == TRUE)
    })
    
    
    data <- reactive({
      x$.tbl
    })
    
    plot_data <- reactive({

      attr(x$.tbl, "pipeline") <- modify_funlist(attr(x$.tbl, "pipeline"),
                                                 "control_click",
                                                 function(.data) {
                                                   click_handler(.data, input$hello)
                                                 })
      
      eval_pipeline(x$.tbl)
    })
    # modify click event function
    
    output$plot1 <- renderPlot({
      ggplot(plot_data(), aes(x = aes_x, y = aes_y)) + geom_point(aes(colour = colour))
    })
    
  }
  shinyApp(ui, server)
}