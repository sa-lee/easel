# Testing we can use vega signal listeners to return data back to
# R
library(shiny)
devtools::load_all("~/easel/")

ui <- fluidPage(
  tags$head(
    tags$title("Brush coords to server side"),
    tags$script(src = "https://cdn.jsdelivr.net/npm/vega@4.2.0"),
    includeScript("delayed-view.js")
  ),
  tags$div(id = "view")
)

server <- function(input, output, session) {
  p <- mtcars %>% 
    visualise(x = hp, y = mpg) %>% 
    draw_points() %>% 
    control_drag() %>% 
    draw_rect()
  message <- p %>% eval_pipeline() %>% to_vg_spec()
  session$sendCustomMessage("spec", 
                            jsonlite::toJSON(message, 
                                             pretty = TRUE, 
                                             auto_unbox = TRUE))
  
}

shinyApp(ui, server)
