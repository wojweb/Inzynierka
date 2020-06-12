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

times_1 = Vector{Float64}(undef, 0)
times_2 = Vector{Float64}(undef, 0)
PRDs_1 = Vector{Float64}(undef, 0)
PRDs_2 = Vector{Float64}(undef, 0)
model_size_per_iterations_1 = Vector{Vector{Float64}}(undef, 0)
model_size_per_iterations_2 = Vector{Vector{Float64}}(undef, 0)
exceeded_vertices_fraction_1 = Vector{Float64}(undef, 0)
exceeded_byone_vertices_fraction_2 = Vector{Float64}(undef, 0)
exceeded_bytwo_vertices_fraction_2 = Vector{Float64}(undef, 0)

# Rozgrzewkowy
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

println("Rozgrzany")

for b = bounds
    content = Base.read("database/mbst/trees.txt",String)
    content_float = [parse(Float64,x) for x in split(content)]
    opts = Base.read("database/mbst/optsb$(b).txt")
    
    n = Int(content_float[1])
    content_float = content_float[2:end]

    for i = 1:n
        println(i)
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
        push!(times_1, t)
        PRD = 100 * (weight(f) - opts[1]) / opts[1]
        push!(PRDs_1, PRD)
        push!(model_size_per_iterations_1, [Float64(model_size) / Float64(model_sizes_int[1]) for model_size in model_sizes_int])
        sum_of_exceeded = 0
        for v in vertices(f)
            if length(delta(f, v)) == b + 1
                sum_of_exceeded += 1
            end
            if length(delta(f, v)) > b + 1
                println("Jest blad w programie 1")
            end
        end
        push!(exceeded_vertices_fraction_1, Float64(sum_of_exceeded) / Float64(nv(f)))

        t = @elapsed (f, model_sizes_int) = mbst_additive_two(g, Set(vertices(g)), Dict([(v,b) for v in vertices(g)]))
        push!(times_2, t)
        PRD = 100 * (weight(f) - opts[1]) / opts[1]
        opts = opts[2:end]
        push!(PRDs_2, PRD)
        push!(model_size_per_iterations_2, [Float64(model_size) / Float64(model_sizes_int[1]) for model_size in model_sizes_int])
        sum_of_exceeded = 0
        for v in vertices(f)
            if length(delta(f, v)) == b + 1
                sum_of_exceeded += 1
            end
        end
        push!(exceeded_byone_vertices_fraction_2, Float64(sum_of_exceeded) / Float64(nv(f)))
        sum_of_exceeded = 0
        for v in vertices(f)
            if length(delta(f, v)) == b + 2
                sum_of_exceeded += 1
            end
            if length(delta(f, v)) > b + 2
                println("Jest blad w programie 2")
            end
        end
        push!(exceeded_bytwo_vertices_fraction_2, Float64(sum_of_exceeded) / Float64(nv(g)))

    end
end

# Rysowanie wyników

mkpath("results")


gr()

# Wykres z czasów obliczeń

timesb2 = times_1[1:20]
timesb3 = times_1[21:40]
timesb5 = times_1[41:60]

avgtimesb2 = Vector{Float64}(undef, 0)
avgtimesb3 = Vector{Float64}(undef, 0)
avgtimesb5 = Vector{Float64}(undef, 0)

for i = 1:4
    push!(avgtimesb2, Statistics.mean(timesb2[(i - 1) * 5 + 1:(i * 5)]))
    push!(avgtimesb3, Statistics.mean(timesb3[(i - 1) * 5 + 1:(i * 5)]))
    push!(avgtimesb5, Statistics.mean(timesb5[(i - 1) * 5 + 1:(i * 5)]))
end


times_p = Plots.plot([30, 40, 50, 60], avgtimesb2, label = "ograniczenie 2")
Plots.plot!(times_p, [30, 40, 50, 60], avgtimesb3, label = "ograniczenie 3")
Plots.plot!(times_p, [30, 40, 50, 60], avgtimesb5, label = "ograniczenie 5", xlabel = "Czas", ylabel = "czas [s]")

Plots.savefig(times_p, "results/mbst1_times_plot.png")

timesb2 = times_1[1:20]
timesb3 = times_1[21:40]
timesb5 = times_1[41:60]

avgtimesb2 = Vector{Float64}(undef, 0)
avgtimesb3 = Vector{Float64}(undef, 0)
avgtimesb5 = Vector{Float64}(undef, 0)

for i = 1:4
    push!(avgtimesb2, Statistics.mean(timesb2[(i - 1) * 5 + 1:(i * 5)]))
    push!(avgtimesb3, Statistics.mean(timesb3[(i - 1) * 5 + 1:(i * 5)]))
    push!(avgtimesb5, Statistics.mean(timesb5[(i - 1) * 5 + 1:(i * 5)]))
end


