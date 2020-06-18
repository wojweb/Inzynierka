 push!(LOAD_PATH, pwd())
 import Pkg
 Pkg.add("Plots")
 Pkg.add("GR")
 Pkg.add("Statistics")
 using MyGraph
 using IterativeMethods
using Plots
using GR
using Statistics

bounds = [2, 3, 5]

times_1 = Dict{Int, Vector{Float64}}()
times_2 = Dict{Int, Vector{Float64}}()
PRDs_1 = Dict{Int, Vector{Float64}}()
PRDs_2 = Dict{Int, Vector{Float64}}()

exceeded_vertices_1 = Dict{Int, Vector{Int}}()
exceeded_byone_vertices_2 = Dict{Int, Vector{Int}}()
exceeded_bytwo_vertices_2 = Dict{Int, Vector{Int}}()

# # Rozgrzewkowy
begin
b = 5
content = Base.read("database/mbst/trees.txt",String)
content_float = [parse(Float64,x) for x in split(content)]
size = Int(content_float[1])
content_float = content_float[2:end]

g = Graph(size)

for v = 1:size
    for vi = v + 1:size
        global content_float
        
        add_edge!(g, v, vi, content_float[1])
        content_float = content_float[2:end]
    end
end
t = @elapsed (f, model_sizes_int) = mbst_additive_one(g, Set(vertices(g)), Dict([(v,b) for v in vertices(g)]))
end

mkpath("results")



sizes = [10,11,12,13,14,15,16,17,18,19,20]

for b = bounds
    times_1[b] = Vector{Float64}(undef, 0)
    times_2[b] = Vector{Float64}(undef, 0)
    PRDs_1[b] = Vector{Float64}(undef, 0)
    PRDs_2[b] = Vector{Float64}(undef, 0)

    exceeded_vertices_1[b] = Vector{Int}(undef, 0)
    exceeded_byone_vertices_2[b] = Vector{Int}(undef, 0)
    exceeded_bytwo_vertices_2[b] = Vector{Int}(undef, 0)

    content = Base.read("database/mbst/small_trees.txt",String)
    content_float = [parse(Float64,x) for x in split(content)]
    content = Base.read("database/mbst/small_optsb$(b).txt", String)
    opts = [parse(Float64,x) for x in split(content)]

    io1 = open("results/mbst+1b$(b)_results.txt", "w")
    io2 = open("results/mbst+2b$(b)_results.txt", "w")


    
    n = Int(content_float[1])
    content_float = content_float[2:end]

    for i = 1:n
        size = Int(content_float[1])

        content_float = content_float[2:end]

        g = Graph(size)
        
        for v = 1:size
            for vi = v + 1:size
                add_edge!(g, v, vi, content_float[1])
                content_float = content_float[2:end]
            end
        end
        t = @elapsed (f, model_sizes_int) = mbst_additive_one(g, Set(vertices(g)), Dict([(v,b) for v in vertices(g)]))
        write(io1, "$(weight(f))\n")
        push!(times_1[b], t)
        PRD = 100 * (weight(f) - opts[1]) / opts[1]
        push!(PRDs_1[b], PRD)

        sum_of_exceeded = 0
        for v in vertices(f)
            if length(delta(f, v)) == b + 1
                sum_of_exceeded += 1
            end
            if length(delta(f, v)) > b + 1
                println("Jest blad w programie 1")
            end
        end
        push!(exceeded_vertices_1[b], sum_of_exceeded)

        t = @elapsed (f, model_sizes_int) = mbst_additive_two(g, Set(vertices(g)), Dict([(v,b) for v in vertices(g)]))
        write(io2, "$(weight(f))\n")
        push!(times_2[b], t)
        PRD = 100 * (weight(f) - opts[1]) / opts[1]
        opts = opts[2:end]
        push!(PRDs_2[b], PRD)
        sum_of_exceeded = 0
        for v in vertices(f)
            if length(delta(f, v)) == b + 1
                sum_of_exceeded += 1
            end
        end
        push!(exceeded_byone_vertices_2[b], sum_of_exceeded)
        sum_of_exceeded = 0
        for v in vertices(f)
            if length(delta(f, v)) == b + 2
                sum_of_exceeded += 1
            end
            if length(delta(f, v)) > b + 2
                println("Jest blad w programie 2")
            end
        end
        push!(exceeded_bytwo_vertices_2[b], sum_of_exceeded)

    end

    close(io1)
    close(io2)

