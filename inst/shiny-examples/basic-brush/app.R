# Testing we can use vega signal listeners to return data back to
# R
library(shiny)

ui <- fluidPage(
  tags$head(
    tags$title("Brush coords to server side"),
    tags$script(src = "https://cdn.jsdelivr.net/npm/vega@4.2.0"),
    includeScript("delayed-view.js")
  ),
  tags$div(id = "view")
)

server <- function(input, output, session) {
  observeEvent(input$xcoords, {
    cat("Brushing xcoords: ", input$xcoords, sep = "\n") 
  })
}

shinyApp(ui, server)
