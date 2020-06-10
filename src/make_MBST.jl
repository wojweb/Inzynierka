using MyGraph
using IterativeMethods

bounds = [2, 3, 5]

for b = bounds
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
        println("zaczynam")
        opt = mbst_opt(g, b)
        write(io, "$(opt)\n")
    end
end
