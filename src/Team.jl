module Team
export CreateTeam

import DataFrames, CSV, StatsBase, Distributions

function CreateTeam()
    team = Vector{Dict}(undef, 9)

    talentframe = DataFrames.DataFrame(CSV.File(joinpath(@__DIR__,
        "..",
        "data",
        "talent",
        "talent.csv")))
    talentdists = Dict{String, Tuple}()

    binamount = convert(Int, round(log(2, length(talentframe[1])) + 1))

    for statname in names(talentframe)
        talentdists[string(statname)] = TalentFreq(talentframe[statname], binamount)
    end

    for i in 1:9
        team[i] = CreateBatter(talentdists)
    end

    return team
end

function CreateBatter(talentdists)
    player = Dict{Symbol, Number}()

    for (talent, talentdist) in pairs(talentdists)
        talentrange = StatsBase.sample(talentdist[1], StatsBase.FrequencyWeights(talentdist[2]))
        player[Symbol(talent)] = rand(Distributions.Uniform(talentrange[1], talentrange[2]))
    end

    h = player[:singles] + player[:doubles] + player[:triples] + player[:homeruns]
    ab = 1 - player[:walks] - player[:hbp] - .007 - .0078 - .000137
    player[:ba] = h / ab
    player[:obp] = (h + player[:walks] + player[:hbp]) / (1 - .0078 - .000137)
    player[:slg] = (player[:singles] + 2 * player[:doubles] + 3 * player[:triples] + 4 * player[:homeruns]) / ab
    player[:ops] = player[:obp] + player[:slg]
    ibb = player[:walks] * player[:intentional_walks]
    ubb = player[:walks] - ibb
    player[:wOBA] = ((.7*(ubb + player[:hbp]) + .9 * player[:singles] +
        1.25 * player[:doubles] + 1.6 * player[:triples] + 2 * player[:homeruns])
        / (1 - ibb - .007))

    return player
end

function TalentFreq(talentsample, binamount)
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

    return (binbounds, binfreqs)
end

function OrderBans(team)

end

end
