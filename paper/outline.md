# A functional interactive grammar of graphics for exploratory data analysis
(_high level overview of paper structure_)

## Contents
[Introduction](##introduction)

[Design](##design)

[Examples](##examples)

[Discussion](##discussion)  

[_misc notes and questions_](##questions)


## Introduction

Motivations for designing a grammar, where the emphaisis is on interactivity (in terms of both manipulating a visualisation and incorporating visualisations into a data analysis workflow) rather than a polished product or graphical user interface. I see this as the core difference between vis software that is written by statisticians vs computer scientists.  

Why is interactivity useful for exploratory data analysis? See work by Di and Heike like _Removing the blindfold_, the papers by Cleveland on brushing scatterplots, Tukey's work on Prism9 and I'm sure many more...


Putting our work in context. Prior work in the stat computing literature (ggplot2, lattice, plotly, gggobi, manet, mondrian, cranvas, orca) and the info vis literature (altair, d3, vega, vega-lite, and many more). Client side vs server side computation. Reactive programming. Events and signals. Graphics pipeline from the plumbing paper. 

Given the multitude of different software available to produce interactive visualisations why do we need another one? Several answers I can think of: grammars are cognitive tools that enable high-level reasoning, (compared to info vis approaches) tight integration with statistical computing environment, just enough control (compared to stat computing approaches).


## Design

Each paragraph highlights key design ideas that we have adapted or contributed 

### Graphics from data and data from graphics

The idea is that the generation of a graphic can be represented by the data itself. The data can be used to manifest the set of transformations (in either direction) from variables to aesthetics to physical representation of a graphics and hence is the 'program' or 'specification' that generates a graphic. Hence, given the intrinsic relationship between data and graphic, the pipeline steps can be represented with elements of a functional grammar. The pipeline is a DAG and hence can be built in stages.


### Events are in data space
And are generated via the context of the aesthetic mappings. State is manipulated as though it is property of the data. 


### Deferred evaluation
Every transformation generates a callback function that is only evaluated upon rendering. It would be cool to be able to actually modify these in real time alongside the visualisation (turns out you could actaully do something like this in the [70s!](http://www.righto.com/2017/10/the-xerox-alto-smalltalk-and-rewriting.html)).

### Pushing computation client side


### Grammar elements

(modified from the wiki)

#### Static Grammar Elements
##### Visualise (the mapping from variables to aesthetics)

This is the function that performs the `aes_` name mangling, think of it like ggplot's aes except the results are visible to the user.


##### Draw, mutate, filter

This function triggers a new layer to be drawn (maybe layer is a better verb?) and will initialise a new layer. It will add in a new column called `geom` corresponding to the mark to be drawn, and any options passed to the function call will be name mangled as a new column(s) called `opt_`, this lets us differentiate between aesthetics and options to a plot. Multiple layers that inherit the same aesthetic mappings can be specified by trigger new calls to draw.
Aesthetics can modified in the pipeline via a call to `mutate`.

##### Summarise (statistical transformations)

Here we can precompute any statistical transformations and make them independent of drawing the graphic. All of these functions use `dplyr` in the backend, so could in theory be pushed back to a database.

##### Group by

`group_by` partitions aesthetics by subsets of the data, any downstream calls act on each paritition. Do groups create facets?

##### Mesh

For adding independent data layers, we could introduce a newdata argument to the `draw_` functions except that seems like the inheritance of aes terms could get tricky. Instead we use  `mesh` to combine pipepline stages.


#### Interactive grammar elements

#### pin
explicitly making data mutable

##### control

The control verb specifies an event in the context of the data, like a click or a drag, to be observed on the visualisation. These functions emit events in data space so they can then be passed to other grammar elements.

##### manipulation of state via `mutate_referential`   

Explicit handling of how state manipulations are inherently recursive, hence mutations should be self referential. 

## Examples

When does a scatter plot become a brushed scatter plot?
```r
scatter <- mtcars %>% visualise(x = hp, y = mpg) %>% draw_points()
```

```r
brush <- scatter %>% control_drag() %>% draw_rect()
```

combine stages

```r
mesh(scatter,brush)
```


Become a transiently highlighted brushed scatter plot?

```r
scatter <- scatter %>% 
				mutate(
					sel = inside(aes_x, aes_y, brush),
					aes_fill = ifelse(sel, "red", "black")
			   )
			   
mesh(scatter, brush)
```

Become a persistently highlighted brushed scatter plot?

```r
scatter <- scatter %>% 
				mutate(sel = FALSE) %>%
				mutate_referential(
					sel = sel | inside(aes_x, aes_y, brush),
					aes_fill = ifelse(sel, "red", "black")
			   )
mesh(scatter, brush)
```


## Discussion


## Questions

Amount of control given to a user? - at the minimum returning event data to the user - but there could be a lot more.

Representation of pipeline stages? - pipelines are not linear but are DAGs 

Representaion of multiple views?





