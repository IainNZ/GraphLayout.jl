# GraphLayout.jl

Graph layout and visualization algorithms, implemented in Julia.

[![Build Status](https://travis-ci.org/IainNZ/GraphLayout.jl.svg)](https://travis-ci.org/IainNZ/GraphLayout.jl)
[![Coverage Status](https://img.shields.io/coveralls/IainNZ/GraphLayout.jl.svg)](https://coveralls.io/r/IainNZ/GraphLayout.jl)
[![GraphLayout](http://pkg.julialang.org/badges/GraphLayout_release.svg)](http://pkg.julialang.org/?pkg=GraphLayout&ver=release)

The package currently implements the following layout methods:

* Spring-based method of [Fruchterman and Reingold (1991)](https://scholar.google.com/scholar?q=Graph+Drawing+by+Force+Directed+Placement)
* Stress-majorization method of [Gansner, Koren, and North (2005)](https://scholar.google.com/scholar?hl=en&q=Graph+Drawing+by+Stress+Majorization)
* Hierachical drawing of directed graphs inspired by the methods of [Sugiyama, Tagawa, and Toda (1981)](https://scholar.google.com/scholar?q=Methods+for+visual+understanding+of+hierarchical+system+structures).

The visualizations are created using [Compose.jl](https://github.com/dcjones/Compose.jl), enabling output to a variety of vector and raster image formats. The hierachical drawing algorithm has multiple components, some of which can use exact algorithms instead of heuristics. To use these components [JuMP](https://github.com/JuliaOpt/JuMP.jl) and a [suitable solver](http://juliaopt.org) should be installed.

GraphLayouts.jl is not a comprehensive graph visualization option yet. Some related packages may meet your needs:
* [GraphViz.jl](https://github.com/Keno/GraphViz.jl) - Julia binding to the `GraphViz` library.
* [TikzGraphs.jl](https://github.com/sisl/TikzGraphs.jl) - plot `Graph.jl` graphs using `lualatex/tikz`.

### Examples

If you have it installed you can plot the resulting graph layouts:

![Gadfly](https://rawgit.com/IainNZ/GraphLayout.jl/master/example/gadfly.svg)

![Pentagon](https://rawgit.com/IainNZ/GraphLayout.jl/master/test/pentagon.svg)

![Random](https://rawgit.com/IainNZ/GraphLayout.jl/master/test/random.svg)

MIT License. Copyright (c) 2015 [Iain Dunning](http://iaindunning.com) and [contributors](https://github.com/IainNZ/GraphLayout.jl/graphs/contributors).
