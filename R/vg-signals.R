#' place holders for some vega signals
#' 
vg_drag_x <- function() {
  list(name = "brushX", 
       value = "0",
       on = list(list(
         events = "mousedown",
         update = "[x(), x()]"),
         list(events = "[mousedown, window:mouseup] > window:mousemove!",
              update = "[brushX[0], clamp(x(), 0, width)]")
       ))
}

vg_drag_y <- function() {
  list(name = "brushY",
       value = "0",
       on = list(list(
         events = "mousedown",
         update = "[y(), y()]"),
         list(events = "[mousedown, window:mouseup] > window:mousemove!",
              update = "[brushY[0], clamp(y(), 0, height)]")
       ))
}

vg_drag <- function() {
  list(
    list(name = "drag",
         value = 0,
         on = list(
           list(
             events = "mousedown",
             update = "{xmin: x(), xmax: x(), ymin: y(), ymax: y()}"
           ),
           list(
             events = "[mousedown, window:mouseup] > window:mousemove",
             update = "{xmin: drag.xmin, xmax: clamp(x(), 0, width), ymin: drag.ymin, ymax:clamp(y(), 0, height)}"
           )
         )
    ),
    list(name = "drag_range_x",
         value = c(0,0),
         on = list(
           list(
             events = list(signal = "drag"),
             update = "invert('aes_x', [drag.xmin, drag.xmax])"
           )
         )
    ),
    list(name = "drag_range_y",
         value = c(0,0),
         on = list(
           list(
             events = list(signal = "drag"),
             update = "invert('aes_y', [drag.ymin, drag.ymax])"
           )
         )
    )
  )
}

vg_click <- function() {
  list(
    list(name = "click",
         value = 0,
         on = list(
           events = "click",
           update = "{xmin: }"
         )
         ),
    list(
      name = "click_range_x",
      value = 0,
      on = list(
        events = list(signal =  "click"),
        update = "invert('x', click.x)" 
      )
    ),
    list(
      name = click_range_y,
      value = 0,
      on = list(
        events = list(signal = "click"),
        update = "invert('y', click.y)" 
      )
    )
  )
}