library(plumber)

#* @assets ./www
list()

#' Simple Webpage
#' @get / 
#' @html
ui <- function() {
  as.character(
    htmltools::tagList(
      htmltools::tags$script(src = "https://cdn.jsdelivr.net/npm/vega@4.2.0"),
      htmltools::tags$script(src = 'public/delayed-view.js'),
      htmltools::tags$body(
        htmltools::tags$div(id = "view")
      )
    )
  )
}

devtools::load_all(here::here())
library(magrittr)

tbl <- mtcars %>% 
  visualise(x = hp, y = mpg) %>% 
  draw_points() %>% 
  eval_pipeline()

#' spec generator
#' @get /spec
#' @serializer unboxedJSON
spec <- function() {
  to_vg_spec(tbl)
}




