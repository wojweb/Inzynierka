

function snd(h::Graph, r::Array{Int, 2})::Tuple{Graph, Vector{Int}}
    g = deepcopy(h)
    f = Graph(nv(g))
    sizes_per_iteration = Vector{Float64}(undef, 0)
    f_is_not_fisible = true
    while f_is_not_fisible
        model = Model(actual_optimizer)
        push!(sizes_per_iteration, ne(g))

        subsets = Vector{Vector{Int}}(undef, 0)
        is_feasible = false
        @variable(model, 0 <= x[vi in vertices(g), vj in vertices(g);
            vi > vj && has_edge(g, vi, vj)] <= 1)
    
        ex = AffExpr()
        for vi in vertices(g), vj in vertices(g)
            if vi > vj && has_edge(g, vi, vj)
                add_to_expression!(ex, weight(g, vi, vj), x[vi, vj])
            end
        end
        
        @objective(model, Min, ex)
        
        ex = AffExpr()
         
        while !is_feasible
            is_feasible = true

            optimize!(model)
            if termination_status(model) != MOI.OPTIMAL
                error(("Nie znalezniono optymalnego rozwiązania", termination_status(model), model))
            end

            for vx in vertices(g), vy in vertices(g)
                if vx != vy
                    gprim = Graph(nv(g), true) # source = nv, sink = nv + 1
                    source = vx
                    sink = vy
                    for vi in vertices(g), vj in vertices(g)
                        if vi > vj && has_edge(g, vi, vj)
                            add_edge!(gprim, vi, vj,  round(JuMP.value(x[vi, vj]), digits=8))
                            add_edge!(gprim, vj, vi,  round(JuMP.value(x[vi, vj]), digits=8))
                        end

                        if vi > vj && has_edge(f, vi, vj)
                            add_edge!(gprim, vi, vj, 1)
                            add_edge!(gprim, vj, vi, 1)
                        end
                    end
        
                    flow, visited = fordfulkerson(gprim, source, sink)
                    if round(flow, digits = 4) < r[source, sink]
                        is_feasible = false
                    
                        ex = AffExpr() 
                        r_max = 0
                        for vi in visited, vj in [v for v in vertices(g) if !in(v, visited)]
                            if vi > vj && has_edge(g, vi, vj)
                                add_to_expression!(ex, 1, x[vi, vj])
                            end
                            if vj > vi && has_edge(g, vi, vj)
                                add_to_expression!(ex, 1, x[vj, vi])
                            end

                            if r[vi, vj] >= r_max
                                r_max = r[vi, vj]
                            end
                        end

                        @constraint(model, ex >= r_max - length(delta(f, visited)))
                        break
                    end
                end
            end
        end

        for vi in vertices(g), vj in vertices(g)
            if vi > vj && has_edge(g, vi, vj) && value(x[vi, vj]) >= 1/2
                add_edge!(f, vi, vj, weight(g, vi, vj))
                rem_edge!(g, vi, vj)
            end
        end


        f_is_not_fisible = false
        fprim = Graph(nv(f), true)
        for vi in vertices(g), vj in vertices(g)
            if vi > vj && has_edge(f, vi, vj)
                add_edge!(fprim, vi, vj, 1)
                add_edge!(fprim, vj, vi, 1)
            end
        end
        for vx in vertices(f), vy in vertices(f)
            if vx != vy
                flow, visited = fordfulkerson(fprim, vx, vy)
                if round(flow, digits = 4) < r[vx, vy]
                    f_is_not_fisible = true
                    break
                end
            end
        end

    end

    return  (f, sizes_per_iteration) 
end