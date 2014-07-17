using GraphLayout

# Pentagon
adj_matrix = ones(5,5) - eye(5,5)
loc_x, loc_y = layout_spring_adj(adj_matrix)
draw_layout_adj(adj_matrix, loc_x, loc_y, filename="pentagon.svg")

# Random graph
adj_matrix = full(sprand(100,100,0.02))
loc_x, loc_y = layout_spring_adj(adj_matrix)
draw_layout_adj(adj_matrix, loc_x, loc_y, filename="random.svg")
