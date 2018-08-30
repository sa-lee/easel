#' just a brush
#' vis <- mtcars %>% visualise(x = hp, y = mpg) %>% draw_points()
#' vis_b <- vis %>% control_drag("brush") %>% draw_rect()
#' transient brush with highlight
#' vis_t <- vis_b %>% mutate_layer("points", 
#'                                 sel = inside(aes_x, aes_y, .brush$event),
#'                                 aes_fill = ifelse(sel, "black", "white")
#'                                 )
#' persisent selection brush
#' vis_p <- vis_b %>% 
#'                mutate_layer("points", sel = FALSE) %>% 
#'                let(sel = sel | inside(aes_x, aes_y, .brush$event))
render_shiny <- function(x) {
  pl <- eval_pipeline(x)
  spec <- to_vg_spec(pl)
  
  signal_listeners <- vapply(spec$signals, 
                             function(.) .[["name"]], 
                             character(1))

  layer_has_reactives <- which_signals(pl)
  
  which_reactives <- lapply(pl[layer_has_reactives], 
                            function(x) dplyr::select_if(x, has_reactive_attr)
  )
  
  
  ui <- shiny::fluidPage(
    vegawidget::vegawidgetOutput("vis"),
    shiny::verbatimTextOutput("cl")
  )
  
  server <- function(input, output, session) {
    
    output$vis <- vegawidget::renderVegawidget({
      
      vl <- vegawidget::vegawidget(vegawidget::as_vegaspec(spec), 
                                   height = 400, 
                                   width = 400)
      
      for (signal in signal_listeners) {
        vl <- vegawidget::vw_add_signal_listener(vl, signal)
      }
      vl 
    })
    
    brush <-  shiny::reactive({get_reactive_expr(which_reactives[[1]]$event)},
                              quoted = TRUE)
    output$cl <- shiny::renderPrint({
      brush()
    })
    
  }
  shiny::shinyApp(ui, server)
}