import CSV

module Batter
export CreateBatter()

function CreateBatter()
    player = Dict{String, Number}()


    talents = [
        "singles",
        "doubles",
        "triples",
        "homeruns",
        "walks",
        "strikeouts",
        "intentional_walks",
        "hbp"
        ]

    for talent in talents
        player[talent] = TrueTalent(talent)
    end
end

function TrueTalent(talent)
    #csv.talent
end

end
