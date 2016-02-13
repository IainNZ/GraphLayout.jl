using BaseTestNext
using GraphLayout
srand(1)

@testset "GraphLayout.jl" begin

@testset "Render a pentagon" begin
    adj_matrix = ones(5,5) - eye(5,5)
    @testset "layout_spring_adj" begin
        loc_x, loc_y = layout_spring_adj(adj_matrix)

        draw_layout_adj(adj_matrix, loc_x, loc_y, filename="pentagon_spring.svg")

        draw_layout_adj(adj_matrix, loc_x, loc_y, filename="pentagon_labeled.svg",
        	labels=collect(1:5), labelsize=2.0)
        draw_layout_adj(adj_matrix, loc_x, loc_y, filename="pentagon_noarrows.svg",
        	arrowlengthfrac=0.0)
        draw_layout_adj(adj_matrix, loc_x, loc_y, filename="pentagon_longarrows.svg",
        	arrowlengthfrac=0.5)
    end  # "layout_spring_adj"

    @testset "layout_stressmajorize_adj" begin
        X = layout_stressmajorize_adj(adj_matrix)
        draw_layout_adj(adj_matrix, X[:,1], X[:,2], filename="pentagon_stress.svg")
    end  # "layout_stressmajorize_adj"
end  # "Render a pentagon"

@testset "Render a random graph" begin

    adj_matrix = full(sprand(100,100,0.02))
    @testset "layout_spring_adj" begin
        loc_x, loc_y = layout_spring_adj(adj_matrix)

        draw_layout_adj(adj_matrix, loc_x, loc_y, filename="random_spring.svg")

        draw_layout_adj(adj_matrix, loc_x, loc_y, filename="random_spring_color.svg",
            labelc="#000000",
            labelsize=4.0,
            nodefillc="#21AAFF",
            nodestrokec="#7BB1B1",
            edgestrokec="#B11B1B")
    end

    @testset "layout_stressmajorize_adj" begin
        X = layout_stressmajorize_adj(adj_matrix)
        draw_layout_adj(adj_matrix, X[:,1], X[:,2], filename="random_stress.svg")
    end
end  # "Render a random graph"

# Trees
@testset "Render a tree" begin
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

    rm("tree_1.svg")
    rm("tree_2.svg")
end

###############################################################################

@testset "Check that output == cached data" begin

#Compare with cached output
cachedout = joinpath(Pkg.dir("GraphLayout"), "test", "examples")
differentfiles = AbstractString[]
for output in readdir(".")
    endswith(output, ".svg") || continue
    contains(output, "tree") && continue  # don't test trees right now
    cached = open(readall, joinpath(cachedout, output))
    genned = open(readall, joinpath(output))
    if cached != genned
        push!(differentfiles, output)
    else #Delete generated file
        rm(output)
    end
end

#Print out which files differ and their diffs
if length(differentfiles)>0
    #Capture diffs
    diffs = map(
        output -> output * ":\n" *
            readall(ignorestatus(`diff $(joinpath(cachedout, output)) $(joinpath(output))`)) *
            "\n\n",
        differentfiles)
    error(string("Generated output differs from cached test output:\n",
        join(differentfiles, "\n"), "\n\n", join(diffs, "\n")))
else
    println("All files matched!")
end

end  # "Check that output == cached data"

end  # "GraphLayout.jl"
