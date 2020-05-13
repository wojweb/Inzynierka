using Test
using MyGraph
using IterativeMethods

@testset "generalizedAssignment" begin
    g = Graph(10)

    add_edge!(g, 1, 8, 5)
    add_edge!(g, 1, 9, 1)
    add_edge!(g, 2, 10, 2)
    add_edge!(g, 2, 8, 8)
    add_edge!(g, 3, 9, 3)
    add_edge!(g, 3, 10, 1)
    add_edge!(g, 4, 8, 6)
    add_edge!(g, 4, 9, 5)
    add_edge!(g, 5, 10, 8)
    add_edge!(g, 5, 8, 8)
    add_edge!(g, 6, 10, 8)
    add_edge!(g, 7, 10, 8)


    processing_times = Array{Float64, 2}(undef, 7, 3)
    fill!(processing_times, 1.)
    machines_times = Array{Float64}(undef, 3)
    fill!(machines_times, 3.)

    f = generalized_assignment(g, 7, processing_times, machines_times)


    @test ne(f) == 7 # liczba zadan


end
