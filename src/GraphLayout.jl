module GraphLayout
    if VERSION < v"0.4.0"
        using Docile
    end
    using Requires

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


    # Optional plotting features using Compose
    export compose_layout_adj, draw_layout_adj
    try
        require("Compose")
        include("draw.jl")
    catch
        global draw_layout_adj(a, x, y; kwargs...) = error("Compose.jl required for drawing functionality.")
    end
end
