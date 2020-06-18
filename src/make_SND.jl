push!(LOAD_PATH, pwd())
using IterativeMethods
using MyGraph
import Pkg
Pkg.add("Plots")
Pkg.add("GR")
Pkg.add("Statistics")
using Statistics
using Plots
using GR


sizes = [10,11,12,13,14,15,16,17,18,19,20]

# Partia rozgrzewkowa
begin
content = Base.read("database/snd/networks.txt",String)
content_float = [parse(Float64,x) for x in split(content)]
content = Base.read("database/snd/opts.txt",String)
opts = [parse(Float64,x) for x in split(content)]

n = Int(content_float[1])
content_float = content_float[2:end]
for i = 1:1
        global content_float
        global opts
        
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
        t = @elapsed (f, sizes_per_iteration) = snd(g, r)
   
end
end


times = Vector{Float64}(undef, 0)
PRDs = Vector{Float64}(undef, 0)
model_size_per_iterations = Vector{Vector{Float64}}(undef, 0)


content = Base.read("database/snd/networks.txt",String)
content_float = [parse(Float64,x) for x in split(content)]
content = Base.read("database/snd/opts.txt",String)
opts = [parse(Float64,x) for x in split(content)]
n = Int(content_float[1])
content_float = content_float[2:end]

mkpath("results")
open("results/snd_results.txt", "w") do io
for i = 1:n
        global content_float
        global opts
        
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
        t = @elapsed (f, sizes_per_iteration) = snd(g, r)
        write(io, "$(weight(f))\n")
        push!(times, t)
        PRD = 100 * (weight(f) - opts[1]) / opts[1]
        opts = opts[2:end]
        push!(PRDs, PRD)
        push!(model_size_per_iterations, [Float64(s) / Float64(sizes_per_iteration[1]) for s in sizes_per_iteration])   
end
end

# Rysowanie wyników

mkpath("results")
gr()

avgtimes = Vector{Float64}(undef, 0)

for i = 1:length(sizes)
        push!(avgtimes, Statistics.mean(times[(i - 1) * 5 + 1:(i * 5)]))
end

times_p = Plots.plot(sizes, avgtimes, ylabel = "Czas [s]", xlabel = "Liczba wierzchołków", legend = false)
Plots.savefig(times_p, "results/snd_times_plot.png")

avgprds = Vector{Float64}(undef, 0)
for i = 1:length(sizes)
    push!(avgprds, Statistics.mean(PRDs[(i - 1) * 5 + 1:(i * 5)]))
end

PRDs_p = Plots.plot(sizes, avgprds, ylabel = "ARPD [%]", xlabel = "Liczba wierzchołków", legend = false)
Plots.savefig(PRDs_p, "results/snd_aprd_plot.png")

sizes_per_i_p = Plots.plot(xlabel = "Liczba iteracji", ylabel = "Rozmiar modelu LP [%]")
for sizes_per_i in model_size_per_iterations
    while length(sizes_per_i) < 3
        push!(sizes_per_i, 0)
    end
    Plots.plot!([1,2,3], sizes_per_i, legend = false)
end

Plots.savefig(sizes_per_i_p, "results/snd_sizes.png")


