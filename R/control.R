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
#   filter(is_clicked) %>%
#   put_vals(colour = "red", t = .)
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
                                         tol = 0.1) &&
                                  dplyr::near(rlang::UQ(mapping_y),
                                         rlang::UQ(values_y),
                                         tol = 0.1))
      dplyr::mutate(.data, is_clicked = rlang::UQ(filter_vals))
    } else {
      dplyr::mutate(.data, is_clicked = FALSE)
    }
  }
  set_pipeline(.data, list(control_press = fun))
}

push_up <- function(.data, event) {
  pipeline <- get_pipeline(.data)
  
}

render_shiny <- function(x) {

  require(shiny)
  ui <- basicPage(
    plotOutput("plot1")
  )
  
  server <- function(input, output) {
    
    data <- reactive(x)
    
    output$plot1 <- renderPlot({
      render(data())
    })

  }
  shinyApp(ui, server)
}