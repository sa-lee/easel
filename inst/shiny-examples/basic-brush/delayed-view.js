var view;
var test_spec;

// we can pass in a spec to a global var
Shiny.addCustomMessageHandler('spec',  function(message) {
  test_spec = message;
});

console.log(test_spec);

// create an array of closures with callbacks to shiny
// if a signal is present
//var signal_listeners = test_spec.signals.map(function(v) {return(function() { 
//    addSignalListner(v.name, function(name, value) {
//      Shiny.onInputChange(v.name, value);
//    }); 
//  }); 
//});
    
// vega.loader()
//    .load('https://api.myjson.com/bins/10r9dc')
//    .then(function(data) { render(JSON.parse(data)); });

function render(spec) {
	view = new vega.View(vega.parse(spec))
            .renderer('canvas')  // set renderer (canvas or svg)
            .initialize('#view') // initialize view within parent DOM container
            .run();
    }
    
render(test_spec);


