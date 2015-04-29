using GraphLayout

adj_list = Vector{Int}[
    [2,3,4],
    [4],
    [4],
    []
]
labels = ["Apple", "Banana", "Carrot", "Durian"]

layout_tree(adj_list,labels,filename="tree_1.svg",
            cycles = false, ordering = :optimal, coord = :optimal,
            xsep = 5, ysep = 10, scale = 0.2, labelpad = 1.2,
            background = nothing)

layout_tree(adj_list,labels,filename="tree_2.svg",
            cycles = false, ordering = :optimal, coord = :optimal,
            xsep = 1, ysep = 20, scale = 0.1, labelpad = 2,
            background = "#DDDDFF")