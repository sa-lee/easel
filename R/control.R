#' Idea for interactive elements
#' - place the layers data into a reactive data.frame
#' - this adds an event column to the plot data frame
#' - the event plus data 
control_press <- function(.data) {
  fun = function(.data, .press) {
    if (missing(.press)) {
      mutate(.data, event = "press")
    } else {
      message("hello")
    }
  }
  set_pipeline(.data, list(control_press = fun))
  
}


shiny_render <- function(x) {
  events <- Filter(function(.x) colnames(.x) %in% "event", x)
  
  require(shiny)
  ui <- basicPage(
    plotOutput("plot1", click = "plot_pressed"),
    verbatimTextOutput("info")
  )
  
  server <- function(input, output) {
    
    data <- reactive({
      eval_pipeline(x)
    })
    output$plot1 <- renderPlot({
      ggplot(mtcars, aes(x=wt, y=mpg)) + geom_point()
    })

  }
  shinyApp(ui, server)
}