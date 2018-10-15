module Batter
export CreateBatter

import StatsBase
import Distributions

function CreateBatter(talentdists)
    player = Dict{String, Number}()

    for (talent, talentdist) in pairs(talentdists)
        talentrange = StatsBase.sample(talentdist[1], StatsBase.FrequencyWeights(talentdist[2]))
        player[talent] = rand(Distributions.Uniform(talentrange[1], talentrange[2]))
    end

    return(player)
end

end
