
using Test

@testset "max_flow" begin

    g = Graph(6, true)

    add_edge!(g, 1, 2, 16)
    add_edge!(g, 1, 3, 13)
    add_edge!(g, 2, 4, 12)
    add_edge!(g, 3, 2, 4)
    add_edge!(g, 3, 5, 14)
    add_edge!(g, 4, 3, 9)
    add_edge!(g, 4, 6, 20)
    add_edge!(g, 5, 4, 7)
    add_edge!(g, 5, 6, 4)

    flow, visited = fordfulkerson(g, 1, 6)

    @test flow == 23.
    @test 1 in visited
    @test 2 in visited
    @test 3 in visited
    @test !(4 in visited)
    @test 5 in visited
    @test !(6 in visited)

end
