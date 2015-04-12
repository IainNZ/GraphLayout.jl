# This file provides optimal integer-programming-powered algorithms for
# tree layout. JuMP is not a hard dependency of GraphLayout.jl, but if
# a user wishes to use these methods then they will need JuMP and an
# integer programming solver installed, such as GLPK, Cbc, or one of the
# commercial solvers like Gurobi or CPLEX

using JuMP

@doc """
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
""" ->
function _ordering_ip{T}(adj_list::AdjList{T}, layers, layer_verts)
    num_layers = maximum(layers)

    m = Model()

    # Define crossing binary variables
    @defVar(m, c[L=1:num_layers,        # for each layer
                 i=layer_verts[L],      # for each vertex in this layer
                 j=adj_list[i],         # and vertex in the next layer
                 k=layer_verts[L],      # for each vertex in this layer
                 l=adj_list[k]], Bin)   # and vertex in the next layer

    # Objective: minimize crossings
    @setObjective(m, Min, sum(c))

    # Define permutation variables for each layer
    # We'll define for both (i,j) and (j,i), and ensure they consistency
    # by adding constraints. Presolve in the IP solver will simplify
    # the problem for us by removing one of the variables.
    @defVar(m, x[L=1:num_layers, i=layer_verts[L], j=layer_verts[L]], Bin)
    for L in 1:num_layers
        for i in layer_verts[L]
            for j in layer_verts[L]
                j <= i && continue  # Don't double-add
                # Ensure x[i,j] and x[j,i] are consistent
                @addConstraint(m, x[L,i,j] == 1 - x[L,j,i])
                # And ensure that triples are consistent
                for k in layer_verts[L]
                    k <= j && continue
                    @addConstraint(m, 0 <= x[L,i,j] + x[L,j,k] - x[L,i,k] <= 1)
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
                @addConstraint(m, -c[L,i,j,k,l] <= x[L+1,j,l] - x[L,i,k])
                @addConstraint(m,  c[L,i,j,k,l] >= x[L+1,j,l] - x[L,i,k])
            end
            end
        end
        end
    end

    # Solve the IP
    solve(m)

    # Extract permutation from solution
    x_sol = getValue(x)
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
                if iround(x_sol[L,i,j]) == 1
                    # i appears before j
                    scores[p] += 1
                end
            end
        end
        new_layer_verts[L] = old_perm[sortperm(scores,rev=true)]
    end

    return new_layer_verts
end