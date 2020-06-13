using MyGraph
using Plots
function find_min(g::Graph)
    min = floatmax()
    for vx in vertices(g), vy in vertices(g)
        if vx > vy
            gprim = Graph(nv(g) + 2, true) # source = nv, sink = nv + 1
            source = nv(g) + 1
            sink = nv(g) + 2
            for vi in vertices(g), vj in vertices(g)
                if vi > vj && has_edge(g, vi, vj)
                    add_edge!(gprim, vi, vj,weight(g, vi, vj))
                    add_edge!(gprim, vj, vi,weight(g, vi, vj))
                end
            end

            for vi in vertices(g)
        
                add_edge!(gprim, source, vi, 1.)
                add_edge!(gprim, vi, sink, 1.)
            end
            add_edge!(gprim, source, vx, typemax(Float64))
            add_edge!(gprim, source, vy, typemax(Float64))

            flow, visited = fordfulkerson(gprim, source, sink)
            break
            if flow < min
                min = flow
            end
        end
    end
end

range = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
times = Vector{Float64}(undef, 0)
for i in range
    g = generateConnectedGraph(i)
    t = @elapsed find_min(g)
    println("$(i) - $(t)")

    push!(times, t)
end

p = plot(range, times)