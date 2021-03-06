#' just a brush
#' vis <- mtcars %>% visualise(x = hp, y = mpg) %>% draw_points()
#' brush <-  control_drag() %>% draw_rect(fill = "transparent", stroke = "black")
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
  which_reactives <- lapply(pl[which_encodings(pl)], 
                            function(x) dplyr::select_if(x, has_reactive_attr)
                            )
  
  which_reactives <- Filter(function(.) ncol(.) > 0, which_reactives)
  
  ui <- shiny::fluidPage(
    vegawidget::vegawidgetOutput("vis"),
    shiny::verbatimTextOutput("debug")
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
      
      stage_selection <- which_reactives[[1]]$sel
      # any updates based on selections
      # transient changes --
      pipeline <- get_pipeline(layer)
      mutate_stages <- setdiff(c("mutate", "mutate_persistent"), 
                                 names(pipeline))
      
      if (length(mutate_stages) == 1) {
        
        message("updating transiently")
        env_bind(get_reactive_env(stage_selection),
                         input = input)
        sel <-  shiny::reactive(
          get_reactive_expr(stage_selection),
          quoted = TRUE,
          env = get_reactive_env(stage_selection))
        print(sel)
        parse_new_data <- rlang::fn_fmls(pipeline$mutate)$dots
        parse_new_data <- parse_new_data[grep("^aes", names(parse_new_data))]
        print(parse_new_data)
        
        transient_updates <- shiny::reactive({
          lapply(parse_new_data,
                 function(.) rlang::env_bind(quo_get_env(.),
                                             sel = sel()))
          
          changeset <- mutate_eager(layer, !!!parse_new_data)
          jsonlite::toJSON(changeset, dataframe = "rows")
        })
        
        shiny::observe({
          changeset <- transient_updates()
          vegawidget:::vw_call_view("vis", "change",
                                    list(name = "source",
                                         data = changeset))
        })
      } else if (length(mutate_stages) == 0) {
        message("persisently updating stuff")
        parse_new_data <- rlang::fn_fmls(pipeline$mutate_persistent)$dots
        parse_new_data <- parse_new_data[grep("^aes", names(parse_new_data))]
        
      
        sel <- as.logical(stage_selection)
        
        # update_state <- shiny::reactive({
        #   cur_state <- selection()
        #   state <<- state | cur_state
        #   state
        # })
        
        renv <- child_env(get_reactive_env(stage_selection),
                          input = input,
                          sel = sel)
        selection <- shiny::reactive(expr({
          !!get_reactive_expr(stage_selection)
        })
        ,
        quoted = TRUE,
        env = renv)
        
        update_state <- reactive({renv$sel <<- selection()})
        
        
        
      }
      
          
      output$debug <- shiny::renderPrint({
        selection()
      })
    }
  }
  
  
  shiny::shinyApp(ui, server)
}
