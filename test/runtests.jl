using FactCheck
using GraphLayout

srand(1)

facts("Render a pentagon") do
    adj_matrix = ones(5,5) - eye(5,5)
    context("layout_spring_adj") do
        loc_x, loc_y = layout_spring_adj(adj_matrix)

        draw_layout_adj(adj_matrix, loc_x, loc_y, filename="pentagon_spring.svg")

        draw_layout_adj(adj_matrix, loc_x, loc_y, filename="pentagon_labeled.svg",
        	labels=[1:5], labelsize=2.0)
        draw_layout_adj(adj_matrix, loc_x, loc_y, filename="pentagon_noarrows.svg",
        	arrowlengthfrac=0.0)
        draw_layout_adj(adj_matrix, loc_x, loc_y, filename="pentagon_longarrows.svg",
        	arrowlengthfrac=0.5)
    end

    context("layout_stressmajorize_adj") do
        X = layout_stressmajorize_adj(adj_matrix)
        draw_layout_adj(adj_matrix, X[:,1], X[:,2], filename="pentagon_stress.svg")
    end
end


# Random graph
facts("Random graph") do

    adj_matrix = full(sprand(100,100,0.02))
    context("layout_spring_adj") do
        loc_x, loc_y = layout_spring_adj(adj_matrix)

        draw_layout_adj(adj_matrix, loc_x, loc_y, filename="random_spring.svg")

        draw_layout_adj(adj_matrix, loc_x, loc_y, filename="random_spring_color.svg",
            labelc="#000000",
            labelsize=4.0,
            nodefillc="#21AAFF",
            nodestrokec="#7BB1B1",
            edgestrokec="#B11B1B")
    end

    context("layout_stressmajorize_adj") do
        X = layout_stressmajorize_adj(adj_matrix)
        draw_layout_adj(adj_matrix, X[:,1], X[:,2], filename="random_stress.svg")
    end
end

# Trees
include("test_tree.jl")

###############################################################################

#Check that output agrees with cached data
#Compare with cached output
cachedout = joinpath(Pkg.dir("GraphLayout"), "test", "examples")
differentfiles = String[]
if VERSION > v"0.4.0-" #Changes to RNG mean that the tests only work on 0.4
    for output in readdir(".")
        endswith(output, ".svg") || continue
        cached = open(readall, joinpath(cachedout, output))
        genned = open(readall, joinpath(output))
        if cached != genned
            push!(differentfiles, output)
        else #Delete generated file
            rm(output)
        end
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

