using Compose

function draw_layout_adj{S, T<:Real}(
    adj_matrix::Array{S,2}, 
    locs_x::Vector{T}, locs_y::Vector{T};
    labels::Vector={},
    filename::String="",
    labelc::String="#000000",
    nodefillc::String="#AAAAFF",
    nodestrokec::String="#BBBBBB",
    edgestrokec::String="#BBBBBB",
    labelsize::Real=4.0)
    
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
    #  filename         Optional. Output filename for SVG. If blank, just
    #                   tries to draw it anyway, which will display in IJulia
    #  nodefillc        Color to fill the nodes with
    #  nodestrokec      Color for the nodes stroke
    #  edgestrokec      Color for the edge strokes

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

    # Determine sizes
    const NODESIZE    = 0.25/sqrt(N)
    const LINEWIDTH   = 3.0/sqrt(N)
    const ARROWLENGTH = LINEWIDTH/10

    # Create lines and arrow heads
    lines = {}
    for i = 1:N
        for j = 1:N
            i == j && continue
            if adj_matrix[i,j] != zero(eltype(adj_matrix))
                push!(lines, lineij(locs_x, locs_y, i,j, NODESIZE, ARROWLENGTH))
            end
        end
    end

    # Create nodes
    nodes = [circle(locs_x[i],locs_y[i],NODESIZE) for i=1:N]

    # Create labels (if wanted)
    texts = length(labels) == N ?
        [text(locs_x[i],locs_y[i],labels[i],hcenter,vcenter) for i=1:N] : {}
    draw(   filename == "" ? SVG(4inch, 4inch) : SVG(filename, 4inch, 4inch),  
            compose(
                context(units=UnitBox(-1.2,-1.2,+2.4,+2.4)),
                compose(context(), texts..., fill(labelc), stroke(nothing), fontsize(labelsize)),
                compose(context(), nodes..., fill(nodefillc), stroke(nodestrokec)),
                compose(context(), lines..., stroke(edgestrokec), linewidth(LINEWIDTH))
            )
        )
end

function lineij(locs_x, locs_y, i, j, NODESIZE, ARROWLENGTH)
    Δx = locs_x[j] - locs_x[i]
    Δy = locs_y[j] - locs_y[i]
    d  = sqrt(Δx^2 + Δy^2)
    θ  = atan2(Δy,Δx)
    endx  = locs_x[i] + (d-NODESIZE)*1.00*cos(θ)
    endy  = locs_y[i] + (d-NODESIZE)*1.00*sin(θ)
    arr1x = endx - ARROWLENGTH*cos(θ+20.0/180.0*π)
    arr1y = endy - ARROWLENGTH*sin(θ+20.0/180.0*π)
    arr2x = endx - ARROWLENGTH*cos(θ-20.0/180.0*π)
    arr2y = endy - ARROWLENGTH*sin(θ-20.0/180.0*π)
    return compose(
            context(),
            line([(locs_x[i], locs_y[i]), (endx, endy)]),
            line([(arr1x, arr1y), (endx, endy)]),
            line([(arr2x, arr2y), (endx, endy)])
        )
end