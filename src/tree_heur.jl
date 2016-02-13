"""
    Assigns layers using the longest path method.

    Arguments:
    adj_list        Directed graph in adjacency list format
"""
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


"""
    Given a layer assignment, introduce dummy vertices to break up
    long edges (more than one layer)

    Arguments:
    orig_adj_list   Original directed graph in adjacency list format
    layers          Assignment of original vertices
"""
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


"""
    Given a layer assignment, decide a permutation for each layer
    that attempts to minimizes edge crossings using the barycenter
    method proposed in the Sugiyama paper.

    Arguments:
    adj_list        Directed graph in adjacency list format
    layers          Assignment of vertices
    layer_verts     Dictionary of layer => vertices
"""
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
