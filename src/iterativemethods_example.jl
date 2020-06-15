push!(LOAD_PATH, pwd())
using MyGraph
using IterativeMethods

g = Graph(9)
add_edge!(g, 1, 2, 6.0)
add_edge!(g, 1, 3, 7.0)
add_edge!(g, 1, 4, 2.0)
add_edge!(g, 2, 3, 4.0)
add_edge!(g, 2, 6, 7.0)
add_edge!(g, 2, 5, 5.0)
add_edge!(g, 3, 4, 7.0)
add_edge!(g, 3, 5, 10.0)
add_edge!(g, 4, 8, 7.0)
add_edge!(g, 5, 6, 9.0)
add_edge!(g, 5, 7, 8.0)
add_edge!(g, 5, 8, 8.0)
add_edge!(g, 6, 7, 8.0)
add_edge!(g, 6, 9, 1.0)
add_edge!(g, 7, 8, 3.0)
add_edge!(g, 7, 9, 2.0)
add_edge!(g, 8, 9, 9.0)

save(g, "graf2")

r = Int.(zeros(9, 9))
r[1,9] = 2
(f, sizes) = snd(g, r)

