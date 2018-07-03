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

control_click <- function(.data) {
  fun = function(.data, .input = NULL) {
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


right_na <- function(type) {
  switch(type,
         character = NA_character_,
         double = NA_real_,
         integer = NA_integer_,
         logical = NA,
         complex = NA_complex_)
}

put_values <- function(.data, vals) {
  cols <- names(vals)
  na_vals <- lapply(vals, typeof)
  for (col in cols) {
    
    .data <- mutate(.data, UQ(col) := dplyr::case_when(
      event == TRUE ~ UQ(vals[[col]]),
      event == FALSE ~ "black"
    ))
  }
  .data
}

put <- function(.data, ...) {
  vals <- rlang::dots_list(...)
  fun <- put_values
  fn_fmls(fun)[2] <- list(vals = vals)
  .data$.tbl <- set_pipeline(.data$.tbl, list(put_values = fun))
  .data
}