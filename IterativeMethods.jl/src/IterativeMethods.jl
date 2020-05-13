module IterativeMethods
    using MyGraph
    using JuMP
    using GLPK

    actual_optimizer = GLPK.Optimizer

    export mst_with_oracle
    export generalized_assignment

    include("mst_with_oracle.jl")
    include("gap.jl")

end
