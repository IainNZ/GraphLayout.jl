using GraphLayout

# Pentagon
adj_matrix = ones(5,5) - eye(5,5)
loc_x, loc_y = layout_spring_adj(adj_matrix)
draw_layout_adj(adj_matrix, loc_x, loc_y, filename="pentagon.svg")
adj_matrix = ones(5,5) - eye(5,5)
loc_x, loc_y = layout_spring_adj(adj_matrix)
draw_layout_adj(adj_matrix, loc_x, loc_y, filename="pentagon-labeled.svg",
	labels=[1:5], labelsize=2.0)
draw_layout_adj(adj_matrix, loc_x, loc_y, filename="pentagon-noarrows.svg",
	arrowlengthfrac=0.0)
draw_layout_adj(adj_matrix, loc_x, loc_y, filename="pentagon-longarrows.svg",
	arrowlengthfrac=0.5)

# Random graph
adj_matrix = full(sprand(100,100,0.02))
loc_x, loc_y = layout_spring_adj(adj_matrix)
draw_layout_adj(adj_matrix, loc_x, loc_y, filename="random.svg")

adj_matrix = full(sprand(100,100,0.02))
loc_x, loc_y = layout_spring_adj(adj_matrix)
draw_layout_adj(adj_matrix, loc_x, loc_y, filename="random-color.svg",
    labelc="#000000",
    labelsize=4.0,
    nodefillc="#21AAFF",
    nodestrokec="#7BB1B1",
    edgestrokec="#B11B1B")
