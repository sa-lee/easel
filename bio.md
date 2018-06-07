# Genomic semantics for graphics

There are many current gaps in methodology for visualising (and performing
exploratory data analysis of) high-throughput genomic datasets. These
issues relate to both the technical nature and underlying biology of the
datasets.

The current workflows of high-throughput biological data analysis prohibit 
performing reproducible and interactive data visualisation for several reasons: 

1. Most data import and processing is performed via command line interfaces (CLI) 
in batch on a high performance compute cluster. As a consequence, these interfaces 
do not enable visualisation until all data is processed and even if a compute 
environment enables a graphics device, the speed of rendering a graphic does 
not allow for rapid iteration. Furthermore, most current packages do not 
integrate into an exploratory or interactive workflow and are mostly used for 
creating summary graphics/reports/applications after a data analysis has been 
performed. This is not necessarily prohibitive but does mean the analyst only 
sees information that the package creator deems important.

2. A lot biological data from high-througput equipment is stored in either
binary formats or on disk formats such as HDF5 or in databases. Currently, in 
order to produce a graphic from data contained in these formats, they must be 
read into memory and then converted to an appropriate data structure for the 
graphics software. There are opportunities for doing this effeciently and 
quickly with R.

3. As the number of samples grows it becomes too time consuming for an analyst 
to iterate through every sample or every possible combination of samples to 
search for problems or structure in the data. There is also a possibility that
in such a large search space, the analyst may fool themselves into believing
there is signal in their data when no such structure is present. This problem
can be addressed with visual inference.

4. There is a lack of visual grammar elements for biological data, in particular 
genomics. Problems include visual crowding (i.e. finding small width genomic 
ranges amongst many larger ones), plot scaling issues (i.e. genome-wide plots, 
expression plots), interactivity, combining multiple experiments/features.