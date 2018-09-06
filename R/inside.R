inside <- function(x, y, rect_model) {
  
  stopifnot(has_reactive_attr(rect_model))
  rect_model <- get_reactive_expr(rect_model)
  
  base_case <- rep(FALSE, length(x))
  
  x <- enquo(x)
  y <- enquo(y)
  
  expr <- rlang::quo({
    ranges <- !!rect_model
    if (is.null(ranges)){
      return(rep(FALSE, length(!!x)))
    } else {
      xrange <- ranges[c(1,2)]
      yrange <- ranges[c(3,4)]
      return(
        dplyr::between(!!x, xrange[1], xrange[2]) & 
          dplyr::between(!!y, yrange[2], yrange[1])
      )
    }
  })
  
  as_reactive_logical(base_case, expr)
}