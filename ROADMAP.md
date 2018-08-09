# Roadmap

## Timeline

I have about two months remaining in the Bay Area to get this package into shape
The goal is to have a subset of the API  working + a draft of the paper 
before I finish up here. I also need a better name for the package...

The overall design of the grammar is in place, in that it is possible
to express a lot of the graphics we want to create, now we have to focus on its 
implementation. As far as a subset of the features go: the aim is to have the
following working:

- [ ] brush and highlight (transient)
- [ ] brush and hightlight (persistent)
- [ ] wheel zoom
- [ ] linked brushing (example, histogram linked to scatterplot)


## Implementation

There is the user facing interface (computations done in R)
and and client side interface which is JS. 

### R

At the moment we have the idea of having different "backends", one
for static plots rendered with ggplot2 and other backends for interactivity
Vega + shiny or just Vega. On the R side, there are the following 
conceptual issues that I need to sort out:

- triggering layers via draw and or control, is a list of data frames a 
good way of doing this?

- representing the output of a control_*, we want to make it explicit 
that the output of a layer this is probably best represnted
as a `reactive` data frame using shiny.

- modifiying aesthetics and graphical options via mutate (how to make it 
clear to a user which layer they are updating) + in the interactive
context expressing relationships between layers.

- order of evaluation for graphics pipeline: some ops i.e. scaling should
be performed at the end of pipeline?

- compiling down to a spec for vega (mostly sorted but need to think
about signal representation in relation to the graphics pipeline)

- how to represent linking in the grammar (natural to think of it as a join?)

### JS

htmlwidgets + Vega (+ shiny), currently kinda hacking at this but could
be better integreated with vegawidgets. 

For this work, need to use the View API
so we can add listeners to signals + dynamically insert/update/transform 
data. Where possible we could push everything client side essentially
using JS like we would use C/C++ for computations in R.

-  we need to first parse the spec before creating the view object
-  once we have a view object we can add signal listeners if there are signals
in the spec
- have the data represented as a url if not local or large?
- at runtime it would be great to perfom any of the transformations/summaries
prior to rendering the plot
