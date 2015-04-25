@doc """
    Hierachical drawing of directed graphs inspired by the Sugiyama framework.
    In particular see Chapter 13 of 'Hierachical Drawing Algorithms' from
    the 'Handbook of Graph Drawing and Visualization' and the article
      K. Sugiyama, S. Tagawa, and M. Toda. Methods for visual understanding
      of hierarchical system structures. IEEE Transaction on Systems, Man,
      and Cybernetics, 11(2):109–125, 1981.

    The method as implemented here has 4 steps:
    1. Cycle removal [if needed]
    2. Layer assignment + break up long edges
    3. Vertex ordering [to reduce crossings]
    4. Vertex coordinates [to straighten edges]
    5. Draw the tree

    Arguments:
    adj_list        Directed graph in adjacency list format

    Optional arguments for layout:
    cycles          If false, assume no cycles. Default true.
    ordering        Vertex ordering method to use. Options are:
                        :optimal        Uses JuMP (integer program)
                        :barycentric    Sugiyama heuristic
    coord           Vertex coordinate method to use. Options are:
                        :optimal        Uses JuMP (linear program)

    Optional arguments for drawing:
""" ->
function layout_tree{T}(adj_list::AdjList{T}; 
                        # Layout arguments
                        cycles      = true,
                        ordering    = :optimal,
                        coord       = :optimal,
                        xsep        = 1,
                        ysep        = 20,
                        # Drawing arguments
                        labels      = Any[],
                        filename    = "",
                        scale       = 0.05)

    # Calculate the original number of vertices
    n = length(adj_list)

    # 1     Cycle removal
    if cycles
        # Need to remove cycles first
        error("Cycle removal not implemented!")
    end

    # 2     Layering
    # 2.1   Assign a layer to each vertex
    layers = _layer_assmt_longestpath(adj_list)
    num_layers = maximum(layers)
    # 2.2  Create dummy vertices for long edges
    adj_list, layers = _layer_assmt_dummy(adj_list, layers)
    orig_n, n = n, length(adj_list)


    # 3     Vertex ordering [to reduce crossings]
    # 3.1   Build initial permutation vectors
    layer_verts = [L => Int[] for L in 1:num_layers]
    for i in 1:n
        push!(layer_verts[layers[i]], i)
    end
    # 3.2  Reorder permutations to reduce crossings
    if ordering == :barycentric
        layer_verts = _ordering_barycentric(adj_list, layers, layer_verts)
    elseif ordering == :optimal
        layer_verts = _ordering_ip(adj_list, layers, layer_verts)
    end
    

    # 4     Vertex coordinates [to straighten edges]
    # 4.1   Place y coordinates in layers
    locs_y = zeros(n)
    for L in 1:num_layers
        for (x,v) in enumerate(layer_verts[L])
            locs_y[v] = (L-1)*ysep
        end
    end
    # 4.2   Get widths of each label, if there are any
    widths  = ones(n); widths[orig_n+1:n]  = 0
    heights = ones(n); heights[orig_n+1:n] = 0
    if length(labels) == orig_n
        extents = text_extents("sans",10pt,labels...)
        for (i,(width,height)) in enumerate(extents)
            widths[i], heights[i] = width.abs, height.abs
        end
    end
    locs_x = _coord_ip(adj_list, layers, layer_verts, orig_n, widths, xsep)
    # 4.3   Summarize vertex info
    max_x, max_y = maximum(locs_x), maximum(locs_y)
    max_w, max_h = maximum(widths), maximum(heights)


    # 5     Draw the tree
    # 5.1   Create the vertices
    verts = [_tree_textrect(locs_x[i]*cx,locs_y[i]*cy,labels[i]) for i in 1:orig_n]
    # 5.2   Create the arrows
    arrows = Any[]
    for L in 1:num_layers, i in layer_verts[L], j in adj_list[i]
        push!(arrows, _arrow_tree(
                locs_x[i],locs_y[i], i<=orig_n?max_h:0,
                locs_x[j],locs_y[j], j<=orig_n?max_h:0))
    end
    # 5.3   Assemble composition
    c = compose(
        context(units=UnitBox(-max_w/2,-max_h/2,max_x+max_w,max_y+max_h)),
        font("sans"), fontsize(8.0pt),
        rectangle(), fill("#FAFAFA"),
        verts..., arrows...
    )
    # 5.4   Draw it
    if filename != ""
        draw(SVG(filename, scale*max_x*inch, scale*max_y*inch), c)
    end
    return c
end



@doc """
    Creates a rectangle with text inside it for use in tree drawing.

    Arguments:
    x,y             Center of rectangle/text (in context units)
    label           The text inside the rectangle
    pad             Padding factor, default = 1.1           
    font_size       Size of font, default = 8pt
    font_face       Font to use, default = "sans"
""" ->
function _tree_textrect(x, y, label, pad=1.2, font_size=8.0pt, font_face="sans")
    width, height = text_extents(font_face, font_size, label)[1]
    width, height = pad*width, pad*height
    compose(
        context(x - width/2, y - height/2, width, height),
        (context(), text(0.5w, 0.5h, label, hcenter, vcenter), fill("black")),
        (context(), rectangle(), fill("white"), stroke("black"))
    )
end



@doc """
    Creates an arrow between two rectangles in the tree

    Arguments:
    o_x, o_y, o_h   Origin x, y, and height
    d_x, d_y, d_h   Destination x, y, and height
""" ->
function _arrow_tree(o_x, o_y, o_h, d_x, d_y, d_h)
    x1, y1 = o_x, o_y + o_h/2
    x2, y2 = d_x, d_y - d_h/2
    Δx, Δy = x2 - x1, y2 - y1
    θ = atan2(Δy,Δx)
    # Put an arrow head only if destination isn't dummy
    head = d_h != 0 ? _arrow_heads(θ, x2, y2, 2) : []
    compose(context(), stroke("black"),
        line([(x1,y1),(x2,y2)]), head...)
end


@doc """
    Creates an arrow head given the angle of the arrow and its destination.

    Arguments:
    θ               Angle of arrow (radians)
    dest_x, dest_y  End of arrow
    λ               Length of arrow head tips
    ϕ               Angle of arrow head tips relative to angle of arrow
""" ->
_arrow_heads(θ, dest_x, dest_y, λ, ϕ=0.125π) = [ line([
    (dest_x - λ*cos(θ+ϕ), dest_y - λ*sin(θ+ϕ)),
    (dest_x, dest_y),
    (dest_x - λ*cos(θ-ϕ), dest_y - λ*sin(θ-ϕ))
]) ]