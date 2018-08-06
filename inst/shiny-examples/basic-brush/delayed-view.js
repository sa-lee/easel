var view;

vega.loader()
    .load('https://api.myjson.com/bins/10r9dc')
    .then(function(data) { render(JSON.parse(data)); });

function render(spec) {
	view = new vega.View(vega.parse(spec))
            .renderer('canvas')  // set renderer (canvas or svg)
            .initialize('#view') // initialize view within parent DOM container
            .addSignalListener('brushX', function(name, value) {
              Shiny.onInputChange('xcoords', value);
              console.log(value);
            })
            .run();
    }

