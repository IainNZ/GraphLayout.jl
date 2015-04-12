typealias AdjList{T} Vector{Vector{T}}

@doc """
    Use the Sugiyama framework/metod for hierachical drawing of graphs.
    For reference, see Chapter 13 of 'Hierachical Drawing Algorithms' from
    'Handbook of Graph Drawing and Visualization' and
      K. Sugiyama, S. Tagawa, and M. Toda. Methods for visual understanding
      of hierarchical system structures. IEEE Transaction on Systems, Man,
      and Cybernetics, 11(2):109–125, 1981.

    The method has 4 steps:
    1. Cycle removal [if needed]
    2. Layer assignment, and dummy vertices for long edges
    3. Vertex ordering, [reduce crossings]
    4. Horizontal Positioning

    Arguments:
    adj_list        Directed graph in adjacency list format
""" ->
function layout_tree{T}(adj_list::AdjList{T}; 
                        cycles=true,
                        ordering=:barycentric)
    n = length(adj_list)

    # 1. Cycle removal
    if cycles
        # Need to remove cycles first
        error("Cycle removal not implemented!")
    end

    # 2    Layering
    # 2.1  Assign a layer to each vertex
    layers = _layer_assmt_longestpath(adj_list)
    num_layers = maximum(layers)
    # 2.2  Create dummy vertices for long edges
    adj_list, layers = _layer_assmt_dummy(adj_list, layers)
    orig_n, n = n, length(adj_list)


    # 3    Vertex ordering
    # 4.1  Build initial permutation vectors
    layer_verts = [L => Int[] for L in 1:num_layers]
    for i in 1:n
        push!(layer_verts[layers[i]], i)
    end
    # 4.2  Reorder permutations to reduce crossings
    if ordering == :barycentric
        layer_verts = _ordering_barycentric(adj_list, layers, layer_verts)
    elseif ordering == :optimal
        layer_verts = _ordering_ip(adj_list, layers, layer_verts)
    end
    

    # 5. Horizontal positioning
    locs_x = zeros(n)
    locs_y = zeros(n)
    for L in 1:num_layers
        for (x,v) in enumerate(layer_verts[L])
            locs_x[v] = x
            locs_y[v] = L
            #println("$v $x $L $(labels[v])")
        end
    end

    return locs_x,locs_y,adj_list
end



@doc """
    Assigns layers using the longest path method.

    Arguments:
    adj_list        Directed graph in adjacency list format
""" ->
function _layer_assmt_longestpath{T}(adj_list::AdjList{T})
    n = length(adj_list)
    layers = fill(-1, n)

    for j in 1:n
        in_deg = 0
        for i in 1:n
            if j in adj_list[i]
                in_deg += 1
            end
        end
        if in_deg == 0
            # Start recursive walk from this vertex
            layers[j] = 1
            _layer_assmt_longestpath_rec(adj_list, layers, j)
        end
    end

    return layers
end
function _layer_assmt_longestpath_rec{T}(adj_list::AdjList{T}, layers, i)
    # Look for all children of vertex i, try to bump their layer
    n = length(adj_list)
    for j in adj_list[i]
        if layers[j] == -1 || layers[j] <= layers[i]
            layers[j] = layers[i] + 1
            _layer_assmt_longestpath_rec(adj_list, layers, j)
        end
    end
end


@doc """
    Given a layer assignment, introduce dummy vertices to break up
    long edges (more than one layer)

    Arguments:
    orig_adj_list   Original directed graph in adjacency list format
    layers          Assignment of original vertices
""" ->
function _layer_assmt_dummy{T}(orig_adj_list::AdjList{T}, layers)
    adj_list = deepcopy(orig_adj_list)

    # This is essentially
    # for i in 1:length(adj_list)
    # but the adj_list is growing in the loop
    i = 1
    while i <= length(adj_list)
        for (k,j) in enumerate(adj_list[i])
            if layers[j] - layers[i] > 1
                # Need to add a dummy vertex
                new_v = length(adj_list) + 1
                adj_list[i][k] = new_v  # Replace dest of cur edge
                push!(adj_list, Int[j])  # Add new edge
                push!(layers, layers[i]+1)  # Layer for new edge
            end
        end
        i += 1
    end

    return adj_list, layers
end


@doc """
    Given a layer assignment, decide a permutation for each layer
    that attempts to minimizes edge crossings using the barycenter
    method proposed in the Sugiyama paper.

    Arguments:
    adj_list        Directed graph in adjacency list format
    layers          Assignment of vertices
    layer_verts     Dictionary of layer => vertices
""" ->
function _ordering_barycentric{T}(adj_list::AdjList{T}, layers, layer_verts)
    num_layers = maximum(layers)
    n = length(adj_list)

    for iter in 1:5
        # DOWN
        for L in 1:num_layers-1
            # Calculate barycenter for every vertex in next layer
            cur_layer = layer_verts[L]
            next_layer = layer_verts[L+1]
            barys = zeros(n)
            in_deg = zeros(n)
            for (p,i) in enumerate(cur_layer)
                # Because of the dummy vertices we know that
                # all vertices in adj list for i are in next layer
                for (q,j) in enumerate(adj_list[i])
                    barys[j] += p
                    in_deg[j] += 1
                end
            end
            barys ./= in_deg
            # Arrange next layer by barys, in ascending order
            next_layer_barys = [barys[j] for j in next_layer]
            #println("DOWN $L")
            #println(next_layer)
            #println(next_layer_barys)
            layer_verts[L+1] = next_layer[sortperm(next_layer_barys)]
        end
        # UP
        for L in num_layers-1:-1:1
            # Calculate barycenters for every vertex in cur layer
            cur_layer = layer_verts[L]
            next_layer = layer_verts[L+1]
            barys = zeros(n)
            out_deg = zeros(n)
            for (p,i) in enumerate(cur_layer)
                # Because of the dummy vertices we know that
                # all vertices in adj list for i are in next layer
                # We need to know their positions in next layer
                # though, unfortunately. Probably a smarter way
                # to do this step
                for (q,j) in enumerate(adj_list[i])
                    # Find position in next layer
                    for (r,k) in enumerate(next_layer)
                        if k == j
                            barys[i] += r
                            out_deg[i] += 1
                            break
                        end
                    end
                end
            end
            barys ./= out_deg
            # Arrange cur layer by barys, in ascending order
            cur_layer_barys = [barys[j] for j in cur_layer]
            #println("UP $L")
            #println(cur_layer)
            #println(cur_layer_barys)
            layer_verts[L] = cur_layer[sortperm(cur_layer_barys)]
        end
        # Do something with phase 2 here - don't really understand
    end

    return layer_verts
end