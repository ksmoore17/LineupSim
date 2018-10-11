module OrderSim
export Sim

include("./GameSim.jl")

function Sim(order::Array, seasons::Int = 1, games::Int = 162)
    sampleruns = Matrix{Int8}(undef, seasons, games)
    for season in 1:seasons
        for game in 1:games
            sampleruns[season, game] = GameSim.Game(order)
        end
    end
    return sampleruns
end

end
