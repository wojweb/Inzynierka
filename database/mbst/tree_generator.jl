push!(LOAD_PATH, pwd())
using MyGraph

sizes = [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20] # rozmiary generowanych grafów 
n = 5 # liczba egzemplarzy o jednakowym rozmiarze

open("database/mbst/trees.txt", "w") do io
    write(io, "$(length(sizes) * n)\n")
    for size = sizes
        for i = 1:n
            write(io, "$(size)\n")
            g = generateConnectedGraph(size)
            for v = 1:size
                for vi = v + 1:size
                    write(io, "$(weight(g, v, vi)) ")
                end
                write(io, "\n")
            end
        end
    end
end


