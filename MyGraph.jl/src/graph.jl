
mutable struct Graph
    n::Int
    vertices::Vector{Int}
    edges::Vector{Vector{Tuple{Int, Float64}}}
    is_directed::Bool
    function Graph(n::Int, is_directed::Bool=false)
        es = Vector{Vector{Tuple{Int, Float64}}}(undef, n)
        vs = Vector{Int}(undef, n)
        for i = 1:n
            es[i] = Vector{Tuple{Int, Float64}}(undef, 0)
            vs[i] = i
        end
        new(n, vs, es, is_directed)
    end
end

function has_vertex(g::Graph, v::Int)::Bool
    return in(v, g.vertices)
end

function has_edge(g::Graph, v1::Int, v2::Int)::Bool
    if has_vertex(g, v1)
        for v in g.edges[v1]
            if first(v) == v2
                return true
            end
        end
    end
    return false
end

function ne(g::Graph)::Int
    sum = 0
    for e in g.edges
        sum += length(e)
    end

    if g.is_directed
        return sum
    else
        return sum / 2
    end
end

function nv(g::Graph)::Int
    return length(g.vertices)
end

function add_edge!(g::Graph, v1::Int, v2::Int, w::Float64)

    rem_edge!(g, v1, v2)

    if round(w, digits=8) == 0.
        return nothing
    end


    push!(g.edges[v1], (v2, w))

    if !g.is_directed
        push!(g.edges[v2], (v1, w))
    end

    nothing
end


function add_edge!(g::Graph, v1::Int, v2::Int, w::Int)
    add_edge!(g, v1, v2, convert(Float64, w))
    nothing
end

function rem_edge!(g::Graph, v1::Int, v2::Int)
    filter!(x -> first(x) != v2, g.edges[v1])
    if !g.is_directed
        filter!(x -> first(x) != v1, g.edges[v2])
    end
    nothing
end

function weight(g::Graph, v1::Int, v2::Int)::Float64
    for v in g.edges[v1]
        if first(v) == v2
            return v[2]
        end
    end
    return 0.
end

function vertices(g::Graph)::Vector{Int}
    return g.vertices
end

function rem_vertex!(g::Graph, v::Int)
    for vi in vertices(g)
        filter!(x -> first(x) != v, g.edges[vi])
    end
    filter!(x -> false, g.edges[v])
    filter!(x -> x != v, g.vertices)
    nothing
end

# Dla digrafow krawedzie wychodzace
function delta(g::Graph, v::Int)::Vector{Int}
    return [first(e) for e = g.edges[v]]
end

function delta(g::Graph, vs::Vector{Int})::Vector{Int}
    answer = Vector{Int}(undef, 0)
    for v in vs
        for vi in delta(g, v)
            if !in(vi, answer) && !in(vi, vs)
                push!(answer, vi)
            end
        end
    end
    return answer
end

function delta_in(g::Graph, v::Int)::Vector{Int}
    d_in = Vector{Int}(undef, 0)

    for vi in vertices(g)
        if v in [first(e) for e = g.edges[vi]] push!(d_in, vi) end
    end
    return d_in
end

function delta_out(g::Graph, v::Int)::Vector{Int}
    return [first(e) for e = g.edges[v]]
end

function degree(g::Graph, v::Int)::Int
    return length(g.edges[v])
end

function is_connected(g::Graph, r::Int = first(vertices(g)))::Bool
    visited = fill(false, g.n)

    explore(g, visited, r)

    for v = 1:g.n
        if has_vertex(g, v) && visited[v] == false
            return false
        end
    end
    return true
end

function explore(g::Graph, visited::Vector{Bool}, v::Int)
    visited[v] = true
    for vi in delta(g, v)
        if ! visited[first(vi)]
            explore(g, visited, first(vi))
        end
    end
end

function is_bipartite(g::Graph)::Bool
    # Sprawdzamy dwudzielnosc, przez probe pokolorowania dwoma kolorami
    # -1 nieodwiedzone, 0 - jeden kolor, 1 - drugi kolor
    color_array =  Vector{Int}(undef, nv(g))
    fill!(color_array, -1)
    stack = Vector{Int}(undef,0)

    color_array[1] = 1
    push!(stack, first(vertices(g)))

    while length(stack) != 0
        v = pop!(stack)

        # w grafie dwudzielnym, nie moze byc petli
        if has_edge(g, v, v)
            return false
        end

        for u in [first(d) for d in delta(g, v)]
            if color_array[u] == -1
                # Przypis alternatywny numer
                color_array[u] = 1 - color_array[v]
                push!(stack,u)
            end

            # Jesli obok siebie maja ten sam numer, to nie  jest dwudzielny.
            if color_array[u] == color_array[v]
                return false
            end
        end
    end

    return true

end

function get_origin(g::Graph, v1::Int, v2::Int)::Tuple{Int,Int}
    for p_v in g.edges[v1]
        if first(p_v) == v2
            return p_v[3], p_v[4]
        end
    end
    return nothing
end

function min_edge_contraction!(g::Graph, v1::Int, v2::Int)
    if !(has_vertex(g, v1) && has_vertex(g, v2))
        return nothing
    end
#   wychodzace
    for p_vi in g.edges[v2]
        if first(p_vi) == v1 continue end

        if has_edge(g, v1, first(p_vi)) && weight(g, v1, first(p_vi)) <= p_vi[2]
            nothing
        else
            (a,b) = get_origin(g, v2, first(p_vi))
            add_edge!(g, v1, first(p_vi), p_vi[2], a, b)
        end
    end

    #wchodzace
    for vi in vertices(g)
        if vi == v1 || vi == v2 continue end
        if has_edge(g, vi, v2)
            if has_edge(g, vi, v1) && weight(g, vi, v1) <= weight(g, vi, v2)
                nothing
            else
                (a,b) = get_origin(g, vi, v2)
                add_edge!(g, vi, v1, weight(g, vi, v2), a, b)
            end
        end
    end

    rem_vertex!(g, v2)
    nothing
end

function weight(g::Graph)::Float64
    sum = 0.
    for vi in vertices(g)
        for vj in g.edges[vi]
            if g.is_directed
                sum += vj[2]
            elseif first(vj) < vi
                sum += vj[2]
            end
        end
    end
    return sum
end
