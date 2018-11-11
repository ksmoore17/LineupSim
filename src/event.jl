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
            if eventoutput in eventfreqs[eventinput][1]
                i = findfirst(x -> x == eventoutput, eventfreqs[eventinput][1])
                eventfreqs[eventinput][2][i] += event.freq
            else
                push!(eventfreqs[eventinput][1], eventoutput)
                push!(eventfreqs[eventinput][2], event.freq)
            end
        else
            eventfreqs[eventinput] = [[eventoutput], [event.freq]]
        end
    end

    return eventfreqs
end

function plateappearance(batter::Tuple, events::Dict, initbasecd::Integer, initouts::Integer)
    while true
        try
            psum = 0
            p = rand()
            for (stat, statvalue) in pairs(batter[1])
                if psum < p < psum + statvalue
                    eventoutcomes = events[(stat, initbasecd, initouts)]
                    eventoutput = StatsBase.sample(eventoutcomes[1],
                        StatsBase.FrequencyWeights(eventoutcomes[2]))
                    return eventoutput
                else
                    psum += statvalue
                end
            end
        catch
            continue
        end
    end
end

function nonbatter()
    #generate nbe based on game state
end
