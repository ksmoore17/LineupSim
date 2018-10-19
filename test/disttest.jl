include(joinpath(@__DIR__,
    "..",
    "src",
    "Team.jl"))

import JSON

outfile = joinpath(@__DIR__, "./testout.json")
f = open(outfile, "w")
JSON.print(f, Team.CreateTeam())
close(f)
