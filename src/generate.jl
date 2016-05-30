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
"""
