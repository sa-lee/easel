var view;
var url = window.location.href + 'spec';

vega.loader()
    .load(url)
    .then(function(data) { render(JSON.parse(data)); });

function render(spec) {
	view = new vega.View(vega.parse(spec))
            .renderer('canvas')  // set renderer (canvas or svg)
            .initialize('#view') // initialize view within parent DOM container
            .run();
    }

