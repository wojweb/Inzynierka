using MyGraph
using IterativeMethods
using Plots
using GR
using Statistics


# Najpierw dokonaliśmy obliczeń na pierwszych 5 egzemplarzach problemu
# bez zapisywania wyników, aby rozpędzić procesory.
# Wlasciwy eksperyment zaczyna sie nizej

for i = 1:1
    content = Base.read("database/gap/gap$(i).txt",String)
    content_int = [parse(Int,x) for x in split(content)]

    numberOfProblems = content_int[1]
    content_int = content_int[2:end]

    for n = 1:numberOfProblems
        numberOfMachines = content_int[1]
        numberOfJobs = content_int[2]
        content_int = content_int[3:end]

        g = Graph(numberOfMachines + numberOfJobs)

        for i = 1:numberOfMachines
            for j = 1:numberOfJobs
                add_edge!(g, i + numberOfJobs, j, content_int[j])
            end
            content_int = content_int[numberOfJobs + 1:end]
        end

        processing_times = Array{Float64, 2}(undef, numberOfJobs, numberOfMachines)
        for i = 1:numberOfMachines
            for j = 1:numberOfJobs
                processing_times[j,i] = Float64(content_int[j])
            end
            content_int = content_int[numberOfJobs + 1:end]
        end

        machienes_times = Array{Float64}(undef, numberOfMachines)
        for i = 1:numberOfMachines
            machienes_times[i] = content_int[i]
        end
        content_int = content_int[numberOfMachines + 1:end]

 

        t = @elapsed (f, number_of_edges_info) = generalized_assignment(g, numberOfJobs, processing_times, machienes_times)

    end
end


# Wlasciwe wykonywanie eksperymentów

times = Vector{Float64}(undef, 0)
PRDs = Vector{Float64}(undef, 0)
overflows = Vector{Float64}(undef, 0)
exceeded_machines_fractions = Vector{Float64}(undef, 0)
model_size_per_iterations = Vector{Vector{Float64}}(undef, 0)

content_opts = Base.read("database/gap/opts.txt", String)
opts = [parse(Int, x) for x in split(content_opts)]

for i = 1:12

    content = Base.read("database/gap/gap$(i).txt",String)
    content_int = [parse(Int,x) for x in split(content)]

    numberOfProblems = content_int[1]
    content_int = content_int[2:end]

    for n = 1:numberOfProblems
        numberOfMachines = content_int[1]
        numberOfJobs = content_int[2]
        content_int = content_int[3:end]

        g = Graph(numberOfMachines + numberOfJobs)

        for i = 1:numberOfMachines
            for j = 1:numberOfJobs
                add_edge!(g, i + numberOfJobs, j, content_int[j])
            end
            content_int = content_int[numberOfJobs + 1:end]
        end

        processing_times = Array{Float64, 2}(undef, numberOfJobs, numberOfMachines)
        for i = 1:numberOfMachines
            for j = 1:numberOfJobs
                processing_times[j,i] = Float64(content_int[j])
            end
            content_int = content_int[numberOfJobs + 1:end]
        end

        machienes_times = Array{Float64}(undef, numberOfMachines)
        for i = 1:numberOfMachines
            machienes_times[i] = content_int[i]
        end
        content_int = content_int[numberOfMachines + 1:end]

 

        t = @elapsed (f, number_of_edges_info) = generalized_assignment(g, numberOfJobs, processing_times, machienes_times)


        global opts
        PRD = 100 * (weight(f) - opts[1]) / opts[1]
        opts = opts[2:end]

        push!(times, t)
        push!(PRDs, PRD)

        numberOfExceededMachines = 0
        avgOverflow = 0
        for i = 1:numberOfMachines
            assignment_time = 0
            for j in delta(f, i + numberOfJobs)
                assignment_time += processing_times[j,i]
            end
            if assignment_time > machienes_times[i]
                numberOfExceededMachines += 1
                avgOverflow += 100 *(assignment_time / machienes_times[i] - 1)
            end
        end
        avgOverflow /= numberOfExceededMachines

        push!(overflows, avgOverflow)
        push!(exceeded_machines_fractions, 100 * numberOfExceededMachines / numberOfMachines)
        push!(model_size_per_iterations, number_of_edges_info)
    end
