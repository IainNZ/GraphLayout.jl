# This file provides optimal integer-programming-powered algorithms for
# tree layout. JuMP is not a hard dependency of GraphLayout.jl, but if
# a user wishes to use these methods then they will need JuMP and an
# integer programming solver installed, such as GLPK, Cbc, or one of the
# commercial solvers like Gurobi or CPLEX

using JuMP

@doc """
    Given a layer assignment, decide a permutation for each layer
    that minimizes edge crossings using integer programming.

    Arguments:
    adj_list        Directed graph in adjacency list format
    layers          Assignment of vertices
    layer_verts     Dictionary of layer => vertices
""" ->
function _ordering_ip{T}(adj_list::AdjList{T}, layers, layer_verts)
    num_layers = maximum(layers)

    m = Model()

    # Define crossing binary variables
    @defVar(m, c[L=1:num_layers,
                 i=layer_verts[L],
                 j=adj_list[i],
                 k=layer_verts[L],
                 l=adj_list[k]], Bin)

    # Define permutation variables for each layer
    # We'll define for both (i,j) and (j,i), and they are consistent
    # by adding constraints. Presolve in the IP solver will simplify
    # the problem for us by removing one of the variables.
    @defVar(m, x[L=1:num_layers,
                 i=layer_verts[L],
                 j=layer_verts[L]], Bin)
    for L in 1:num_layers
        for (p,i) in enumerate(layer_verts[L])
            for (q,j) in enumerate(layer_verts[L])
                p <= q && continue
                @addConstraint(m, x[L,i,j] == 1 - x[L,j,i])
            end
        end
    end

    # Objective: minimize crossings
    @setObjective(m, Min, sum(c))

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

    # Enforce consistency in permutations
    for L in 1:num_layers
        for i in layer_verts[L]
            for j in layer_verts[L]
                j <= i && continue
                for k in layer_verts[L]
                    k <= j && continue
                    @addConstraint(m, 0 <= x[L,i,j] + x[L,j,k] - x[L,i,k] <= 1)
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