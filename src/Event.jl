function eventfreq()
    eventfreqs = Dict{Tuple, Array}()

    file = CSV.File((joinpath(@__DIR__,
        "..",
        "data",
        "events",
        "events.csv")))

    for event in file
        eventcd = event.eventcd
        initbasecd = event.initbasecd
        initouts = event.initouts
        eventoutput = (event.endbasecd, event.outsinc, event.runsinc)

        if eventcd in [2, 17, 18, 19]
            eventcd = :BIP
        elseif eventcd == 3
            eventcd = :SO
        elseif eventcd == 14
            eventcd = :UBB
        elseif eventcd == 15
            eventcd = :IBB
        elseif eventcd == 16
            eventcd = :HBP
        elseif eventcd == 20
            eventcd = :X1B
        elseif eventcd == 21
            eventcd = :X2B
        elseif eventcd == 22
            eventcd = :X3B
        elseif eventcd == 23
            eventcd = :HR
        end

        eventinput = (eventcd, initbasecd, initouts)

        if haskey(eventfreqs, eventinput)
            push!(eventfreqs[eventinput][1], eventoutput)
            push!(eventfreqs[eventinput][2], event.freq)
        else
            eventfreqs[eventinput] = [[eventoutput], [event.freq]]
        end
    end

    return eventfreqs
end

function plateappearance(batter::Dict, events::Dict, initbasecd::Integer, initouts::Integer)
    psum = 0
    p = rand()
    for stat in keys(batter)
        if psum < p < psum + batter[stat]
            eventoutcomes = (stat, initbasecd, initouts)
            eventouput = StatsBase.sample(eventoutcomes[1],
                StatsBase.FrequencyWeights(eventoutcomes[2]))
            return eventouput
        else
            psum += batter[stat]
        end
    end
end

function nonbatter()
    #generate nbe based on game state
end
