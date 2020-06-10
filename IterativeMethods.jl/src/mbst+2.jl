function mbst_additive_two(h::Graph, w::Set{Int}, b::Dict{Int, Int})::Graph
    g = deepcopy(h)
    f = Graph(nv(g))

    if ! is_connected(g)
        error("Graf nie jest spójny")
    end

    for v in keys(b)
        if !(v in w)
            error("Niewlasciwe dane")
        end
    end

    while nv(g) >= 2
        if !is_connected(g)
            print(g)
        end
        @assert is_connected(g)

        model = Model(actual_optimizer) # actual_optimizer jest zmienna modulowa
        subsets = Vector{Vector{Int}}(undef, 0)
        is_feasible = false
        @variable(model, 0 <= x[vi in vertices(g), vj in vertices(g);
            vi > vj && has_edge(g, vi, vj)])

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
            @constraint(model, ex <= b)
        end

        while !is_feasible
            optimize!(model)
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

        is_leaf = false
        for vi in vertices(g)
            if degree(g, vi) == 1
                vj = delta(g, vi)[1]
                add_edge!(f, vi, vj, weight(g, vi, vj))
                rem_vertex!(g, vi)
                is_leaf = true
            end
        end
    end
    return f
end
