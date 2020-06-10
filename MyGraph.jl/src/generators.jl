function generateConnectedGraph(n::Int)::Graph
    g = Graph(n)

    for i = 1:n
        for j = 1:(i - 1)
            add_edge!(g, i, j, rand([1:20;]))
        end
    end

    if is_connected(g)
        return g
    else
        return generateConnectedGraph(n)
    end
end

function generateConnectedDiGraph(n::Int, root::Int)::Graph
    g = Graph(n, true)

    for i = 1:n
        for j = 1:n
            if i == j continue end
            add_edge!(g, i, j, rand([1:20;]))
        end
    end

    if is_connected(g, root)
        return g
    else
        return generateConnectedDiGraph(n, root)
    end
end

function generateBipartiteGraph(left::Int, right::Int)::Graph
    g = Graph(left + right)

    for i = 1:left, j = (left+1):(left+right)
        add_edge!(g, i, j, rand([1:20;]))
    end

    if is_connected(g) && is_bipartite(g)
        return g
    else
        return generateBipartiteGraph(left, right)
    end
end
