# Testing we can use vega signal listeners to return data back to
# R
library(shiny)
library(dplyr)

ui <- fluidPage(
  tags$head(
    tags$title("Brush coords to server side"),
    tags$script(src = "https://cdn.jsdelivr.net/npm/vega@4.2.0"),
    includeScript("delayed-view.js")
  ),
  tags$div(id = "view"),
  shiny::verbatimTextOutput("cl")
)

server <- function(input, output, session) {
  
  data <- mtcars %>%
    select(aes_x = hp, aes_y = mpg) 
  rownames(data) <- NULL
  
  sel <- reactive({
    ranges <- c(input$drag_range_x, input$drag_range_y)
    if (is.null(ranges)) {
      return(rep(FALSE, nrow(data)))
    } else {
      x <- data$aes_x
      y <- data$aes_y
      x <- unname(x)
      y <- unname(y)
      xrange <- ranges[c(1,2)]
      yrange <- ranges[c(3,4)]
      return(
        dplyr::between(x, xrange[1], xrange[2]) & 
          dplyr::between(y, yrange[2], yrange[1])
      )
    }
  })
  
  current_state <- reactive({
    vapply(input$view_state$source, function(.x) .x[["sel"]], logical(1))
  })
  
  update <- reactive({
    state <- current_state()
    if (length(state) == 0L) {
      cur_sel <- sel()
    } else {
      cur_sel <- sel() | state
    }
    data[["sel"]] <- cur_sel
    data[["aes_fill"]] <- dplyr::if_else(data[["sel"]], "red", "steelblue")
    data
  })
  
  observe({
    source <- update()
    hash <- digest::digest(source)
    session$sendCustomMessage(type = "source",
                              message = list(data = jsonlite::toJSON(source),
                                             hash = hash))
  })
  
  output$cl <- shiny::renderPrint({
    current_state()
  })
}

shinyApp(ui, server)
