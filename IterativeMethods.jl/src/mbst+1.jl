function mbst_additive_one(h::Graph, w::Set{Int}, b::Dict{Int, Int})::Tuple{Graph, Vector{Int}}
    g = deepcopy(h)
    w = deepcopy(w)
    f = Graph(nv(g))

    number_of_edges = Vector{Int}(undef, 0)

    if ! is_connected(g)
        error("Graf nie jest spójny")
    end

    for v in keys(b)
        if !(v in w)
            error("Niewlasciwe dane")
        end
    end

    while  length(w) > 0
        if !is_connected(g)
            print(g)
        end
        @assert is_connected(g)

        model = Model(actual_optimizer) # actual_optimizer jest zmienna modulowa
        subsets = Vector{Vector{Int}}(undef, 0)
        is_feasible = false
        @variable(model, 0 <= x[vi in vertices(g), vj in vertices(g);
            vi > vj && has_edge(g, vi, vj)])

        push!(number_of_edges, ne(g))
        ex = AffExpr()
        for vi in vertices(g), vj in vertices(g)
            if vi > vj && has_edge(g, vi, vj)
                add_to_expression!(ex, weight(g, vi, vj), x[vi, vj])
            end
        end

        @objective(model, Min, ex)
        ex = AffExpr()
        for vi in vertices(g), vj in vertices(g)
            if vi > vj && has_edge(g, vi, vj)
                add_to_expression!(ex, 1, x[vi, vj])
            end
        end
        @constraint(model, ex == nv(g) - 1)

        for vi in w
            ex = AffExpr()
            for vj in vertices(g)
                if has_edge(g, vi, vj)
                    if vi > vj
                        add_to_expression!(ex, 1, x[vi,vj])
                    else
                        add_to_expression!(ex, 1, x[vj, vi])
                    end
                end
            end
            @constraint(model, ex <= b[vi])
        end

        while !is_feasible
            t = @elapsed optimize!(model)
            if termination_status(model) != MOI.OPTIMAL
                error(("Nie znalezniono optymalnego rozwiązania", termination_status(model), model))
            end
            is_feasible = true

            for vx in vertices(g), vy in vertices(g)
                if vx > vy
                    gprim = Graph(nv(h) + 2, true) # source = nv, sink = nv + 1
                    source = nv(h) + 1
                    sink = nv(h) + 2
                    for vi in vertices(g), vj in vertices(g)
                        if vi > vj && has_edge(g, vi, vj)
                            add_edge!(gprim, vi, vj, 0.5 * round(value(x[vi, vj]), digits=8))
                            add_edge!(gprim, vj, vi, 0.5 * round(value(x[vi, vj]), digits=8))
                        end
                    end

                    for vi in vertices(g)
                        sum = 0.
                        for vj in delta(g, vi)
                            sum += value(x[max(vi, vj),min(vi, vj)])
                        end
                        add_edge!(gprim, source, vi, sum / 2)
                        add_edge!(gprim, vi, sink, 1.)
                    end
                    add_edge!(gprim, source, vx, typemax(Float64))
                    add_edge!(gprim, source, vy, typemax(Float64))

                    flow, visited = fordfulkerson(gprim, source, sink)
                    if round(flow, digits = 4)< nv(g)
                        filter!(x -> x != source, visited)
                        is_feasible = false
                        ex = AffExpr()
                        for vi in visited, vj in visited
                            if vi > vj && has_edge(g, vi, vj)
                                add_to_expression!(ex, 1, x[vi, vj])
                            end
                        end
                        @constraint(model, ex <= length(visited) - 1)
                        break
                    end

                end
            end
        end

        for vi in vertices(g), vj in vertices(g)
            if vi > vj && has_edge(g, vi, vj) && round(value(x[vi, vj]), digits=8) == 0
                rem_edge!(g, vi, vj)
            end
        end

        for vi in w
            if degree(g,vi) <= b[vi] + 1
                setdiff!(w, [vi])
                break;
            end
        end

    end

    # Prim algorithm
    connected_vertices = [1]
    while length(connected_vertices) != nv(g)
        min_edge = (floatmax(),0,0)
        for vi in connected_vertices, vj in
            [v for v in vertices(g) if !in(v, connected_vertices)]
            if has_edge(g, vi, vj) && weight(g, vi, vj) < first(min_edge)
                min_edge = (weight(g, vi, vj), vi, vj)
            end
        end
        add_edge!(f, min_edge[2], min_edge[3], min_edge[1])
        push!(connected_vertices, min_edge[3])
    end
    return (f, number_of_edges)
end
