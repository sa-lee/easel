# Control triggers some kind of event to be placed into a mutibble:
#  - first we pin a data frame down creating a mutable table
# this stores the table and a reference to itself, any downstream operations
# get evaluated in the reference
# p <- pin(mtcars)
# 
# define a scatter plot
# scatter <- p %>% 
#           visualise(x = mpg, y = wt) %>% 
#           draw_points()
# # a click event, adds a column called is_clicked
# when is_clicked is TRUE , the mutibble has the value colour = "red" inserted
# into it.
# control_click() 
# clicker_highlight <- p %>%
#   control_click() %>%
#   put(colour = "red")
# 
# an interactive graphic, p contains all the information necessary to build
# a plot
# render(p)
control_click <- function(.data, handler) UseMethod("control_click") 

control_click.mutibble <- function(.data, handler) {
  .data$.tbl <- set_pipeline(.data$.tbl, list(control_click = handler))
  .data
}


control_drag <- function(.data, handler) { UseMethod("control_drag") }

control_drag.tbl_pl <- function(.data, handler) {
  fun <- function(.data) {
    rect_model <- tibble::tibble(control = list(shiny::reactive({input$drag })))
    tbl <- build_plibble(
      rect_model,
      rlang::quos(x = xmin, x2 = xmax, y = ymin, y2 = ymax),
      list(signal = vg_drag)
    )
    c(.data, list(tbl))
  }
  
  set_pipeline(.data, list(control_drag = fun))
}

control_drag.mutibble <- function(.data, handler) {
  .data$.tbl <- set_pipeline(.data$.tbl, list(control_drag = handler))
  .data
}

