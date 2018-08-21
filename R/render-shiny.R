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
    
    spec <- reactive({
      pl$layer$aes_fill <- data()
      to_vg_spec(pl) 
    })
    
    data <- reactive({ 
      ranges <- cols_reactive$event[[1]]()
      if (is.null(ranges)) {
        aes_fill <- "steelblue"
      } else {
        xrange <- ranges[c(1,2)]
        yrange <- ranges[c(3,4)]
        aes_fill <- dplyr::if_else(
          dplyr::between(pl$layer$aes_x, xrange[1], xrange[2]) &
            dplyr::between(pl$layer$aes_y, yrange[2], yrange[1]),
          "red",
          "steelblue"
        )
      }
      aes_fill
    })
    
    cols_reactive$event[[1]] <-  reactive({
      c(input$vis_drag_range_x, input$vis_drag_range_y)
    })
    
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
    
    output$cl <- shiny::renderPrint({
      spec()
    })
    
  }
  shiny::shinyApp(ui, server)
}