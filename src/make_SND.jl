push!(LOAD_PATH, pwd())
using IterativeMethods
using MyGraph

open("wynikiBig.txt", "w") do io
    content = Base.read("database/snd/networks.txt",String)
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

        r = Array{Int}(undef, size, size)
        for col = 1:size
            for row = 1:size
                r[col, row] = Int(content_float[1])
                content_float = content_float[2:end]
            end
        end


        println("zaczynam")


        f = snd(g, r)

        
        write(io, "$(weight(f))\n")

    end
end