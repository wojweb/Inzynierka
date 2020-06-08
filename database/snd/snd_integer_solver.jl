using MyGraph
using JuMP
using GLPK

function snd_opt(h::Graph, r::Array{Float64, 2})::Int
    g = deepcopy(h)
    model = Model(GLPK.Optimizer)
    intModel = Model(GLPK.Optimizer)
    
    subsets = Vector{Vector{Int}}(undef, 0)
    is_feasible = false
    @variable(model, 0 <= x[vi in vertices(g), vj in vertices(g);
        vi > vj && has_edge(g, vi, vj)] <= 1)
    
    @variable(intModel, 0 <= y[vi in vertices(g), vj in vertices(g);
        vi > vj && has_edge(g, vi, vj)] <= 1, Bin)
    
    
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
    
    while !is_feasible
        optimize!(model)
        if termination_status(model) != MOI.OPTIMAL
            error(("Nie znalezniono optymalnego rozwiązania", termination_status(model), model))
        end
        is_feasible = true
    
        for vx in vertices(g), vy in vertices(g)

                gprim = Graph(nv(h), true) # source = nv, sink = nv + 1
                source = vx
                sink = vy
                for vi in vertices(g), vj in vertices(g)
                    if vi > vj && has_edge(g, vi, vj)
                        add_edge!(gprim, vi, vj,  round(value(x[vi, vj]), digits=8))
                        add_edge!(gprim, vj, vi,  round(value(x[vi, vj]), digits=8))
                    end
                end
    
    
                flow, visited = fordfulkerson(gprim, source, sink)
                if round(flow, digits = 4) < r[source, sink]
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
                    @constraint(model, ex >= r[source, sink])
                    @constraint(intModel, ey >= r[source, sink])
                    break
                end
            end
    end    
    optimize!(intModel)
    
    return  round(objective_value(intModel))
    
end


open("database/snd/opt.txt", "w") do io
    content = Base.read("database/snd/networks.txt",String)
    content_float = [parse(Float64,x) for x in split(content)]

    n = Int(content_float[1])
    content_float = content_float[2:end]
    for i = 1:1
        size = Int(content_float[1])
        content_float = content_float[2:end]

        g = Graph(size)
        for v = 1:size
            for vi = v + 1:size
                add_edge!(g, v, vi, content_float[1])
                content_float = content_float[2:end]
            end
        end

        r = Array{Float64}(undef, size, size)

        for col = 1:size
            for row = 1:size
                r[col, row] = content_float[1]
                content_float = content_float[2:end]
            end
        end

        println("zaczynam")
        opt = snd_opt(g, r)
        write(io, "$(opt)\n")

        println(r)
    end
end