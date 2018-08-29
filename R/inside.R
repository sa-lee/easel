inside <- function(x, y, rect_model) {
  
  callback <- function(x, y, rect_model) ({
    ranges <- rect_model
    if (is.null(ranges)) {
      return(rep(FALSE, length(x)))
    } else {
      xrange <- ranges[c(1,2)]
      yrange <- ranges[c(3,4)]
      return(
        dplyr::between(x, xrange[1], xrange[2]) & 
          dplyr::between(y, yrange[2], yrange[1])
      )
    }
  })
  
  rlang::fn_fmls(callback) <- list(x = x, 
                                   y = y,
                                   rect_model = rect_model)
  callback
}