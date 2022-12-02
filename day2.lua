util = require('util')

day2 = {}

-- player 1 is XYZ
function day2.player1Wins(move1, move2)
    return move2 == "C" and move1 == "X" or
        move2 == "A" and move1 == "Y" or
        move2 == "B" and move1 == "Z"
end


function day2.draw(move1, move2)
    return move2 == "A" and move1 == "X" or
            move2 == "B" and move1 == "Y" or
            move2 == "C" and move1 == "Z"
end

function day2.scorePlayer1(strategy, moves)
    player1Points = 0

    -- local opponent_signs = { "Y", "X", "Z"}
    for i=1,#moves do
        moveIdx = strategy[moves[i].p1]
        if day2.player1Wins(moves[i].p1, moves[i].p2) then
            player1Points = player1Points + 6
        elseif day2.draw(moves[i].p1, moves[i].p2) then
            player1Points = player1Points + 3
        end
        player1Points = player1Points + moveIdx
    end

    return player1Points
end

-- X means you need to lose, Y means you need to end the round in a draw, and Z means you need to win. Good luck!"
function day2.pickDesiredMove(move)
    local loose = {}
    loose["A"] = "Z"
    loose["B"] = "X"
    loose["C"] = "Y"

    local win = {}
    win["A"] = "Y"
    win["B"] = "Z"
    win["C"] = "X"

    local draw = {}
    draw["A"] = "X"
    draw["B"] = "Y"
    draw["C"] = "Z"
    if move.p1 == "X" then
        return loose[move.p2]
    elseif move.p1 == "Y" then
        return draw[move.p2]
    else -- Z
        return win[move.p2]
    end
end


function day2.scoreStrategicPlayer1(strategy, moves)
    player1Points = 0

    -- local opponent_signs = { "Y", "X", "Z"}
    for i=1,#moves do
        local p1move = day2.pickDesiredMove(moves[i])
        moveIdx = strategy[p1move]
        if day2.player1Wins(p1move, moves[i].p2) then
            player1Points = player1Points + 6
        elseif day2.draw(p1move, moves[i].p2) then
            player1Points = player1Points + 3
        end
        player1Points = player1Points + moveIdx
    end

    return player1Points
end

function day2.loadMoves(filename)
    local splitSpaceRegex = '([^ ]+)'
    moves = {}
    for line in io.lines(filename) do
        local p2 = ""
        local p1 = ""
        for x in string.gmatch(line, splitSpaceRegex) do
            if p2 == "" then
                p2 = x
            else
                p1 = x
                table.insert(moves, { p1=p1, p2=p2 })
                p2 = ""
            end
        end
    end
    return moves
end

if util.is_main(arg, ...) then
     --A (Rock), B (Paper), C (Scissors)
     --X (Rock), Y (Paper), Z (Scissors)
    local strategy = {}
    strategy["X"] = 1
    strategy["Y"] = 2
    strategy["Z"] = 3
    local moves = day2.loadMoves("input/day2_input.txt")
    local player1Points = day2.scorePlayer1(strategy, moves)
    print("[day 2] player 1 score: ", player1Points)

    local strategicPlayer1Points = day2.scoreStrategicPlayer1(strategy, moves)
    print("[day 2] strategic player 1 score: ", strategicPlayer1Points)
end

return day2