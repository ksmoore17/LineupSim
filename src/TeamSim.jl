import Combinatorics

module TeamSim

include("./OrderSim.jl")
include("./Team.jl")

function Sim()
    team = Team.CreateTeam()
    teamruns = Dict{Array, Matrix}()
    
    orders = Combinatorics.permutations(1:9)
    bannedorders = BanOrders(team)

    for order in orders
        if order in bannedorders
            continue
        else
            teamruns[order] = OrderSim.Sim(order, 5)
        end
    end
end

function BanOrders(team, banbest = 3, banworst = 3)
    top = Vector{}(banbest)
    bottom = Vector{}(banworst)
    bannedorders = Vector{Vector}()

    for player in team
        #check if the woba is in bottom 3
    end

    return bannedorders
end
