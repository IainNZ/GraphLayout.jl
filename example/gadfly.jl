# Plot the dependency graph for Gadfly.jl
using GraphLayout

# Load adjacency matrix from file
fp = open("gadfly.txt","r")
adj_matrix = readdlm(fp,',')
close(fp)

# Load node labels
fp = open("gadfly_names.txt","r")
labels = map(chomp,readlines(fp))
close(fp)

# Calculate a layout
#srand(4)
#println("Layout...")
#loc_x, loc_y = layout_spring_adj(adj_matrix)

# Draw it
#rintln("Drawing...")
#draw_layout_adj(adj_matrix, loc_x, loc_y, labels=labels, filename="gadfly.svg")


adj_list = Vector{Int}[]
for i in 1:size(adj_matrix,1)
    new_list = Int[]
    for j in 1:size(adj_matrix,2)
        if adj_matrix[i,j] != zero(eltype(adj_matrix))
            push!(new_list,j)
        end
    end
    push!(adj_list, new_list)
end

loc_x, loc_y, exp_adj_list = 
    GraphLayout.layout_tree(adj_list, cycles=false, ordering=:optimal)

# Correct for dummy nodes
for i in 1:(length(loc_x)-length(adj_list))
    push!(labels, "")
end
exp_adj_matrix = zeros(length(loc_x),length(loc_y))
for (i,lst) in enumerate(exp_adj_list)
    for j in lst
        exp_adj_matrix[i,j] = 1
    end
end
draw_layout_adj(exp_adj_matrix, loc_x, loc_y, labels=labels, filename="test.svg", labelsize=2.0)