module Game
export Sim

function Sim(order::Array, team::Array)
    runs = 0
    inning = 0
    b = 1

    while inning < 10
        basecd = 0
        outs = 0

        while outs != 3
            (basecd, outs) = NonBatterEvent(basecd)
            (outsinc, basecd, runsinc) = Event(order[b], outs, basecd)
            runs += runsinc
            outs += outsinc
            b = (b + 1) % 10
        end

        inning += 1
    end
    
    return runs
end

end
