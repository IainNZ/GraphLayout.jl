__precompile__(true)

module GraphLayout
    using Compose   # for plotting features
    using GeometryTypes   # for generating the layout

    typealias AdjList{T} Vector{Vector{T}}

    type Node
      p::Point
    end

    type Edge
      src::Point
      dest::Point
      directed::Bool
    end

    immutable Network
      Positions::Array{Node}
      Connections::Array{Edge}
    end

    export Node, Edge, Network

    # Spring-based force layout algorithm
    export layout_spring_adj
    export layout_spring_adj_3D
    include("spring.jl")

    # Stress majorization layout algorithm
    export layout_stressmajorize_adj
    include("stress.jl")

    # Tree layout algorithms
    export layout_tree
    include("tree.jl")
    # Heuristic algortihms for tree layout
    include("tree_heur.jl")
    # Optimal algorithms for tree layout, that require JuMP
    include("tree_opt.jl")

    # Drawing utilities
    export draw_layout_adj
    include("draw.jl")

    # Generating layout
    export generate_layout
    include("generate.jl")

    # Generating tree layout
    export generate_layout_tree
    include("tree_layout.jl")
end
