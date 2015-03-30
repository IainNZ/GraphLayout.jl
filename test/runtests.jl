using GraphLayout

srand(1)

# Pentagon
adj_matrix = ones(5,5) - eye(5,5)
loc_x, loc_y = layout_spring_adj(adj_matrix)

draw_layout_adj(adj_matrix, loc_x, loc_y, filename="pentagon.svg")
adj_matrix = ones(5,5) - eye(5,5)
loc_x, loc_y = layout_spring_adj(adj_matrix)
draw_layout_adj(adj_matrix, loc_x, loc_y, filename="pentagon_labeled.svg",
	labels=[1:5], labelsize=2.0)
draw_layout_adj(adj_matrix, loc_x, loc_y, filename="pentagon_noarrows.svg",
	arrowlengthfrac=0.0)
draw_layout_adj(adj_matrix, loc_x, loc_y, filename="pentagon_longarrows.svg",
	arrowlengthfrac=0.5)

draw_layout_adj(adj_matrix, loc_x, loc_y, filename="pentagon_spring.svg")

X = layout_stressmajorize_adj(adj_matrix)
draw_layout_adj(adj_matrix, X[:,1], X[:,2], filename="pentagon_stress.svg")


# Random graph
adj_matrix = full(sprand(100,100,0.02))
loc_x, loc_y = layout_spring_adj(adj_matrix)

draw_layout_adj(adj_matrix, loc_x, loc_y, filename="random.svg")

adj_matrix = full(sprand(100,100,0.02))
loc_x, loc_y = layout_spring_adj(adj_matrix)
draw_layout_adj(adj_matrix, loc_x, loc_y, filename="random_spring_color.svg",
    labelc="#000000",
    labelsize=4.0,
    nodefillc="#21AAFF",
    nodestrokec="#7BB1B1",
    edgestrokec="#B11B1B")

draw_layout_adj(adj_matrix, loc_x, loc_y, filename="random_spring.svg")

X = layout_stressmajorize_adj(adj_matrix)
draw_layout_adj(adj_matrix, X[:,1], X[:,2], filename="random_stress.svg")
