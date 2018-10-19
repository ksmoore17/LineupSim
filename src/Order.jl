module Order
export Sim

include("./Game.jl")

function Sim(order::Array, team::Array, seasons::Int = 1, games::Int = 162)
    sampleseasons = Matrix{}(undef, seasons, games)
    for game in 1:games * seasons
            sampleseasons[season, game] = GameSim.Sim(order)
    end

    return sampleseasons
end

end
