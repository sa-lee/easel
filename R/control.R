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
control_click <- function(.data) UseMethod("control_click") 

control_click.mutibble <- function(.data) {
  fun <- function(.data, .input = NULL) {
    if (length(.input) > 0) {
      # this is very shiny dependent 
      mapping_x <- rlang::sym(.input$mapping[["x"]])
      mapping_y <- rlang::sym(.input$mapping[["y"]])
      values_x <- .input$x
      values_y <- .input$y
      filter_vals <- rlang::quo(dplyr::near(rlang::UQ(mapping_x), 
                                         rlang::UQ(values_x), 
                                         tol = 0.1) &
                                  dplyr::near(rlang::UQ(mapping_y),
                                         rlang::UQ(values_y),
                                         tol = 0.1))
      return(mutate(.data, event = rlang::UQ(filter_vals)))
    } 
    mutate(.data, event = FALSE)
  }
  .data$.tbl <- set_pipeline(.data$.tbl, list(control_click = fun))
  .data
}

control_drag <- function(.data) { UseMethod("control_drag") }

control_drag.mutibble <- function(.data) {
  fun <- function(.data, .input = NULL) {
    if (length(.input) > 0) {
      # this is very shiny dependent 
      mapping_x <- rlang::sym(.input$mapping[["x"]])
      mapping_y <- rlang::sym(.input$mapping[["y"]])
      values_x_left <- .input$xmin
      values_x_right <- .input$xmax
      values_y_left <- .input$ymin
      values_y_right <- .input$ymax
      filter_vals <- rlang::quo(dplyr::between(UQ(mapping_x), 
                                               UQ(values_x_left),
                                               UQ(values_x_right)) &
                                  dplyr::between(UQ(mapping_y),
                                                 UQ(values_y_left),
                                                 UQ(values_y_right)))
      return(mutate(.data, event = rlang::UQ(filter_vals)))
    } 
    mutate(.data, event = FALSE)
  }
}

