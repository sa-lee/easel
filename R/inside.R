inside <- function(x, y, rect_model) {
  
  base_case <- rep(FALSE, length(x))
  
  expr <- shiny::reactive({
    if (is.null(rect_model)){
      return(rep(FALSE, length(x)))
    } else {
      xrange <- rect_model[c(1,2)]
      yrange <- rect_model[c(3,4)]
      return(
        dplyr::between(x, xrange[1], xrange[2]) & 
          dplyr::between(y, yrange[2], yrange[1])
      )
    }
  })
  
  as_reactive_logical(base_case, expr)
}