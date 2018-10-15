module Team
export CreateTeam

include("./Batter.jl")
import DataFrames, CSV

function CreateTeam()
    team = Vector{Dict}(undef, 1603)

    talentframe = DataFrames.DataFrame(CSV.File(joinpath(@__DIR__,
        "..",
        "data",
        "talent",
        "talent.csv")))
    talentdists = Dict{String, Tuple}()

    binamount = convert(Int, 2 * round(log(2, length(talentframe[1])) + 1))

    for statname in names(talentframe)
        talentdists[string(statname)] = TalentFreq(talentframe[statname], binamount)
    end

    for i in 1:1603
        team[i] = Batter.CreateBatter(talentdists)
    end

    return team
end

function OrderBans(team)

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

end