times_p = Plots.plot([30, 40, 50, 60], avgtimesb2, label = "ograniczenie 2")
Plots.plot!(times_p, [30, 40, 50, 60], avgtimesb3, label = "ograniczenie 3")
Plots.plot!(times_p, [30, 40, 50, 60], avgtimesb5, label = "ograniczenie 5", xlabel = "Czas", ylabel = "czas [s]")

Plots.savefig(times_p, "results/mbst2_times_plot.png")


# # Wykres ARPD 

# PRDs5 = PRDs[1:20]
# PRDs8 = PRDs[21:40]
# PRDs10 = PRDs[41:60]

# APRD5 = Vector{Float64}(undef, 0)
# APRD8 = Vector{Float64}(undef, 0)
# APRD10 = Vector{Float64}(undef, 0)

# for i = 1:4
#     push!(APRD5, Statistics.mean(PRDs5[(i - 1) * 5 + 1:(i * 5)]))
#     push!(APRD8, Statistics.mean(PRDs8[(i - 1) * 5 + 1:(i * 5)]))
#     push!(APRD10, Statistics.mean(PRDs10[(i - 1) * 5 + 1:(i * 5)]))
# end


# p = Plots.plot([1:4], APRD5, label = "5 maszyn")
# Plots.plot!(p, [1:4], APRD8, label = "8 maszyn")
# Plots.plot!(p, [1:4], APRD10, label = "10 maszyn", xlabel = "Stosunek ilości zadań do maszyn r", ylabel = "ARPD [%]")


# Plots.savefig(p, "results/aprd_plot.png")

# # Wykres sredniego czasu przekroczenia maszyn 
# # oraz wykres procentu egzemplarzy na poszczególne iteracje


# # Wyróżniamy konfiguracje m5j15, m10j30, m10j60

# mspi515 = model_size_per_iterations[1:5]
# mspi1030 = model_size_per_iterations[41:45]
# mspi1060 = model_size_per_iterations[56:60]


# Amspi515 = Vector{Float64}(undef, 0)
# Amspi1030 = Vector{Float64}(undef, 0)
# Amspi1060 = Vector{Float64}(undef, 0)
# aipi515 = Vector{Float64}(undef, 0)
# aipi1030 = Vector{Float64}(undef, 0)
# aipi1060 = Vector{Float64}(undef, 0)


# for j = 1:maximum([length(mspi515[i]) for i = 1:5])
#     sum = 0.
#     amount = 0.
#     for i = 1:5
#         if length(mspi515[i]) >= j
#             sum += mspi515[i][j] / mspi515[i][1]
#             amount += 1
#         end
#     end
#     push!(Amspi515, 100 * sum / 5)
#     push!(aipi515, 100 * amount / 5)
# end

# for j = 1:maximum([length(mspi1030[i]) for i = 1:5])
#     sum = 0.
#     amount = 0.
#     for i = 1:5
#         if length(mspi1030[i]) >= j
#             sum += mspi1030[i][j] / mspi1030[i][1]
#             amount += 1
#         end
#     end
#     push!(Amspi1030, 100 * sum / 5)
#     push!(aipi1030, 100 * amount / 5)
# end

# for j = 1:maximum([length(mspi1060[i]) for i = 1:5])
#     sum = 0.
#     amount = 0.
#     for i = 1:5
#         if length(mspi1060[i]) >= j
#             sum += mspi1060[i][j] / mspi1060[i][1]
#             amount += 1
#         end
#     end
#     push!(Amspi1060, 100 * sum / 5)
#     push!(aipi1060, 100 * amount / 5)
# end

# while length(Amspi515) != max(length(Amspi515), length(Amspi1030), length(Amspi1060))
#     push!(Amspi515, 0.)
#     push!(aipi515, 0.)
# end

# while length(Amspi1030) != max(length(Amspi515), length(Amspi1030), length(Amspi1060))
#     push!(Amspi1030, 0.)
#     push!(aipi1030, 0.)
# end

# while length(Amspi1060) != max(length(Amspi515), length(Amspi1030), length(Amspi1060))
#     push!(Amspi1060, 0.)
#     push!(aipi1060, 0)
# end

# p = Plots.plot([1:length(Amspi515)], Amspi515, label = "5 maszyn, 15 zadań")
# Plots.plot!(p, [1:length(Amspi515)], Amspi1030, label = "10 maszyn, 30zadań")
# Plots.plot!(p, [1:length(Amspi515)], Amspi1060, label = "10 maszyn, 60 zadań", xlabel = "Liczba iteracji", ylabel = "Wielkość modelu LP [%]")

# Plots.savefig(p, "results/amspi.png")

# p = Plots.plot([1:length(aipi515)], aipi515, label = "5 maszyn, 15 zadań")
# Plots.plot!(p, [1:length(aipi515)], aipi1030, label = "10 maszyn, 30zadań")
# Plots.plot!(p, [1:length(aipi515)], aipi1060, label = "10 maszyn, 60 zadań", xlabel = "Liczba iteracji", ylabel = "Ilość egzemplarzy [%]", legend = :bottomleft)

# Plots.savefig(p, "results/aipi.png")
