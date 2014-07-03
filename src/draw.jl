using Compose

function draw_layout_adj{S, T<:Real}(
    adj_matrix::Array{S,2}, 
    locs_x::Vector{T}, locs_y::Vector{T};
    FILENAME="graph.svg")
    
    # draw_layout_adj
    # Given an adjacency matrix and two vectors of X and Y coordinates, draw
    # using Compose.jl an SVG of the graph layout.
    # Arguments:
    #  adj_matrix       Adjacency matrix of some type. Non-zero of the eltype
    #                   of the matrix is used to determine if a link exists,
    #                   but currently no sense of magnitude
    #  locs_x, locs_y   Locations of the nodes. Can be any units you want, 
    #                   but will be normalized and centered anyway
    #  FILENAME         Output filename for SVG

    length(locs_x) != length(locs_y) && error("Vectors must be same length")
    const N = length(locs_x)

    # Calculate center of locations, then shift it so it sits in middle
    locs_x .-= mean(locs_x)
    locs_y .-= mean(locs_y)

    # Calculate maximimum coordinate so we can scale back to [-1,+1]^2
    locs_x ./= maximum(abs(locs_x))
    locs_y ./= maximum(abs(locs_y))

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

    draw(   SVG(FILENAME, 4inch, 4inch), 
            compose(
                context(units=UnitBox(-1.2,-1.2,+2.4,+2.4)),
                nodes...,  lines..., fill("red"), stroke("black"), linewidth(10.0/N)
            )
        )
end