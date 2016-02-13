__precompile__(true)

module GraphLayout
    using Compose   # for plotting features

    typealias AdjList{T} Vector{Vector{T}}

    # Spring-based force layout algorithm
    export layout_spring_adj
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
end
