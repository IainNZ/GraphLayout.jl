This package will only work on very old version of Julia.
As of 2020 May, https://github.com/JuliaGraphs/GraphPlot.jl might be what you want.
Good luck!

# GraphLayout.jl

Graph layout and visualization algorithms, implemented in Julia.

The package currently implements the following layout methods:

* Spring-based method of [Fruchterman and Reingold (1991)](https://scholar.google.com/scholar?q=Graph+Drawing+by+Force+Directed+Placement)
* Stress-majorization method of [Gansner, Koren, and North (2005)](https://scholar.google.com/scholar?hl=en&q=Graph+Drawing+by+Stress+Majorization)
* Hierachical drawing of directed graphs inspired by the methods of [Sugiyama, Tagawa, and Toda (1981)](https://scholar.google.com/scholar?q=Methods+for+visual+understanding+of+hierarchical+system+structures).

The visualizations are created using [Compose.jl](https://github.com/dcjones/Compose.jl), enabling output to a variety of vector and raster image formats. The hierarchical drawing algorithm has multiple components, some of which can use exact algorithms instead of heuristics. To use these components [JuMP](https://github.com/JuliaOpt/JuMP.jl) and a [suitable solver](http://juliaopt.org) should be installed - JuMP will be automatically installed, but a solver will not.

GraphLayouts.jl is not a comprehensive graph visualization option yet, and may never be. **Please consider using a more mature library**. Some related packages may meet your needs:
* [GraphViz.jl](https://github.com/Keno/GraphViz.jl) - Julia binding to the `GraphViz` library.
* [TikzGraphs.jl](https://github.com/sisl/TikzGraphs.jl) - plot graphs using `lualatex/tikz`.

### Examples

If you have it installed you can plot the resulting graph layouts:

![Pentagon](https://rawgit.com/IainNZ/GraphLayout.jl/master/test/pentagon.svg)

![Random](https://rawgit.com/IainNZ/GraphLayout.jl/master/test/tree.svg)

MIT License. Copyright (c) 2016 [Iain Dunning](http://iaindunning.com) and [contributors](https://github.com/IainNZ/GraphLayout.jl/graphs/contributors).
