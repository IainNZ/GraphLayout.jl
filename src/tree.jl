function _tree_rectangle(x, y, rect)
    SimpleRectangle(rect.x + x - rect.w/2, rect.y + y - rect.w/2, rect.w, rect.h)
end

"""
    Creates a line between two rectangles in the tree

    Arguments:
    origin, o_h   Origin x, y, and height
    destination, d_h   Destination x, y, and height
"""
function _arrow_tree{T}(origin::Point{2,T}, o_h::T, destination::Point{2,T}, d_h::T)
    x1, y1 = origin[1], origin[2] + o_h/2
    x2, y2 = destination[1], destination[2] - d_h/2
    Δx, Δy = x2 - x1, y2 - y1
    θ = atan2(Δy, Δx)
    # Put an arrow head only if destination isn't dummy
    start = Point{2,T}(x1, y1)
    endpoint = Point{2,T}(x2, y2)
    LineSegment{Point{2,T}}[LineSegment{Point{2,T}}(start, endpoint)]
end


"""
    Hierachical drawing of directed graphs inspired by the Sugiyama framework.
    In particular see Chapter 13 of 'Hierachical Drawing Algorithms' from
    the 'Handbook of Graph Drawing and Visualization' and the article
      K. Sugiyama, S. Tagawa, and M. Toda. Methods for visual understanding
      of hierarchical system structures. IEEE Transaction on Systems, Man,
      and Cybernetics, 11(2):109–125, 1981.

    The method as implemented here has 4 steps:
    1. Cycle removal [if needed]
    2. Layer assignment + break up long edges
    3. Vertex ordering [to reduce crossings]
    4. Vertex coordinates [to straighten edges]
    5. returns positioned Rectangles for every node and lines connecting the nodes

    Arguments:
    adj_list        Directed graph in adjacency list format
    labels          Label for each vertex

    Optional arguments:
    cycles          If false, assume no cycles. Default true.
    ordering        Vertex ordering method to use. Options are:
                        :optimal        Uses JuMP (integer program)
                        :barycentric    Sugiyama heuristic
    coord           Vertex coordinate method to use. Options are:
                        :optimal        Uses JuMP (linear program)

    xsep            Controls the minimum vertex horizontal spacing
    ysep            Controls the minimum vertex vertical spacing
    scale           Scales the output figure size
    labelpad        Padding around nodes in vertices
"""
function layout_tree{T<:Integer, R<:SimpleRectangle}(
        adj_list::AdjList{T},
        labels::Vector{R};
        cycles      = false,
        ordering    = :optimal,
        coord       = :optimal,
        xsep        = 50,
        ysep        = 120,
        scale       = 0.05,
        labelpad    = 1.2,
    )
    # 1     Cycle removal
    if cycles # cycles in a tree?
        # Need to remove cycles first
        error("Cycle removal not implemented!")
    end

    # Calculate the original number of vertices
    n = length(adj_list)
    TV = eltype(R)

    # 2     Layering
    # 2.1   Assign a layer to each vertex
    layers = _layer_assmt_longestpath(adj_list)
    num_layers = maximum(layers)
    # 2.2  Create dummy vertices for long edges
    adj_list, layers = _layer_assmt_dummy(adj_list, layers)
    orig_n, n = n, length(adj_list)


    # 3     Vertex ordering [to reduce crossings]
    # 3.1   Build initial permutation vectors
    layer_verts = [L => Int[] for L in 1:num_layers]
    for i in 1:n
        push!(layer_verts[layers[i]], i)
    end
    # 3.2  Reorder permutations to reduce crossings
    if ordering == :barycentric
        layer_verts = _ordering_barycentric(adj_list, layers, layer_verts)
    elseif ordering == :optimal
        layer_verts = _ordering_ip(adj_list, layers, layer_verts)
    end


    # 4     Vertex coordinates [to straighten edges]
    # 4.1   Place y coordinates in layers
    locs_y = zeros(TV, n)
    for L in 1:num_layers
        for (x,v) in enumerate(layer_verts[L])
            locs_y[v] = (L-1)*ysep
        end
    end
    # 4.2   Get widths of each label, if there are any
    widths_  = ones(TV, n); widths_[orig_n+1:n]  = 0
    heights = ones(TV, n); heights[orig_n+1:n] = 0
    # Note that we will convert these sizes into "absolute" units
    # and then work in these same units throughout. The font size used
    # here is just arbitrary, and unchanging. This hack arises because it
    # is meaningless to ask for the size of the font in "relative" units
    # but we don't want to collapse to absolute units until the end.
    if length(labels) == orig_n
        @inbounds for (i, rect) in enumerate(labels)
            w, h = Vec{2, TV}(widths(rect))
            widths_[i]  = w
            heights[i] = h
        end
    end
    locs_x = convert(Vector{TV}, _coord_ip(adj_list, layers, layer_verts, orig_n, widths_, xsep))
    # 4.3   Summarize vertex info
    max_x, max_y = maximum(locs_x), maximum(locs_y)
    max_w, max_h = maximum(widths_), maximum(heights)

    # 5     Layout the tree
    # 5.1   Create the label rectangles
    positioned_rectangles = [_tree_rectangle(locs_x[i], locs_y[i], labels[i]) for i in 1:orig_n]
    # 5.2   Create the connecting lines
    lines = LineSegment{Point{2,TV}}[]
    for L in 1:num_layers, i in layer_verts[L], j in adj_list[i]
        node_lines = _arrow_tree(
            Point{2,TV}(locs_x[i], locs_y[i]), i<=orig_n ? max_h : TV(0),
            Point{2,TV}(locs_x[j], locs_y[j]), j<=orig_n ? max_h : TV(0)
        )
        append!(lines, node_lines)
    end

    return positioned_rectangles, lines
end
