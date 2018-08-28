render_vega <- function(x) {
  pl <- eval_pipeline(x)
  
  spec <- jsonlite::toJSON(to_vg_spec(pl), 
                           pretty = TRUE, 
                           auto_unbox = TRUE)
  
  vegawidget::vegawidget(spec)

}