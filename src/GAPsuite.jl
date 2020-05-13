using MyGraph
using IterativeMethods

function process(content::String)
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

        # println(g)
        # println(machienes_times)

        t = @elapsed f = generalized_assignment(g, numberOfJobs, processing_times, machienes_times)

        numberOfExceededMachiens = 0
        averegeOfExtraTime = 0

        for i = 1:numberOfMachines
            time = 0
            for j in delta(f, i + numberOfJobs)
                time = time + processing_times[j, i]
            end
            if time > machienes_times[i]
                # println("$(time), $(machienes_times[i])")
                numberOfExceededMachiens += 1
                averegeOfExtraTime += time / machienes_times[i]
            end
        end

        println("$(numberOfJobs), $(numberOfMachines), $(weight(f)), $(numberOfExceededMachiens), $(averegeOfExtraTime / numberOfExceededMachiens), $(t)")

    end

end


for i = 1:12
    println("plik gap$(i).txt")
    content = Base.read("testdatabase/gap$(i).txt", String)
    process(content)
end
