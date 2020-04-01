using Test


@testset "digraph" begin
    g = Graph(6, true)

    add_edge!(g, 1, 2, 1)
    add_edge!(g, 1, 4, 2)
    add_edge!(g, 2, 4, 3)
    add_edge!(g, 4, 5, 2)
    add_edge!(g, 5, 3, 1)
    add_edge!(g, 5, 4, 1)
    add_edge!(g, 5, 6, 4)
    add_edge!(g, 3, 6, 2)


    @test nv(g) == 6
    @test ne(g) == 8
    @test has_edge(g, 4, 5)
    @test !has_edge(g, 2, 1)
    @test weight(g) == 16
    @test weight(g, 5, 6) == 4
    @test sort(delta_in(g, 4)) == [1, 2, 5]
    @test sort(delta_out(g, 5)) == [3, 4, 6]
    # @test is_connected(g)
    # @test degree(g, 2) == 2

    min_edge_contraction!(g, 4, 5)

    @test weight(g) == 13
    @test has_edge(g, 2, 4)
    @test has_edge(g, 4, 6)
    @test !has_edge(g, 4, 5)
    @test has_edge(g, 4, 3)
    @test get_origin(g, 4, 3) == (5, 3)

    println(g)



end
