module GraphLayout
    # Spring-based force layout algorithms
    export layout_spring_adj
    include("spring.jl")

    # Optional plotting features using Compose
    export draw_layout_adj
    try
        require("Compose")
        include("draw.jl")
    catch
        global draw_layout_adj(a, x, y; kwargs...) = error("Compose.jl required for drawing functionality.")
    end
end