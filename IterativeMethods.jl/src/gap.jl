using MyGraph
using JuMP
using GLPK

# processing_times jobs x machines
function gap(h::Graph, jobs_n::Int,
     processing_times::Array{Float64, 2},
     machines_times::Vector{Float64})::Tuple{Graph, Vector{Int}}

    number_of_edges_per_iteration = Vector{Int}(undef, 0)

     f = Graph(nv(h))
     g = deepcopy(h)
     machines_times = deepcopy(machines_times)
     if !is_bipartite(g)
        error("Graf nie jest dwudzielny")
     end

    jobs = Vector{Int}(undef, jobs_n)
    machines = Vector{Int}(undef, nv(g) - jobs_n)
    for i = 1:jobs_n
        jobs[i] = i
    end
    for i = 1:(nv(g) - jobs_n)
        machines[i] = i + jobs_n
    end

# Oczyszczenie danych
    for i in machines
        for j in jobs
            if processing_times[j,i - jobs_n] > machines_times[i - jobs_n]
                rem_edge!(g, i, j)
            end
        end
    end



    while length(jobs) != 0

        push!(number_of_edges_per_iteration, ne(g))
        model = Model(actual_optimizer)
        @variable(model,0 <= x[vi in vertices(g), vj in vertices(g); has_edge(g, vj, vi) && vj < vi] <= 1)

        ex = AffExpr();
        for i in vertices(g), j in vertices(g)
            if has_edge(g, j, i) && j < i
                add_to_expression!(ex, weight(g, j, i), x[i,j])
            end
        end

        @objective(model, Max, ex)

        for j in jobs
            ex = AffExpr()
            for i in [first(d) for d in delta(g, j)]
                    add_to_expression!(ex, 1, x[i, j])
            end
            @constraint(model, ex == 1)
        end

        for i in machines
            ex = AffExpr()
            for j in [first(d) for d in delta(g, i)]
                    add_to_expression!(ex, processing_times[j, i - jobs_n], x[i,j])
            end
            @constraint(model, ex <= machines_times[i - jobs_n])
        end
        # println(model)
        # println(g)
        optimize!(model)
        if termination_status(model) != MOI.OPTIMAL
            error(("Nie znalezniono optymalnego rozwiązania", termination_status(model), model))
        end
        jobs_to_remove = Vector{Int}(undef, 0)
        for j in jobs
            for i in [first(d) for d in delta(g, j)]
                    if round(value(x[i,j]), digits = 2)  == 0.
                        rem_edge!(g, i, j)
                    end

                    if round(value(x[i, j]), digits = 2) == 1.
                        add_edge!(f, i, j, weight(g, i, j))
                        push!(jobs_to_remove, j)
                        machines_times[i - jobs_n] -= processing_times[j, i - jobs_n]
                        rem_vertex!(g, j)
                    end
            end
        end
        for j in jobs_to_remove
            filter!(n -> n != j, jobs)
        end

        # Relaksacja
        for m in machines
            if degree(g, m) == 1 || (degree(g, m) == 2
                && sum([has_edge(g, m, j) ? value(x[m,j]) : 0 for j in jobs]) >= 1)
                filter!(n -> n != m, machines)
                break
            end
        end

    end

    return (f, number_of_edges_per_iteration)
end
