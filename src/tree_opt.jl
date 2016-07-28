# This file provides optimal integer-programming-powered algorithms for
# tree layout. JuMP is not a hard dependency of GraphLayout.jl, but if
# a user wishes to use these methods then they will need JuMP and an
# integer programming solver installed, such as GLPK, Cbc, or one of the
# commercial solvers like Gurobi or CPLEX
# Ideally, only when one of these methods is used will JuMP will be
# loaded. However, one of the phases only has a JuMP-dependent version
# so we need to always load JuMP for now.
########################################################################

using JuMP

"""
    Given a layer assignment, decide a permutation for each layer
    that minimizes edge crossings using integer programming.

    Based on the IP described in
      M. Junger, E. K. Lee, P. Mutzel, and T. Odenthal.
      A polyhedral approach to the multi-layer crossing minimization problem.
      In G. Di Battista, editor, Graph Drawing: 5th International Symposium,
      GD ’97, volume 1353 of Lecture Notes in Computer Science, pages 13–24,
      Rome, Italy, September 1997. Springer-Verlag.


    Arguments:
    adj_list        Directed graph in adjacency list format
    layers          Assignment of vertices
    layer_verts     Dictionary of layer => vertices (initial perm.)

    Returns:
    new_layer_verts An improved dictionary of layer => vertices (opt. perm.)
"""
function _ordering_ip{T}(adj_list::AdjList{T}, layers, layer_verts)
    num_layers = maximum(layers)

    m = Model()

    # Define crossing binary variables
    @variable(m, c[L=1:num_layers,        # for each layer
                 i=layer_verts[L],      # for each vertex in this layer
                 j=adj_list[i],         # and vertex in the next layer
                 k=layer_verts[L],      # for each vertex in this layer
                 l=adj_list[k]], Bin)   # and vertex in the next layer

    # Objective: minimize crossings
    @objective(m, Min, sum(c))

    # Define permutation variables for each layer
    # We'll define for both (i,j) and (j,i), and ensure they consistency
    # by adding constraints. Presolve in the IP solver will simplify
    # the problem for us by removing one of the variables.
    @variable(m, x[L=1:num_layers, i=layer_verts[L], j=layer_verts[L]], Bin)
    for L in 1:num_layers
        for i in layer_verts[L]
            for j in layer_verts[L]
                j <= i && continue  # Don't double-add
                # Ensure x[i,j] and x[j,i] are consistent
                @constraint(m, x[L,i,j] == 1 - x[L,j,i])
                # And ensure that triples are consistent
                for k in layer_verts[L]
                    k <= j && continue
                    @constraint(m, 0 <= x[L,i,j] + x[L,j,k] - x[L,i,k] <= 1)
                end
            end
        end
    end

    # Link permutations to crossings
    for L in 1:num_layers-1
        # For all (i,j)
        for i in layer_verts[L]
        for j in adj_list[i]
            # For all (k,l)
            for k in layer_verts[L]
            k == i && continue  # Can't cross if starting from same vertex!
            for l in adj_list[k]
                @constraint(m, -c[L,i,j,k,l] <= x[L+1,j,l] - x[L,i,k])
                @constraint(m,  c[L,i,j,k,l] >= x[L+1,j,l] - x[L,i,k])
            end
            end
        end
        end
    end

    # Solve the IP
    solve(m)

    # Extract permutation from solution
    x_sol = getvalue(x)
    new_layer_verts = [L => Int[] for L in 1:num_layers]
    for L in 1:num_layers
        old_perm = layer_verts[L]
        # For each vertex, count the number of times it is "in front"
        # of the other vertices. The higher this number, the earlier
        # the vertex appears in the layer.
        scores = zeros(length(old_perm))
        for (p,i) in enumerate(old_perm)
            for j in old_perm
                i == j && continue
                if round(Integer, x_sol[L,i,j]) == 1
                    # i appears before j
                    scores[p] += 1
                end
            end
        end
        new_layer_verts[L] = old_perm[sortperm(scores,rev=true)]
    end

    return new_layer_verts
end


########################################################################


"""
    Given a layer assignment and permutation, decide the coordinates for
    each vertex. The objective is to encourage straight edges, especially
    for longer edges. This function uses an integer program to decide the
    coordinates (although it is solved as a linear program), as described in
      Gansner, Emden R., et al.
      A technique for drawing directed graphs.
      Software Engineering, IEEE Transactions on 19.3 (1993): 214-230.

    Arguments:
    adj_list        Directed graph in adjacency list format
    layers          Assignment of vertices
    layer_verts     Dictionary of layer => vertices (final perm.)
    orig_n          Number of original (non-dummy) vertices
    widths          Width of each vertex
    xsep            Minimum seperation between each vertex

    Returns:
    layer_coords    For each layer and vertex, the x-coord
"""
function _coord_ip{T}(adj_list::AdjList{T}, layers, layer_verts, orig_n, widths, xsep)
    num_layers = maximum(layers)

    m = Model()

    # One variable for each vertex
    @variable(m, x[L=1:num_layers, i=layer_verts[L]] >= 0)

    # Constraint: must respect permutation, and spacign constraint
    for L in 1:num_layers
        for i in 1:length(layer_verts[L])-1
            a = layer_verts[L][i]
            b = layer_verts[L][i+1]
            @constraint(m, x[L,b] - x[L,a] >=
                (widths[a] + widths[b])/2 + xsep)
        end
    end

    # Objective: minimize total misalignment
    # Use the weights from the Ganser paper:
    #   1 if both nodes "real"
    #   2 if one of the nodes is "real"
    #   8 if neither node is "real"
    # We use absolute distance in the objective so we'll need
    # auxilary variables for each pair of edges
    obj = AffExpr()
    @variable(m, absdiff[L=1:num_layers-1,
                        i=layer_verts[L], j=adj_list[i]] >= 0)
    for L in 1:num_layers-1
        for i in layer_verts[L]
            for j in adj_list[i]
                @constraint(m, absdiff[L,i,j] >= x[L,i] - x[L+1,j])
                @constraint(m, absdiff[L,i,j] >= x[L+1,j] - x[L,i])
                if i > orig_n && j > orig_n
                    # Both dummy vertices
                    obj += 8*absdiff[L,i,j]
                elseif (i <= orig_n && j >  orig_n) ||
                       (i >  orig_n && j <= orig_n)
                    # Only one dummy vertix
                    obj += 2*absdiff[L,i,j]
                else
                    # Both real
                    obj += absdiff[L,i,j]
                end
            end
        end
    end
    @objective(m, Min, obj)

    # Solve it...
    solve(m)

    # ... and mangle the solution into shape
    x_sol = getvalue(x)
    locs_x = zeros(length(layers))
    for L in 1:num_layers
        for i in layer_verts[L]
            locs_x[i] = x_sol[L,i]
        end
    end
    return locs_x
end
