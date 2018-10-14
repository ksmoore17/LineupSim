module Team
export CreateTeam

include("./Batter.jl")
import DataFrames

function CreateTeam()
    team = Vector{Dict}(undef, 9)

    talentframe = DataFrames.DataFrame(CSV.File(joinpath(@__DIR__,
        "..",
        "data",
        "talent",
        "talent.csv")))
    talentfreqs = Dict{String, Tuple}()

    binamount = convert(Int, round(log(2, length(talentframe[1])) + 1))

    for statname in names(talentframe)
        talentfreqs[string(statname)] = TalentFreq(talentframe[statname], binamount)
    end

    for i in 1:9
        team[i] = Batter.CreateBatter(talentfreqs)
    end
    return team
end

function OrderBans(team)

end

function TalentFreq(talentdist, binamount)
    statmax = maximum(talentdist) + .0000001

    binwidth = (statmax - minimum(talentdist)) / binamount
    binbreaks = Vector{}(undef, binamount + 1)
    talentbinfreqs = Vector{}(undef, binamount)
    talentbinbounds = Vector{}(undef, binamount)

    binbreaks[1] = minimum(talentdist)
    binbreaks[binamount + 1] = statmax

    for i in 2:binamount + 1
        binbreaks[i] = ((i - 1) * binwidth) + binbreaks[1]
    end

    for i in 1:length(binbreaks) - 1
        count = 0
        lowerbound = binbreaks[i]
        upperbound = binbreaks[i + 1]
        for stat in talentdist
            lowerbound <= stat < upperbound ? count += 1 : continue
        end
        talentbinbounds[i] = (lowerbound, upperbound)
        talentbinfreqs[i] = count
    end

    total = sum(talentbinfreqs)
    talentbinfreqs = talentbinfreqs / total

    return (talentbinbounds, talentbinfreqs)
end

end
