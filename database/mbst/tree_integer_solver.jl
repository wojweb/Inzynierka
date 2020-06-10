using MyGraph
using JuMP
using CPLEX

function mbst_opt(h::Graph, b::Int)::Int
    g = deepcopy(h)
    model = Model(CPLEX.Optimizer)
    intModel = Model(CPLEX.Optimizer)
    
    subsets = Vector{Vector{Int}}(undef, 0)
    is_feasible = false
    @variable(model, 0 <= x[vi in vertices(g), vj in vertices(g);
        vi > vj && has_edge(g, vi, vj)])
    
    @variable(intModel, 0 <= y[vi in vertices(g), vj in vertices(g);
        vi > vj && has_edge(g, vi, vj)], Bin)
    
    
    ex = AffExpr()
    ey = AffExpr()
    
    for vi in vertices(g), vj in vertices(g)
        if vi > vj && has_edge(g, vi, vj)
            add_to_expression!(ex, weight(g, vi, vj), x[vi, vj])
            add_to_expression!(ey, weight(g, vi, vj), y[vi, vj])
            
        end
    end
    
    @objective(model, Min, ex)
    @objective(intModel, Min, ey)
    
    ex = AffExpr()
    ey = AffExpr()
    
    for vi in vertices(g), vj in vertices(g)
        if vi > vj && has_edge(g, vi, vj)
            add_to_expression!(ex, 1, x[vi, vj])
            add_to_expression!(ey, 1, y[vi, vj])
        end
    end
    @constraint(model, ex == nv(g) - 1)
    @constraint(intModel, ey == nv(g) - 1)

    ex = AffExpr()
    ey = AffExpr()

    for vi in vertices(g)
        ex = AffExpr()
        ey = AffExpr()
        for vj in vertices(g)
            if has_edge(g, vi, vj)
                if vi > vj
                    add_to_expression!(ex, 1, x[vi,vj])
                    add_to_expression!(ey, 1, y[vi,vj])
                else
                    add_to_expression!(ex, 1, x[vj, vi])
                    add_to_expression!(ey, 1, y[vj, vi])
                end
            end
        end
        @constraint(model, ex <= b)
        @constraint(intModel, ey <= b)
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
                    ey = AffExpr()
    
                    for vi in visited, vj in visited
                        if vi > vj && has_edge(g, vi, vj)
                            add_to_expression!(ex, 1, x[vi, vj])
                            add_to_expression!(ey, 1, y[vi, vj])
    
                        end
                    end
                    @constraint(model, ex <= length(visited) - 1)
                    @constraint(intModel, ey <= length(visited) - 1)
    
                    break
                end
    
            end
        end
    end    
    optimize!(intModel)
    
    return  round(objective_value(intModel))
    
end

bounds = [2,3,5]


for b = bounds
    open("database/mbst/optsb$(b)pp.txt", "w") do io


        content = Base.read("database/mbst/trees.txt",String)
        content_float = [parse(Float64,x) for x in split(content)]

        n = Int(content_float[1])
        content_float = content_float[2:end]

        for i = 1:n
            content_float

            size = Int(content_float[1])
            content_float = content_float[2:end]

            g = Graph(size)
            for v = 1:size
                for vi = v + 1:size
                    add_edge!(g, v, vi, content_float[1])
                    content_float = content_float[2:end]
                end
            end
            opt = mbst_opt(g, b)
            write(io, "$(opt)\n")
        end
    end
end