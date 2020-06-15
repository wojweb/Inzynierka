push!(LOAD_PATH, pwd())
using MyGraph

g = Graph(6)
add_edge!(g, 1, 2, 9.0)
add_edge!(g, 1, 3, 7.0)
add_edge!(g, 2, 4, 4.0)
add_edge!(g, 2, 3, 8.0)
add_edge!(g, 3, 4, 4.0)
add_edge!(g, 3, 5, 5.0)
add_edge!(g, 4, 5, 1.0)
add_edge!(g, 4, 6, 6.0)
add_edge!(g, 5, 6, 10.0)

println("Suma wag krawędzi grafu g wynosi:")
w = weight(g)
println(w)

println("Maksymalny przepływ pomiędzy 1, a 6 wynosi:")
(flow, s_part) = fordfulkerson(g, 1, 6)
println(flow)

println("Wierzchołki stopnia 4 to:")
for v in vertices(g)
    if degree(g, v) == 4
        println(v)
    end
end