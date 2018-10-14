module OrderSim
export Sim

include("./GameSim.jl")

function Sim(order::Array, seasons::Int = 1, games::Int = 162)
    sampleseasons = Matrix{}(undef, seasons, games)
    for season in 1:seasons
        for game in 1:games
            sampleseasons[season, game] = GameSim.Sim(order)
        end
    end
    return sampleseasons
end

end
