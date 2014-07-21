GraphLayout.jl
==============

[![Build Status](https://travis-ci.org/IainNZ/GraphLayout.jl.svg)](https://travis-ci.org/IainNZ/GraphLayout.jl)
[![Coverage Status](https://img.shields.io/coveralls/IainNZ/GraphLayout.jl.svg)](https://coveralls.io/r/IainNZ/GraphLayout.jl)
[![GraphLayout](http://pkg.julialang.org/badges/GraphLayout_0.3.svg)](http://pkg.julialang.org/?pkg=GraphLayout&ver=0.3)

Graph layout algorithms in pure Julia. Currently only has the spring-based method of [Fruchterman and Reingold (1991)](http://www.mathe2.uni-bayreuth.de/axel/papers/reingold:graph_drawing_by_force_directed_placement.pdf), but more can and will be added. Only other restriction is the graph must be provided in adjacency matrix format - adjacency list and [Graph.jl](https://github.com/JuliaLang/Graphs.jl) support to come later (PRs welcomed).

Related packages:
* [TikzGraphs.jl](https://github.com/sisl/TikzGraphs.jl) - plot `Graph.jl` graphs using `lualatex/tikz`.
* [GraphViz.jl](https://github.com/Keno/GraphViz.jl) - Julia binding to the `GraphViz` library.

GraphLayout.jl has an optional dependency on [Compose.jl](https://github.com/dcjones/Compose.jl). If you have it installed you can plot the resulting graph layouts:

![Gadfly](https://rawgit.com/IainNZ/GraphLayout.jl/master/example/gadfly.svg)

![Pentagon](https://rawgit.com/IainNZ/GraphLayout.jl/master/test/pentagon.svg)

![Random](https://rawgit.com/IainNZ/GraphLayout.jl/master/test/random.svg)

MIT License. Copyright (c) 2014 Iain Dunning
