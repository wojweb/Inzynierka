module MyGraph

    using SparseArrays

    export Graph, has_vertex, has_edge, nv, ne, add_edge!, rem_edge!,
    vertices, delta, degree, is_connected, rem_vertex!, min_edge_contraction!, weight,
    is_bipartite, get_origin, delta_in, delta_out

    export generateConnectedGraph, generateConnectedDiGraph, generateBipartiteGraph
    export save, read
    export fordfulkerson


    include("graph.jl")
    include("generators.jl")
    include("io.jl")
    include("flows.jl")

end