end

# Rysowanie wyników



gr()

# Wykres z czasów obliczeń


avgtimes_1 = Dict{Int, Vector{Float64}}()
avgtimes_2 = Dict{Int, Vector{Float64}}()

for b in bounds
    avgtimes_1[b] = Vector{Float64}(undef, 0)
    avgtimes_2[b] = Vector{Float64}(undef, 0)

    for i = 1:length(sizes)
        push!(avgtimes_1[b], Statistics.mean(times_1[b][(i - 1) * 5 + 1:(i * 5)]))
        push!(avgtimes_2[b], Statistics.mean(times_2[b][(i - 1) * 5 + 1:(i * 5)]))
    end
end

times_p = Plots.plot()
for b in bounds
    Plots.plot!(times_p, sizes, avgtimes_1[b], label = "b = $(b), Singh i Lau")

end

for b in bounds
    Plots.plot!(times_p, sizes, avgtimes_2[b], label = "b = $(b), Goemans")
end

Plots.plot!(times_p, legend = :topleft, ylabel = "Czas [s]", xlabel = "Liczba wierzchołków")

Plots.savefig(times_p, "results/mbst_times_plot.png")
# Wykres ARPD 

avgprd_1 = Dict{Int, Vector{Float64}}()
avgprd_2 = Dict{Int, Vector{Float64}}()

for b in bounds
    avgprd_1[b] = Vector{Float64}(undef, 0)
    avgprd_2[b] = Vector{Float64}(undef, 0)

    for i = 1:length(sizes)
        push!(avgprd_1[b], Statistics.mean(PRDs_1[b][(i - 1) * 5 + 1:(i * 5)]))
        push!(avgprd_2[b], Statistics.mean(PRDs_2[b][(i - 1) * 5 + 1:(i * 5)]))
    end
end

aprd_p1 = Plots.plot()
aprd_p2 = Plots.plot()
for b in bounds
    Plots.plot!(aprd_p1, sizes, avgprd_1[b], label = "b  = $(b)", linestyle=:auto)
    Plots.plot!(aprd_p2, sizes, avgprd_2[b], label = "b = $(b)", linestyle=:auto)
end


Plots.plot!(aprd_p1, legend = :topleft, xlabel = "Liczba wierzchołków w grafie", ylabel = "ARPD [%]", ylims=(-10, 0))
Plots.plot!(aprd_p2, legend = :topleft, xlabel = "Liczba wierzchołków w grafie", ylabel = "ARPD [%]", ylims=(-10, 0))
Plots.savefig(aprd_p1, "results/mbst+1_aprd_plot.png")
Plots.savefig(aprd_p2, "results/mbst+2_aprd_plot.png")

#wykresy % przekroczonych

open("results/mbst+1b2_exceeded", "w") do io
    for size in sizes
        write(io, " $(size) &")
    end
    write(io, "\\\\\n")
    for i = 1:5
        for j = 0:10
            write(io, " $(exceeded_vertices_1[2][5 * j + i]) &")
        end
        write(io, "\\\\\n")
    end
end
open("results/mbst+2b2_exceeded", "w") do io
    for size in sizes
        write(io, " $(size) &")
    end
    write(io, "\\\\\n")
    for i = 1:5
        for j = 0:10
            write(io, " $(exceeded_byone_vertices_2[2][5 * j + i]) &")
        end
        write(io, "\\\\\n")
    end
end
