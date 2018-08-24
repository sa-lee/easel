var view;
var source;
var previous_hash = null;
var hash;

Shiny.addCustomMessageHandler("source",
  function(message) {
    source = message.data;
    hash = message.hash;
    // initial insert
    if (previous_hash === null) {
      view.insert('source', source);
      previous_hash = hash;
    }
    
    if (previous_hash == hash) {
      console.log("no need to update");
    } else {
      console.log("now would be a good time");
      prev = view.data('source').slice();
      view.change('source', vega.changeset().remove(prev).insert(source));
      previous_hash = hash;
    }
    view.run();
  }
);

vega.loader()
    .load('https://api.myjson.com/bins/nfgdk')
    .then(function(data) { render(JSON.parse(data)); });

function render(spec) {
	view = new vega.View(vega.parse(spec))
            .renderer('canvas')  // set renderer (canvas or svg)
            .initialize('#view') // initialize view within parent DOM container
            .addSignalListener('drag', function(name, value) {
              Shiny.onInputChange('drag', view.data('source').slice());
            })
            .addSignalListener('drag_range_x', function(name, value) {
              Shiny.onInputChange('drag_range_x', value);
            })
            .addSignalListener('drag_range_y',  function(name, value) {
              Shiny.onInputChange('drag_range_y', value);
            })
    }

