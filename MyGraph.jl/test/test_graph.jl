using Test
using MyGraph1


@testset "graph" begin
    g = Graph(6)

    add_edge!(g, 1, 2, 1)
    add_edge!(g, 1, 4, 2)
    add_edge!(g, 2, 4, 3)
    add_edge!(g, 4, 5, 2)
    add_edge!(g, 5, 3, 1)
    add_edge!(g, 5, 6, 4)
    add_edge!(g, 3, 6, 2)


    @test nv(g) == 6
    @test ne(g) == 7
    @test has_edge(g, 4, 5)
    @test weight(g) == 15
    @test weight(g, 5, 6) == 4
    @test is_connected(g)
    @test degree(g, 2) == 2

    rem_edge!(g, 4, 5)
    @test !is_connected(g)
    @test weight(g) == 13

    rem_vertex!(g, 2)
    @test weight(g) == 9

end
