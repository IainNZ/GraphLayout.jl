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
    5. Generate the layout

    Will return the layout for visualzing the tree (as a GraphLayout.Network object).

    Arguments:
    adj_list        Directed graph in adjacency list format

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
"""

function generate_layout_tree{T}(adj_list::AdjList{T};
                        cycles      = true,
                        ordering    = :optimal,
                        coord       = :optimal,
                        xsep        = 3,
                        ysep        = 20,
                        scale       = 0.05,)
    # Calculate the original number of vertices
    n = length(adj_list)

    # 1     Cycle removal
    if cycles
        # Need to remove cycles first
        error("Cycle removal not implemented!")
    end

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
    locs_y = zeros(n)
    for L in 1:num_layers
        for (x,v) in enumerate(layer_verts[L])
            locs_y[v] = (L-1)*ysep
        end
    end

    locs_x = _coord_ip_layout(adj_list, layers, layer_verts, orig_n, xsep)
    # 4.2   Summarize vertex info
    max_x, max_y = maximum(locs_x), maximum(locs_y)

    # 5     Generate the layout
    # 5.1   Create the nodes
    nodes = [Node(Point(locs_x[i], locs_y[i])) for i in 1:orig_n]

    # 5.2   Create the arrows
    arrows = Edge[]
    for L in 1:num_layers, i in layer_verts[L], j in adj_list[i]
        push!(arrows, Edge(Point(locs_x[i],locs_y[i]), Point(locs_x[j],locs_y[j]), true))
    end

    # 5.3 Return the layout
    n = Network(nodes, arrows)
    return n
end
