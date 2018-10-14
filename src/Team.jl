import DataFrames

module Team
export CreateTeam()

include("./Batter.jl")

function CreateTeam()
    team = Vector{Dict}(undef, 9)

    talentframe = DataFrames.DataFrame(csv.file("../data/talent/talent.csv"))
    talentfreqs = Dict{String, Array}()

    binamount = round(log(2, length(talentframe[1])) + 1)

    for statname in names(talentframe)
        talentfreqs[statname] = TalentFreq(talentframe[:statname], binamount)

    for i in 1:9
        team[i] = CreateBatter(talentfreqs)

    return team
end

function OrderBans()

end

function TalentFreq(talentdist, binamount)
    binwidth = (max(talentdist) - min(talentdist)) / binamount
    binbreaks = Vector{}(undef, binamount + 1)

    binbreaks[1] = min(talentdist)
    binbreaks[binamount] = max(talentdist)

    for i in 2:binamount
        binbreaks[i] = ((i - 1) * binwidth) + binbreaks[1]
    end

    talentbinfreqs = Vector{}(undef, binamount - 1)

    for i in 1:length(binbreaks) - 1
        count = 0
        lowerbound = binbreaks[i]
        upperbound = binbreaks[i + 1]
        for stat in talentdist
            lowerbound < stat < upperbound ? count += 1 : continue
        end
        talentbinfreqs[i] = ((lowerbound, upperbound), count)
    end
end


end