end

# Rysowanie wyników

mkpath("results")


gr()

# Wykres z czasów obliczeń

times5 = times[1:20]
times8 = times[21:40]
times10 = times[41:60]

avgtimes5 = Vector{Float64}(undef, 0)
avgtimes8 = Vector{Float64}(undef, 0)
avgtimes10 = Vector{Float64}(undef, 0)

for i = 1:4
    push!(avgtimes5, Statistics.mean(times5[(i - 1) * 5 + 1:(i * 5)]))
    push!(avgtimes8, Statistics.mean(times8[(i - 1) * 5 + 1:(i * 5)]))
    push!(avgtimes10, Statistics.mean(times10[(i - 1) * 5 + 1:(i * 5)]))
end


times_p = Plots.plot([1:4], avgtimes5, label = "5 maszyn")
Plots.plot!(times_p, [1:4], avgtimes8, label = "8 maszyn")
Plots.plot!(times_p, [1:4], avgtimes10, label = "10 maszyn", xlabel = "Stosunek ilości zadań do maszyn r", ylabel = "czas [s]")


Plots.savefig(times_p, "results/times_plot.png")


# Wykres ARPD 

PRDs5 = PRDs[1:20]
PRDs8 = PRDs[21:40]
PRDs10 = PRDs[41:60]

APRD5 = Vector{Float64}(undef, 0)
APRD8 = Vector{Float64}(undef, 0)
APRD10 = Vector{Float64}(undef, 0)

for i = 1:4
    push!(APRD5, Statistics.mean(PRDs5[(i - 1) * 5 + 1:(i * 5)]))
    push!(APRD8, Statistics.mean(PRDs8[(i - 1) * 5 + 1:(i * 5)]))
    push!(APRD10, Statistics.mean(PRDs10[(i - 1) * 5 + 1:(i * 5)]))
end


p = Plots.plot([1:4], APRD5, label = "5 maszyn")
Plots.plot!(p, [1:4], APRD8, label = "8 maszyn")
Plots.plot!(p, [1:4], APRD10, label = "10 maszyn", xlabel = "Stosunek ilości zadań do maszyn r", ylabel = "ARPD [%]")


Plots.savefig(p, "results/aprd_plot.png")

# Wykres sredniego czasu przekroczenia maszyn 
# oraz wykres procentu egzemplarzy na poszczególne iteracje


# Wyróżniamy konfiguracje m5j15, m10j30, m10j60

mspi515 = model_size_per_iterations[1:5]
mspi1030 = model_size_per_iterations[41:45]
mspi1060 = model_size_per_iterations[56:60]


Amspi515 = Vector{Float64}(undef, 0)
Amspi1030 = Vector{Float64}(undef, 0)
Amspi1060 = Vector{Float64}(undef, 0)
aipi515 = Vector{Float64}(undef, 0)
aipi1030 = Vector{Float64}(undef, 0)
aipi1060 = Vector{Float64}(undef, 0)


for j = 1:maximum([length(mspi515[i]) for i = 1:5])
    sum = 0.
    amount = 0.
    for i = 1:5
        if length(mspi515[i]) >= j
            sum += mspi515[i][j] / mspi515[i][1]
            amount += 1
        end
    end
    push!(Amspi515, 100 * sum / 5)
    push!(aipi515, 100 * amount / 5)
end

for j = 1:maximum([length(mspi1030[i]) for i = 1:5])
    sum = 0.
    amount = 0.
    for i = 1:5
        if length(mspi1030[i]) >= j
            sum += mspi1030[i][j] / mspi1030[i][1]
            amount += 1
        end
    end
    push!(Amspi1030, 100 * sum / 5)
    push!(aipi1030, 100 * amount / 5)
end

for j = 1:maximum([length(mspi1060[i]) for i = 1:5])
    sum = 0.
    amount = 0.
    for i = 1:5
        if length(mspi1060[i]) >= j
            sum += mspi1060[i][j] / mspi1060[i][1]
            amount += 1
        end
    end
    push!(Amspi1060, 100 * sum / 5)
    push!(aipi1060, 100 * amount / 5)
