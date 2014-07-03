# Plot the dependency graph for Gadfly.jl
using GraphLayout

# Load adjacency matrix from file
fp = open("gadfly.txt","r")
adj_matrix = readdlm(fp,',')
close(fp)

# Calculate a layout
loc_x, loc_y = layout_spring_adj(adj_matrix)

# Draw it
draw_layout_adj(adj_matrix, loc_x, loc_y, FILENAME="gadfly.svg")