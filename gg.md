# Revisiting the grammar of graphics

The grammar of graphics is a framework that allows a user to describe
and evaluate plots in a consistent manner. As a formalism it allows a user
to discover an apporpriate plot for their given data analysis question. Recall 
that the layered grammar of graphics (i.e. _ggplot2_) defines a plot as consisting of the
following features:

1. A dataset to be plotted.
1. A set of aesthetic mappings (aes). These determine which variables
in a dataset correspond to graphical elements to be drawn.
1. A set of layers. Each layer contains exactly one geometrical element (geoms) such as
a line and exactly one statistical transformation (stats) like a mean or a count. 
A layer can also be defined with a dataset independent of the one used in 1.
1. Scales for each aesthetic element. A scale defines how values of variables
are placed on the graph with respect to their aesthetic mappings.
1. A coordinate system (coords). The choice of system can modify the shape of
a geom.
1. A facetting (facets). Create small multiples based on subsets of the data. That is, the same plot
is generated using different subsets of the data.
1. A theme. Modify features of the graphic such as margin or text size.

In _ggplot2_, a plot object is defined as an object containing each of 
the grammar elements mentioned above, with the requirement that each layer
is defined using a base R `data.frame`.  The aesthetics that map to variables 
in the data, forms the dataset that will be used to draw a graphic, and then
a given grammar element is computed on that data. A clear disadvantage of this
approach is that any other object type in R must first be converted to a 
`data.frame` and any method for effeciently computing on that object type 
is discarded when constructing a plot. 

Using the layered grammar approach resuls in grammar elements such as stats and 
geoms that are not independent components
of a plot object and instead imply each other. For example, `geom_bar` 
implies `stat_count` or `geom_histogram` implies `stat_bin` and so on. These
are convienient for the user most of the time but can cause confusion (i.e.
using `stat_identity` to enable rectangle heights to be proprotional to a
values of a varialbe for a bar chart). This also results in an ineffeciency
as the stat methods perform transformations on the data that are not necessarily
optimal.

## What would a fluent grammar of graphics API look like?

Or can we make a verb based API based on the grammar of graphics and
`ggplot2` that:

1. Can be extended to `tibbles` and other data strucutres.
2. Provides generic code for computing grammar elements.
3. Can be composed functionally using the pipe operator (forming the graphics
pipeline).

## What would the verbs be for each grammar element?

In _ggplot2_ a plot is constructed via a call to the `ggplot` constructor
that constructs a ggplot object. This is achieved in three ways


1. data with aesthetics
```
ggplot(data, aes(x = ..., y == ...))
```
2. just data
```
ggplot(data)
```

3. all arguments missing
```
ggplot()
```

The last example is generally used to add layers using different datasets.
For our API to be fluent, the constructor should be seperated from defining
the aesthetic mappings. I propose to use the verb `frame` as the name
of the generic that begins the graphics pipeline since it is evocative
of painting/drawing on a canvas (although this might not be the best since
there is a `frame()` function in base graphics. 

Once a data structure has been framed, aesthetics can be added using the
_dplyr_ verb `transmute` (although this feels clunky) with checks for
valid aesthetic names. Another option could be to use a preposition function
such as `with_aesthetics` so that multiple layers could be handled. Could
group wise aesthetics use `group_by` instead of having `aes(group = )`?

Since stats are either modifiers or summaries of the input data and transform
what data is used to draw the graphic. This implies that aggregation 
operations could use a `summarise` prefix and variable transformations could
use `mutate`.

The notion of `geoms` is relatively abstract, so could be replaced with
the`draw` family of functions. A question remains about what to do with
additional layers from other data sources?

The _ggplot2_ `facet` and functions can already be treated as verbs. 

Scales could be simplified by using a `scale_at` verb which takes 
aesthetic mappings and provides a transformation function. 

Coordinates could modified like aesthetics with the use of a prepositional
function or with the verb `project`.

### Examples

Here are some canonical ggplot2 examples with our API:

```{r}
# scatter plot
ggplot(mtcars, aes(x = wt, y = mpg)) + geom_point()

mtcars %>% 
  frame() %>%
  with_aesthetics(x = wt, y = mpg) %>% 
  draw_points()
  
# bar chart (counting)
ggplot(mpg, aes(class))
mpg %>%
  frame() %>%
  with_aesthtics(x = class) %>%
  summarise_unique(y = n()) %>%
  draw_bar()

# bar chart with identity 
# short cut is geom_col = geom_bar(stat = "identity")
df <- data.frame(trt = c("a", "b", "c"), outcome = c(2.3, 1.9, 3.2))
ggplot(df, aes(trt, outcome)) +
  geom_col()

df %>%
  frame() %>% 
  with_aesthetics(x = trt, y = outcome) %>%
  draw_bar()
  
# histogram
ggplot(movies, aes(rating)) + geom_histogram()

movies %>%
  frame() %>% 
  with_aesthetics(x = rating) %>%
  summarise_bin(y = n()) %>%
  draw_bar() 
# histogram with sqrt scale
ggplot(movies, aes(rating)) + geom_histogram() + scale_y_sqrt()

movies %>%
  frame() %>% 
  with_aesthetics(x = rating) %>%
  summarise_bin(y = n()) %>%
  draw_bar()  %>%
  scale_at(y = "sqrt")

```


## Backend agnostic rendering

In principle, the grammar abstracts away the process of defining the graph 
from the drawing of a graphic. This can be achieved via a compile-render logic. 
All of the features that define a plot are compiled into instructions
that determine how the graph should be rendered. The graphic can then actually 
be rendered to a graphics device with a backend library indedpendently. 
The _plotly_ package uses this logic for turning a _ggplot2_ object into an 
interactive figure [@Sievert2017]. 