render_shiny <- function(x) {

  pl <- eval_pipeline(x)
  
  signals_loc <- which_signals(pl)
  
  signals_reactives <- pl[signals_loc]
  cols_reactive <- signals_reactives[[1]]
  
  ui <- shiny::fluidPage(
    vegawidget::vegawidgetOutput("vis"),
    shiny::verbatimTextOutput("cl")
  )
  
  server <- function(input, output, session) {
    spec <- reactive({ to_vg_spec(pl) })
    
    output$vis <- vegawidget::renderVegawidget({
      vegawidget::vw_add_signal_listener(
        vegawidget::vw_add_signal_listener(
          vegawidget::vegawidget(vegawidget::as_vegaspec(spec()), 
                                 height = 400, 
                                 width = 400),
          "drag_range_x"
        ),
        "drag_range_y"
      )
    })
    

    cols_reactive$event[[1]] <-  observe({
      c(input$vis_drag_range_x, input$vis_drag_range_y)
    })
    
    
    output$cl <- shiny::renderPrint({
      cols_reactive$event[[1]]()
    })
    
  }
  shiny::shinyApp(ui, server)
}