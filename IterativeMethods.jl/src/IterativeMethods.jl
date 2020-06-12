module IterativeMethods
    using MyGraph
    using JuMP
    using GLPK
    # using CPLEX

    actual_optimizer = GLPK.Optimizer

    export gap
    export mbst_additive_one, mbst_additive_two
    export snd

    include("gap.jl")
    include("mbst+1.jl")
    include("mbst+2.jl")
    include("snd.jl")
end
