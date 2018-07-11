# Place holders for events for sending data from shiny back to R
# ideally these should be handled without JS or shiny but for now they are
# ok these are placed in the script tag of 

click_handler_js <- function(plot_div) {
  js_fun <- "$(function(){ 
    $(plot_div).click(function(e) {
      var output = {};
      output.coord_x = e.clientX;
      output.coord_y = e.clientY;
      output.width = $(plot_div).width();
      output.height = $(plot_div).height();
      Shiny.onInputChange('click', output)
    });
  }) 
 "
  stringr::str_replace_all(js_fun, "plot_div", plot_div)
}

drag_handler_js <- function(plot_div) {
  js_fun <- "$(function(){
    var is_drawing = false;
    var output = {};
    output.width = $(plot_div).width();
    output.height = $(plot_div).height();
    $(plot_div).on('dragstart', function(e) { e.preventDefault()});
    $(plot_div).mousedown(function(e) {
      is_drawing = true;
      output.start_x = e.clientX;
      output.start_y = e.clientY;
    }).mousemove(function(e) {
      if (is_drawing) {
        console.log('moving')
      }
    }).mouseup(function(e) {
      is_drawing = false;
      output.end_x = e.clientX;
      output.end_y = e.clientY
      console.log('not moving');
      console.log(output);
      Shiny.onInputChange('drag', output);
    });
  })"
  stringr::str_replace_all(js_fun, "plot_div", plot_div)
}


# simple projection
project_pxcoords_points <- function(.data, .emitted) {
  coord_x <- .emitted$coord_x
  coord_y <- .emitted$coord_y
  width <- .emitted$width
  height <- .emitted$height
  # this doesnt take into account plot margins but will do for now
  data.frame(aes_x = coord_x*(diff(range(.data[["aes_x"]]))/width), 
             aes_y = (height - coord_y)*(diff(range(.data[["aes_y"]]))/height))
}
