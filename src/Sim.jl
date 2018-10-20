module Sim

import Combinatorics

include("./Team.jl")

function Sim(seasons::Int = 1, games::Int = 162)
    team = Team.Create()
    teamruns = Dict{Array, Matrix}()

    (lowteambans, highteambans) = BanBatters(team)

    orderrunslist = Vector{Tuple}(undef, 10)
    runslist = Vector{Int}(undef, games * seasons)

    for order in Combinatorics.permutations(1:9)
        if any(x -> x in order[1:3], lowteambans) || any(x -> x in order[7:9], highteambans)
            continue
        else
            for game in 1:games * seasons
                runslist[game] = Game.Sim(order, team)
            end
        end
        orderrunslist(Tuple(order..., runslist))
    end

end

function BanBatters(team::Array, banbest::Int = 3, banworst::Int = 3)
    lowteambans = Vector{}()
    highteambans = Vector{}()
    bannedorders = Vector{Vector}()

    idwoba = Dict{}()

    for i in 1:length(team)
        idwoba[i] = team[i][:wOBA]
    end

    lowwOBAbans = sort(collect(values(idwoba)))[1:3]
    highwOBAbans = sort(collect(values(idwoba)))[7:9]

    for (index, value) in pairs(idwoba)
        if value in lowwOBAbans
            push!(lowteambans, index)
        elseif value in highwOBAbans
            push!(highteambans, index)
        end
    end

    return (lowteambans, highteambans)
end

end
