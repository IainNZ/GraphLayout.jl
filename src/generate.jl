using GeometryTypes

"""
Given an adjacency matrix and two vectors of X, Y and Z coordinates, returns
the layout object.

Arguments:
    adj_matrix       Adjacency matrix of some type. Non-zero of the eltype
                     of the matrix is used to determine if a link exists,
                     but currently no sense of magnitude
    locs_x, locs_y,
    locs_z            Locations of the nodes.

Returns:
    layout            Layout of the given graph represented as a GraphLayout.Network object.

"""

function generate_layout{S, T<:Real}(
  adj_matrix::Array{S,2},
  locs_x::Vector{T}, locs_y::Vector{T}, locs_z::Vector{T}=T[];
  z::Bool = true,
  directed::Bool=false,
  )

  dim = size(locs_z,1)
  size(adj_matrix, 1) != size(adj_matrix, 2) && error("Adj. matrix must be square.")
  const N = length(locs_x)
  if z
    nodes = [Node(Point(locs_x[i], locs_y[i], locs_z[i])) for i in 1:N]
  else
    nodes = [Node(Point(locs_x[i], locs_y[i])) for i in 1:N]
  end
  edges = find_edges(adj_matrix, nodes, directed)
  layout = Network(nodes, edges)
  return layout

end

function find_edges(adj_matrix, nodes::Array{Node,1}, directed::Bool=false)

  size(adj_matrix, 1) != size(adj_matrix, 2) && error("Adj. matrix must be square.")
  const N = length(nodes)
  edges = Edge[]
  for i = 1:N
    for j = 1:N
      i == j && continue
      if adj_matrix[i,j] != zero(eltype(adj_matrix))
        push!(edges, Edge(i, j, directed))
      end
    end
  end
  return edges

end
