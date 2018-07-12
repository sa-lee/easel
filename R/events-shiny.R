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

project_pxcoords_rect <- function(.data, .emitted) {
  if (is.null(.emitted)) return(data.frame(aes_xmin = numeric(0), 
                                          aes_ymin = numeric(0), 
                                          aes_xmax = numeric(0), 
                                          aes_ymax = numeric(0)))
  start_x <- .emitted$start_x
  start_y <- .emitted$start_y
  end_x <- .emitted$end_x
  end_y <- .emitted$end_y
  width <- .emitted$width
  height <- .emitted$height
  # this doesnt take into account plot margins but will do for now
  data.frame(aes_xmin = start_x*(diff(range(.data[["aes_x"]]))/width), 
             aes_ymin = (height - start_y)*(diff(range(.data[["aes_y"]]))/height),
             aes_xmax = (end_x*(diff(range(.data[["aes_x"]]))/width)),
             aes_ymax = (height - end_y)*(diff(range(.data[["aes_y"]]))/height))
}


is_clicked <- function(.data, .emitted) {
  if (nrow(.emitted) > 0) {
    .clicked <- project_pxcoords_points(.data, .emitted)
    dplyr::near(.data[["aes_x"]], .clicked[["aes_x"]], tol = 0.1) &
      dplyr::near(.data[["aes_y"]], .clicked[["aes_y"]], tol = 0.1)
  } else {
    rep(FALSE, nrow(.data))
  }
}