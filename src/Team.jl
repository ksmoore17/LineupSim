module Team

import Combinatorics, DataFrames, CSV, StatsBase, Distributions

include("./Order.jl")

function Sim()
    team = Create()
    teamruns = Dict{Array, Matrix}()

    (lowteambans, highteambans) = BanBatters(team)

    for order in Combinatorics.permutations(1:9)
        if any(x -> x in order[1:3], lowteambans) || any(x -> x in order[7:9], highteambans)
            continue
        else
            continue
            teamruns[order] = Order.Sim(order, team, 5)
        end
    end
end

function Create(teamsize = 9)
    team = Vector{Dict}(undef, teamsize)

    talentframe = DataFrames.DataFrame(CSV.File(joinpath(@__DIR__,
        "..",
        "data",
        "talents",
        "talent.csv")))
    talentdists = Dict{Symbol, Tuple}()

    binamount = convert(Int, round(log(2, length(talentframe[1])) + 1))

    for statname in names(talentframe)
        if statname in [:X3B, :HBP, :IBB, :HR, :SF, :SH]
            talentdists[statname] = TalentFreq(filter(
                x -> x != 0, talentframe[statname]),
                binamount - 1,
                [(0, 0)],
                [length(filter(x -> x == 0, talentframe[statname]))])
        elseif statname != "Column1"
            talentdists[statname] = TalentFreq(talentframe[statname], binamount)
        end
    end

    for i in 1:teamsize
        team[i] = CreateBatter(talentdists)
    end

    return team
end

function TalentFreq(talentsample, binamount, prebinbounds = [], prebinfreqs = Vector{Int}(undef, 0))
    statmax = maximum(talentsample) + .0000001
    statmin = minimum(talentsample)

    binwidth = (statmax - statmin) / binamount
    binbreaks = Vector{}(undef, binamount + 1)
    binbounds = Vector{Tuple}(undef, binamount)
    binfreqs = Vector{Int}(undef, binamount)

    binbreaks[1] = statmin
    binbreaks[binamount + 1] = statmax

    for i in 2:binamount + 1
        binbreaks[i] = ((i - 1) * binwidth) + binbreaks[1]
    end

    for i in 1:length(binbreaks) - 1
        count = 0
        lowerbound = binbreaks[i]
        upperbound = binbreaks[i + 1]
        for stat in talentsample
            lowerbound <= stat < upperbound ? count += 1 : continue
        end
        binbounds[i] = (lowerbound, upperbound)
        binfreqs[i] = count
    end

    return (vcat(prebinbounds, binbounds), vcat(prebinfreqs, binfreqs))
end

function CreateBatter(talentdists)
    player = Dict{Symbol, Number}()
    for (talentname, talentdist) in pairs(talentdists)
        talentrange = StatsBase.sample(talentdist[1], StatsBase.FrequencyWeights(talentdist[2]))
        if talentrange[2] == 0
            player[talentname] = 0
        else
            player[talentname] = rand(Distributions.Uniform(talentrange[1], talentrange[2]))
        end
    end

    di = .000137

    walks = player[:UBB] + player[:IBB]
    h = player[:X1B] + player[:X2B] + player[:X2B] + player[:HR]
    ab = 1 - walks - player[:HBP] - player[:SH] - player[:SF] - di

    player[:BA] = h / ab

    player[:OBP] = ((h + walks + player[:HBP]) /
        (ab + walks + player[:HBP] + player[:SF]))

    player[:SLG] = (player[:X1B] + 2 * player[:X2B] + 3 * player[:X3B] + 4 * player[:HR]) / ab

    player[:OPS] = player[:OBP] + player[:SLG]

    player[:wOBA] = ((.7*(player[:UBB] + player[:HBP]) + .9 * player[:X1B] +
        1.25 * player[:X2B] + 1.6 * player[:X3B] + 2 * player[:HR])
        / (ab + player[:UBB] + player[:SF] + player[:HBP]))

    return player
end

function BanBatters(team::Array, banbest = 3, banworst = 3)
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
