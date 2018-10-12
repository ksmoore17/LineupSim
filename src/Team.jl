module Team
export CreateTeam()

("./Batter.jl")

function CreateTeam()
    team = Vector{Dict}(undef, 9)
    for i in 1:9
        team[i] = CreateBatter()
end

end
