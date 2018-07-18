# set up a canvas tag

add_img_canvas <- function(id, img) {
  paste0(
    "var canvas = document.getElementById('", id, "');",
    "var context = canvas.getContext('2d');",
    "var plot = new Image();",
    "plot.src='", img, "';",
    "plot.onload = function() {",
    "canvas.height = this.naturalHeight; canvas.width = this.naturalWidth;",
    "context.drawImage(plot,0,0);",
    "context.drawImage(plot, 0, 0, this.width, this.height);}"
    )
}

new_canvas <- function(id, height, width, ...) {
  paste0('<canvas id="',
         id,
         '", height="', 
         height,
         '", width="',
         width, '"\n',
         ...,
         '</canvas>'
  )
}