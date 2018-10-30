function createteam(teamsize::Int = 9)
    team = Vector{Tuple}(undef, teamsize)

    talentframe = DataFrames.DataFrame(CSV.File(joinpath(@__DIR__,
        "..",
        "data",
        "talents",
        "talents.csv")))
    talentdists = Dict{Symbol, Tuple}()

    binamount = convert(Int, round(log(2, length(talentframe[1])) + 1))

    for statname in names(talentframe)
        if statname in [:X3B, :HBP, :IBB, :HR, :SF, :SH]
            talentdists[statname] = talentsfreqs(
                filter(x -> x != 0, talentframe[statname]),
                binamount - 1,
                [(0, 0)],
                [length(filter(x -> x == 0, talentframe[statname]))]
                )

        elseif statname != :Column1
            talentdists[statname] = talentsfreqs(talentframe[statname], binamount)
        end
    end

    for i in 1:teamsize
        team[i] = createbatter(talentdists)
    end

    return team
end

function talentsfreqs(talentsample::Array,
    binamount::Int,
    prebinbounds::Array = [],
    prebinfreqs::Array = Vector{Int}(undef, 0)
    )

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

function createbatter(talentdists::Dict)
    player = Tuple{Dict}
    talentdict = Dict{Symbol, Float64}()
    ratedict = Dict{Symbol, Float64}()

    bip = 1

    for (talentname, talentdist) in pairs(talentdists)
        talentrange = StatsBase.sample(talentdist[1], StatsBase.FrequencyWeights(talentdist[2]))
        if talentrange[2] == 0
            talentdict[talentname] = 0
        else
            talentvalue = rand(Distributions.Uniform(talentrange[1], talentrange[2]))
            talentdict[talentname] = talentvalue
            bip -= talentvalue
        end
    end

    talentdict[:BIP] = bip

    di = .000137

    walks = talentdict[:UBB] + talentdict[:IBB]
    h = talentdict[:X1B] + talentdict[:X2B] + talentdict[:X3B] + talentdict[:HR]
    ab = 1 - walks - talentdict[:HBP] - talentdict[:SH] - talentdict[:SF] - di

    talentdict[:H] = h
    talentdict[:AB] = ab

    ratedict[:BA] = h / ab

    ratedict[:OBP] = ((h + walks + talentdict[:HBP]) /
        (ab + walks + talentdict[:HBP] + talentdict[:SF]))

    ratedict[:SLG] = (talentdict[:X1B] + 2 * talentdict[:X2B] + 3 *
        talentdict[:X3B] + 4 * talentdict[:HR]) / ab

    ratedict[:OPS] = ratedict[:OBP] + ratedict[:SLG]

    ratedict[:wOBA] = ((.7*(talentdict[:UBB] + talentdict[:HBP]) + .9 * talentdict[:X1B] +
        1.25 * talentdict[:X2B] + 1.6 * talentdict[:X3B] + 2 * talentdict[:HR])
        / (ab + talentdict[:UBB] + talentdict[:SF] + talentdict[:HBP]))

    player = (talentdict, ratedict)

    return player
end
