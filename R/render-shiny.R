#' just a brush
#' vis <- mtcars %>% visualise(x = hp, y = mpg) %>% draw_points()
#' vis_b <- vis %>% control_drag() %>% draw_rect()
#' transient brush with highlight
#' vis_t <- vis %>% mutate(
#'                          sel = inside(aes_x, aes_y, vis_b$event),
#'                          aes_fill = ifelse(sel, "black", "white")
#'                         ) %>%
#'                         mesh(vis_b)
#' persisent selection brush
#' vis_p <- vis %>% 
#'                mutate(sel = FALSE) %>% 
#'                mutate_persistent(sel = sel | inside(aes_x, aes_y, vis_b$event)) %>%
#'                mesh(vis_b)
render_shiny <- function(x) {
  pl <- invoke_pipeline(x)
  spec <- to_vg_spec(pl)
  
  signal_listeners <- vapply(spec$signals, 
                             function(.) .[["name"]], 
                             character(1))
  which_reactives <- lapply(pl, 
                            function(x) dplyr::select_if(x, has_reactive_attr)
  )
  which_reactives <- Filter(function(.) ncol(.) > 0, which_reactives)
  
  
  
  
  ui <- shiny::fluidPage(
    vegawidget::vegawidgetOutput("vis"),
    shiny::verbatimTextOutput("cl")
  )
  
  server <- function(input, output, session) {
    vl <- vegawidget::vegawidget(spec, 
                                 height = 400, 
                                 width = 400)
    
    if (length(signal_listeners) > 0) {
      for (signal in signal_listeners) {
        vl <- vegawidget::vw_add_signal_listener(vl, signal)
      }
    }
    
    
    output$vis <- vegawidget::renderVegawidget({
      vl 
    })
    
    # selection stages
    if (length(which_reactives) > 0) {
      layer <- dplyr::select(pl[[1]], dplyr::starts_with("aes"))
      
      sel <-  shiny::reactive({
        get_reactive_expr(which_reactives[[1]]$sel)
      }, quoted = TRUE)
      
      parse_new_data <- rlang::fn_fmls(get_pipeline(layer)$mutate)$dots
      parse_new_data <- parse_new_data[grep("^aes", names(parse_new_data))] 
      
      updates <- shiny::reactive({
        lapply(parse_new_data, 
               function(.) rlang::env_bind(quo_get_env(.),
                                           sel = sel()))
        
        changeset <- mutate_eager(layer, !!!parse_new_data)
        jsonlite::toJSON(changeset, dataframe = "rows")
      })
      
      observe({
        changeset <- updates()
        vegawidget:::vw_call_view("vis", "change",
                                  list(name = "source",
                                       data = changeset)
        )
        
      })
    }
 
    output$cl <- shiny::renderPrint({ 
      list(
        c(input$vis_drag_range_x, input$vis_drag_range_y),
        sel(),
        jsonlite::fromJSON(updates())
      )
    })
    
  }
  shiny::shinyApp(ui, server)
}
