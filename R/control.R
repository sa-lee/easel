
control_click <-  function() {
  expr <- rlang::expr(
    c(input$vis_click_x, input$vis_click_y)
  )
  
  data_model <- tibble::tibble(
    event = as_reactive_numeric(numeric(2), expr)
  )
  
  signal_callback <- function(.data) {
    build_plibble(.data, get_mapping(.data), list(signal = vg_click))
  }
  
  build_plibble(data_model,
                rlang::quos(x = aes_x, y = aes_y),
                list(signal_click = signal_callback))
  
}


control_drag <- function() {
  
  # this is eagerly evaluated not a callback,
  # invoking control_drag will return a new plibble
  expr <- rlang::expr(
    c(input$vis_drag_range_x, input$vis_drag_range_y)
  )
  
  rect_model <- tibble::tibble(
    event = as_reactive_numeric(numeric(4), expr)
  )
  
  signal_callback <- function(.data) {
    build_plibble(.data, get_mapping(.data), list(signal = vg_drag))
  }
  
  build_plibble(
    rect_model,
    rlang::quos(x = xmin, x2 = xmax, y = ymin, y2 = ymax),
    list(signal = signal_callback)
  )
  
}

