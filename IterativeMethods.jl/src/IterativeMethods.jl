module IterativeMethods
    using MyGraph
    using JuMP
    using GLPK
    # using CPLEX

    actual_optimizer = GLPK.Optimizer

    export mst_with_oracle
    export generalized_assignment
    export gapinfo

    include("mst_with_oracle.jl")
    include("gap.jl")

end
