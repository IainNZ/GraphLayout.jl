module GraphLayout
    if VERSION < v"0.4.0"
        using Docile
    end
    using Requires  # to optionally load JuMP
    using Compose  # for plotting features

    # Spring-based force layout algorithms
    export layout_spring_adj
    include("spring.jl")

    # Stress majorization layout algorithms
    export layout_stressmajorize_adj
    include("stress.jl")

    # Tree layout algorithms
    export layout_tree
    include("tree.jl")
    # Also provide optimal algorithms, that require JuMP
    # JuMP will only be loaded if these methods are requested
    @require JuMP include(joinpath(Pkg.dir("GraphLayout","src","tree_opt.jl")))

    # Drawing utilities
    export draw_layout_adj
    include("draw.jl")
end
