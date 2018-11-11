module LineupSim

import Combinatorics, DataFrames, CSV, StatsBase, Distributions

include("team.jl")
include("event.jl")

function sim(seasons::Int = 1, games::Int = 162)
    team = createteam()
    teamruns = Dict{Array, Matrix}()

    (lowteambans, highteambans) = banbatters(team)

    orderrunslist = []

    events = eventfreq()

    i = 0

    for order in Combinatorics.permutations(1:9)
        i += 1
        if i % 100 == 0
            print(string("Order: ", i, "\r      "))
        end
        runslist = Vector{Int}(undef, games * seasons)
        if any(x -> x in order[1:3], lowteambans) || any(x -> x in order[7:9], highteambans)
            continue
        else
            for game in 1:games * seasons
                runslist[game] = gamesim(order, team, events)
            end
        end
        push!(orderrunslist, tuple(order..., runslist))


    end
    return orderrunslist

end

function gamesim(order::Array, team::Array, events::Dict)
    runs = 0
    inning = 1
    b = 1

    while inning < 10
        basecd = 0
        outs = 0

        while outs < 3
            (basecd, outsinc, runsinc) = plateappearance(team[order[b]], events, basecd, outs)
            runs += runsinc
            outs += outsinc
            #(basecd, runsinc, outsinc) = Event.nonbatter(basecd)
            b = (b % 9) + 1
        end
        inning += 1
    end

    return runs
end

function banbatters(team::Array, banbest::Int = 3, banworst::Int = 3)
    lowteambans = Vector{}()
    highteambans = Vector{}()
    bannedorders = Vector{Vector}()

    idwoba = Dict{}()

    for i in 1:length(team)
        idwoba[i] = team[i][2][:wOBA]
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
