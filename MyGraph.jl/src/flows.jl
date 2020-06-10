function bfs(g::Graph, s::Int, t::Int, parents::Vector{Int})::Tuple{Bool, Array{Int,1}}
    visited = falses(nv(g))

    queue = Int[]
    push!(queue, s)
    visited[s] = true

    while length(queue) > 0
        u = pop!(queue)
        for v in delta(g, u)
            if visited[v] == false
                push!(queue, v)
                parents[v] = u
                visited[v] = true
            end
        end
    end

    return (visited[t], [i for i in 1:nv(g) if visited[i]])
end

function fordfulkerson(g::Graph, s::Int, t::Int)::Tuple{Float64, Array{Int, 1}}
    resg = deepcopy(g)
    parents = Vector{Int}(undef, nv(g))
    maxflow = 0

    is_reachable, visited = bfs(resg, s, t, parents)
    is_good = true
    for vi in vertices(resg), vj in vertices(resg)
        if has_edge(resg, vi, vj) && weight(resg, vi, vj) < 0
            is_good = false;
            println(resg)
        end
    end
    @assert is_good

    while is_reachable
        pathflow = typemax(Float64)
        v = t
        while v != s
            # println(v)
            u = parents[v]
            pathflow = min(pathflow, weight(resg, u, v))
            v = u
        end
        # print("W fulkersonie, $(parents), - $(pathflow)")
        v = t
        while v != s
            # println(v)
            u = parents[v]
            add_edge!(resg, u, v, weight(resg, u, v) - pathflow)
            add_edge!(resg, v, u, weight(resg, v, u) + pathflow)
            v = u
        end

        maxflow += pathflow

        for vi in vertices(resg), vj in vertices(resg)
            if has_edge(resg, vi, vj) && weight(resg, vi, vj) < 0
                is_good = false;
                println(resg)
            end
        end
        @assert is_good

        is_reachable, visited = bfs(resg, s, t, parents)
    end
    return (maxflow, visited)
end
