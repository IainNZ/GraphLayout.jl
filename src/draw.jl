using Compose

function draw_layout_adj{S, T<:Real}(
    adj_matrix::Array{S,2}, 
    locs_x::Vector{T}, locs_y::Vector{T};
    labels::Vector={},
    filename::String="graph.svg")
    
    # draw_layout_adj
    # Given an adjacency matrix and two vectors of X and Y coordinates, draw
    # using Compose.jl an SVG of the graph layout.
    # Arguments:
    #  adj_matrix       Adjacency matrix of some type. Non-zero of the eltype
    #                   of the matrix is used to determine if a link exists,
    #                   but currently no sense of magnitude
    #  locs_x, locs_y   Locations of the nodes. Can be any units you want, 
    #                   but will be normalized and centered anyway
    #  labels           Optional. Labels for the vertices.
    #  filename         Optional. Output filename for SVG

    length(locs_x) != length(locs_y) && error("Vectors must be same length")
    const N = length(locs_x)
    if length(labels) != N && length(labels) != 0
        error("Must have one label per node (or none)")
    end

    # Scale to unit square
    min_x, max_x = minimum(locs_x), maximum(locs_x)
    min_y, max_y = minimum(locs_y), maximum(locs_y)
    function scaler(z, a, b)
        2.0*((z - a)/(b - a)) - 1.0
    end
    map!(z -> scaler(z, min_x, max_x), locs_x)
    map!(z -> scaler(z, min_y, max_y), locs_y)

    # Create lines
    lines = {}
    for i = 1:N
        for j = 1:N
            i == j && continue
            if adj_matrix[i,j] != zero(eltype(adj_matrix))
                push!(lines, line([(locs_x[i],locs_y[i]), (locs_x[j],locs_y[j])]))
            end
        end
    end

    # Create nodes
    nodes = [circle(locs_x[i],locs_y[i],0.25/sqrt(N)) for i=1:N]

    # Create labels (if wanted)
    texts = length(labels) == N ?
        [text(locs_x[i],locs_y[i],labels[i],hcenter,vcenter) for i=1:N] : {}

    draw(   SVG(filename, 4inch, 4inch), 
            compose(
                context(units=UnitBox(-1.2,-1.2,+2.4,+2.4)),
                compose(context(), texts..., fill("#000000"), stroke(nothing), fontsize(4.0)),
                compose(context(), nodes..., fill("#AAAAFF"), stroke("#BBBBBB")),
                compose(context(), lines..., stroke("#BBBBBB"), linewidth(10.0/N))
            )
        )
end