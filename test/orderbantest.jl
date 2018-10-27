import Random
include(joinpath(@__DIR__,
    "..",
    "src",
    "Team.jl"))
Random.seed!(17)
println(Team.Sim())
