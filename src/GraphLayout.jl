__precompile__(true)

module GraphLayout
    using Requires  # to optionally load JuMP
    using Compose   # for plotting features

    typealias AdjList{T} Vector{Vector{T}}

    # Spring-based force layout algorithms
    export layout_spring_adj
    include("spring.jl")

    # Stress majorization layout algorithms
    export layout_stressmajorize_adj
    include("stress.jl")

    # Tree layout algorithms
    export layout_tree
    include("tree.jl")
    # Heuristic algortihms for tree layout
    include("tree_heur.jl")
    # Optimal algorithms for tree layout, that require JuMP
    # These methods will be loaded when JuMP is loaded
    _ordering_ip(args...) =
        error("JuMP package must be loaded for optimization tree layout")
    @require JuMP include("tree_opt.jl")

    # Drawing utilities
    export draw_layout_adj
    include("draw.jl")
end
