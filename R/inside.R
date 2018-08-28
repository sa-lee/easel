inside <- function(x, y, rect) {
  reactive({
    ranges <- rect()
    if (is.null(ranges)) {
      return(rep(FALSE, length(x)))
    } else {
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
}