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
        team[i] = createbatter(talentdists, namefreqs())
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

function createbatter(talentdists::Dict, namestup::Tuple)
    player = Tuple{Dict}
    talentdict = Dict{Symbol, Float64}()
    aggdict = Dict{Symbol, Float64}()

    bip = 1

    firstname = StatsBase.sample(namestup[1][1], StatsBase.FrequencyWeights(namestup[1][2]))
    lastname = StatsBase.sample(namestup[2][1], StatsBase.FrequencyWeights(namestup[2][2]))

    name = string(firstname, " ", lastname)

    for (talentname, talentdist) in pairs(talentdists)
        talentrange = StatsBase.sample(talentdist[1], StatsBase.FrequencyWeights(talentdist[2]))
        if talentrange[2] == 0
            if talentname != :SH && talentname != :SF
                talentdict[talentname] = 0
            else
                aggdict[talentname] = 0
            end
        else
            talentvalue = rand(Distributions.Uniform(talentrange[1], talentrange[2]))

            if talentname != :SH && talentname != :SF
                talentdict[talentname] = talentvalue
                bip -= talentvalue
            else
                aggdict[talentname] = talentvalue
            end
        end
    end

    talentdict[:BIP] = bip

    di = .000137

    walks = talentdict[:UBB] + talentdict[:IBB]
    h = talentdict[:X1B] + talentdict[:X2B] + talentdict[:X3B] + talentdict[:HR]
    ab = 1 - walks - talentdict[:HBP] - aggdict[:SH] - aggdict[:SF] - di

    aggdict[:H] = h
    aggdict[:AB] = ab

    aggdict[:BA] = h / ab

    aggdict[:OBP] = ((h + walks + talentdict[:HBP]) /
        (ab + walks + talentdict[:HBP] + aggdict[:SF]))

    aggdict[:SLG] = (talentdict[:X1B] + 2 * talentdict[:X2B] + 3 *
        talentdict[:X3B] + 4 * talentdict[:HR]) / ab

    aggdict[:OPS] = aggdict[:OBP] + aggdict[:SLG]

    aggdict[:wOBA] = ((.7*(talentdict[:UBB] + talentdict[:HBP]) + .9 * talentdict[:X1B] +
        1.25 * talentdict[:X2B] + 1.6 * talentdict[:X3B] + 2 * talentdict[:HR])
        / (ab + talentdict[:UBB] + aggdict[:SF] + talentdict[:HBP]))

    player = (talentdict, aggdict, name)

    return player
end

function namefreqs()
    firstnames = Vector{String}(undef, 0)
    firstnamefreqs = Vector{Int}(undef, 0)

    firstnamesfile = CSV.File(joinpath(@__DIR__,
        "..",
        "data",
        "names",
        "firstnames.csv"))

    for row in firstnamesfile
        push!(firstnames, row.x)
        push!(firstnamefreqs, row.freq)
    end

    firstnamestup = (firstnames, firstnamefreqs)

    lastnames = Vector{String}(undef, 0)
    lastnamefreqs = Vector{Int}(undef, 0)

    lastnamesfile = CSV.File(joinpath(@__DIR__,
        "..",
        "data",
        "names",
        "lastnames.csv"))

    for row in lastnamesfile
        push!(lastnames, row.x)
        push!(lastnamefreqs, row.freq)
    end

    lastnamestup = (lastnames, lastnamefreqs)

    return (firstnamestup, lastnamestup)
end
