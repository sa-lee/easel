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

update <- reactive({ 
  ranges <- cols_reactive$event[[1]]()
  if (is.null(ranges)) {
    aes_fill <- "steelblue"
  } else {
    xrange <- ranges[c(1,2)]
    yrange <- ranges[c(3,4)]
    aes_fill <- dplyr::if_else(
      dplyr::between(pl$layer$aes_x, xrange[1], xrange[2]) &
        dplyr::between(pl$layer$aes_y, yrange[2], yrange[1]),
      "red",
      "steelblue"
    )
  }
  aes_fill
})

server <- function(input, output, session) {
  
  data <- mtcars %>%
    select(aes_x = hp, aes_y = mpg) 
  rownames(data) <- NULL
  
  update <- reactive({
    ranges <- c(input$drag_range_x, input$drag_range_y)
    if (is.null(ranges)) {
      aes_fill <- rep("steelblue", 32)
    } else {
      x <- data$aes_x
      y <- data$aes_y
      x <- unname(x)
      y <- unname(y)
      xrange <- ranges[c(1,2)]
      yrange <- ranges[c(3,4)]
      aes_fill <- dplyr::if_else(
        dplyr::between(x, xrange[1], xrange[2]) &
          dplyr::between(y, yrange[2], yrange[1]),
        "red",
        "steelblue"
      )
    }
    data[["aes_fill"]] <- aes_fill
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
    update()
  })
}

shinyApp(ui, server)
