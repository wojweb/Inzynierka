push!(LOAD_PATH, pwd())
using MyGraph
using JuMP
using CPLEX

function snd_opt(h::Graph, r::Array{Int, 2})::Float64
    g = deepcopy(h)
    model = Model(CPLEX.Optimizer)
    intModel = Model(CPLEX.Optimizer)
    
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
    
    counter = 1
    
    while !is_feasible
        optimize!(model)


        println("$(counter): $(objective_value(model))")
        counter += 1

        if termination_status(model) != MOI.OPTIMAL
            error(("Nie znalezniono optymalnego rozwiązania", termination_status(model), model))
        end
        is_feasible = true
        for vx in vertices(g), vy in vertices(g)
            if vx != vy
                gprim = Graph(nv(h), true) # source = nv, sink = nv + 1
                source = vx
                sink = vy
                for vi in vertices(g), vj in vertices(g)
                    if vi > vj && has_edge(g, vi, vj)
                        add_edge!(gprim, vi, vj,  round(JuMP.value(x[vi, vj]), digits=8))
                        add_edge!(gprim, vj, vi,  round(JuMP.value(x[vi, vj]), digits=8))
                    end
                end
    
                flow, visited = fordfulkerson(gprim, source, sink)
                if round(flow, digits = 4) < r[source, sink]
                    is_feasible = false
                    ex = AffExpr()
                    ey = AffExpr()

                    
                    r_max = 0
                    for vi in visited, vj in [v for v in vertices(g) if !in(v, visited)]
                        if vi > vj && has_edge(g, vi, vj)
                            add_to_expression!(ex, 1, x[vi, vj])
                            add_to_expression!(ey, 1, y[vi, vj])
                        end
                        if vj > vi && has_edge(g, vi, vj)
                            add_to_expression!(ex, 1, x[vj, vi])
                            add_to_expression!(ey, 1, y[vj, vi])
                        end

                        if r[vi, vj] >= r_max
                            r_max = r[vi, vj]
                        end
                    end

                    @constraint(model, ex >= r_max)
                    @constraint(intModel, ey >= r_max)
                    break
                end
            end
        end
    end    
    optimize!(intModel)
    
    return  objective_value(intModel)
    
end


open("database/snd/opts.txt", "w") do io
    content = Base.read("database/snd/networks.txt",String)
    content_float = [parse(Float64,x) for x in split(content)]

    n = Int(content_float[1])
    content_float = content_float[2:end]
    for i = 1:n
        
        size = Int(content_float[1])
        content_float = content_float[2:end]

        g = Graph(size)
        for v = 1:size
            for vi = v + 1:size
                add_edge!(g, v, vi, content_float[1])
                content_float = content_float[2:end]
            end
        end

        r = Array{Int}(undef, size, size)
        for col = 1:size
            for row = 1:size
                r[col, row] = Int(content_float[1])
                content_float = content_float[2:end]
            end
        end


        println("zaczynam")

        opt = snd_opt(g, r)
        
        write(io, "$(opt)\n")
        flush(io)
        println(opt)
        # println(r)
    end
end