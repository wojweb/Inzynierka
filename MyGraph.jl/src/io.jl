function save(g::Graph, filename::String)
    io = open(filename, "w")
    for i in vertices(g)
        for j in vertices(g)
            write(io, "$(weight(g, i, j)),")
        end
        write(io, "\n")
    end
    close(io)
end

function read(filename::String)::Graph
    io = open(filename)
    lines = readlines(io)

    g = Graph(length(lines), true)
    for i = 1:length(lines)
        elements = split(lines[i], ",")
        for j = 1:length(elements) - 1
            add_edge!(g, i, j, parse(Float64, elements[j]))
        end
    end
    close(io)

    g.is_directed = false
    for i in vertices(g)
        for j in vertices(g)
            if weight(g, i, j) != weight(g, j, i)
                g.is_directed = true
            end
        end
    end

    return g
end

