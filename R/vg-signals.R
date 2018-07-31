
vg_signals <- function() {
  list(list(name = "brushX", 
            value = "0",
            on = list(list(
              events = "mousedown",
                      update = "[x(), x()]"),
              list(events = "[mousedown, window:mouseup] > window:mousemove!",
                   update = "[brushX[0], clamp(x(), 0, width)]")
              )),
       list(name = "brushY",
            value = "0",
            on = list(list(
              events = "mousedown",
              update = "[y(), y()]"),
              list(events = "[mousedown, window:mouseup] > window:mousemove!",
                   update = "[brushY[0], clamp(y(), 0, height)]")
            )))
}