end

while length(Amspi515) != max(length(Amspi515), length(Amspi1030), length(Amspi1060))
    push!(Amspi515, 0.)
    push!(aipi515, 0.)
end

while length(Amspi1030) != max(length(Amspi515), length(Amspi1030), length(Amspi1060))
    push!(Amspi1030, 0.)
    push!(aipi1030, 0.)
end

while length(Amspi1060) != max(length(Amspi515), length(Amspi1030), length(Amspi1060))
    push!(Amspi1060, 0.)
    push!(aipi1060, 0)
end

p = Plots.plot([1:length(Amspi515)], Amspi515, label = "5 maszyn, 15 zadań")
Plots.plot!(p, [1:length(Amspi515)], Amspi1030, label = "10 maszyn, 30zadań")
Plots.plot!(p, [1:length(Amspi515)], Amspi1060, label = "10 maszyn, 60 zadań", xlabel = "Liczba iteracji", ylabel = "Wielkość modelu LP [%]")

Plots.savefig(p, "results/amspi.png")

p = Plots.plot([1:length(aipi515)], aipi515, label = "5 maszyn, 15 zadań")
Plots.plot!(p, [1:length(aipi515)], aipi1030, label = "10 maszyn, 30zadań")
Plots.plot!(p, [1:length(aipi515)], aipi1060, label = "10 maszyn, 60 zadań", xlabel = "Liczba iteracji", ylabel = "Ilość egzemplarzy [%]", legend = :bottomleft)

Plots.savefig(p, "results/aipi.png")




# EMFs5 = exceeded_machines_fractions[1:20]
# EMFs8 = exceeded_machines_fractions[21:40]
# EMFs10 = exceeded_machines_fractions[41:60]

# AEMF5 = Vector{Float64}(undef, 0)
# AEMF8 = Vector{Float64}(undef, 0)
# AEMF10 = Vector{Float64}(undef, 0)

# for i = 1:4
#     push!(AEMF5, Statistics.mean(EMFs5[(i - 1) * 5 + 1:(i * 5)]))
#     push!(AEMF8, Statistics.mean(EMFs8[(i - 1) * 5 + 1:(i * 5)]))
#     push!(AEMF10, Statistics.mean(EMFs10[(i - 1) * 5 + 1:(i * 5)]))
# end


# p = Plots.plot([1:4], AEMF5, label = "5 maszyn")
# Plots.plot!(p, [1:4], AEMF8, label = "8 maszyn")
# Plots.plot!(p, [1:4], AEMF10, label = "10 maszyn", xlabel = "Stosunek ilości zadań do maszyn r", ylabel = "Procent maszyn o przekroczonym dostępie [%]")


# Plots.savefig(p, "results/exceeded_machines_plot.png")

# # Wykres średniej ilości przekroczonych maszyn 

# EMFs5 = exceeded_machines_fractions[1:20]
# EMFs8 = exceeded_machines_fractions[21:40]
# EMFs10 = exceeded_machines_fractions[41:60]

# AEMF5 = Vector{Float64}(undef, 0)
# AEMF8 = Vector{Float64}(undef, 0)
# AEMF10 = Vector{Float64}(undef, 0)

# for i = 1:4
#     push!(AEMF5, Statistics.mean(EMFs5[(i - 1) * 5 + 1:(i * 5)]))
#     push!(AEMF8, Statistics.mean(EMFs8[(i - 1) * 5 + 1:(i * 5)]))
#     push!(AEMF10, Statistics.mean(EMFs10[(i - 1) * 5 + 1:(i * 5)]))
# end


# p = Plots.plot([1:4], AEMF5, label = "5 maszyn")
# Plots.plot!(p, [1:4], AEMF8, label = "8 maszyn")
# Plots.plot!(p, [1:4], AEMF10, label = "10 maszyn", xlabel = "Stosunek ilości zadań do maszyn r", ylabel = "Procent maszyn o przekroczonym dostępie [%]")


# Plots.savefig(p, "results/exceeded_machines_plot.png")

