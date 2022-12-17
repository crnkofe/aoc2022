util = require('util')

day17 = {}

function day17.cubes()
    local cubes = { "####" }
    table.insert(cubes, [[
.#.
###
.#.]])
    table.insert(cubes,[[
..#
..#
###]])
    table.insert(cubes,[[
#
#
#
#]])

    table.insert(cubes, [[##
##]])




    return cubes
end

function day17.parseFile(filename)
    for line in io.lines(filename) do
        return line
    end
end

function day17.pprint(field, maxY)
    for y = maxY,1,-1 do
        if field[y] ~= nil then
            local l = ""
            for x=1,7 do
                if field[y][x] == nil then
                    l = l .. "."
                else
                    l = l .. field[y][x]
                end
            end
            print(l)
        end
    end
end

function day17.paint(field, cube, height, at, modify)
    local x, y = 0, 0
    for i=1,#cube do
        local c = string.sub(cube, i, i)
        if c == "."  then
            x = x + 1
            goto continue
        end
        if c == "#" then
            if at.x+x < 1 or at.x+x > 7 then
                return false
            end
            if at.y+y <= 0 then
                return false
            end
            if field[at.y + y] == nil or field[at.y + y] ~= nil and field[at.y + y][at.x + x] == nil then
                if modify then
                    if field[at.y+y] == nil then
                        field[at.y+y] = {}
                    end
                    field[at.y+y][at.x+x] = "#"
                end
            else
                return false
            end
        end

        if c == "\n" then
            x = 0
            y = y - 1
        else
            x = x + 1
        end
        ::continue::
    end

    return true
end

function day17.simulate(moves, cubes, limitStopped)
    -- part2 - poišč cikle v grafu
    -- trenutno stanje je globina v vsakem stolpcu, indeks kocke, indeks poteze
    -- ko najdem cikel poiščem štartno globino * modulo aritmetiko
    local field = { }

    cubeHeight = {}
    for i=1,#cubes do
        cubeHeight[i] = 1
        for ci=1,#cubes[i] do
            if string.sub(cubes[i], ci, ci) == "\n" then
                cubeHeight[i] = cubeHeight[i] + 1
            end
        end
    end

    local maxY = 0
    local move, cube, at, countStopped = 1, 1, {x=3, y=3 + cubeHeight[1]}, 0
    local cycleMap = {}
    local heightAtBlock = {}
    while countStopped < limitStopped do
        local candidateMoveIdx = at.x
        if string.sub(moves, move, move) == "<" then
            candidateMoveIdx = math.max((candidateMoveIdx - 1), 0)
        else
            candidateMoveIdx = math.max((candidateMoveIdx + 1), 0)
        end
        if day17.paint(field, cubes[cube], cubeHeight[cube], {x=candidateMoveIdx, y=at.y}, false) then
            at.x = candidateMoveIdx
        end
        local nextY = at.y-1
        if not day17.paint(field, cubes[cube], cubeHeight[cube], {x=at.x, y=nextY}, false) then
            day17.paint(field, cubes[cube], cubeHeight[cube], {x=at.x, y=at.y}, true)
            maxY = math.max(maxY, at.y)
            -- part 2 related
            for py=1,cubeHeight[cube] do
                if field[at.y-py-1] ~= nil then
                    -- check lines at.y-py-1 for pattern ###.###
                    local line = ""
                    for x=1,7 do
                        local row = field[at.y-py-1]
                        if row == nil then
                            line = line .. "."
                        else
                            if row[x] ~= nil then
                                line = line .. row[x]
                            else
                                line = line .. "."
                            end
                        end
                    end
                    if line == "###.###" then
                        local key = string.format("%s-%s", cube, move)
                        if cycleMap[key] ~= nil then
                            local cycleLen = countStopped - cycleMap[key].stopped
                            local hdiff = maxY - cycleMap[key].mx
                            local endHeight = cycleMap[key].mx + ((limitStopped - cycleMap[key].stopped) // cycleLen) * hdiff
                            local remaining = ((limitStopped - cycleMap[key].stopped) % cycleLen)
                            local remainderDiff = heightAtBlock[cycleMap[key].stopped + remaining] - heightAtBlock[cycleMap[key].stopped]
                            return endHeight + remainderDiff
                        end
                        cycleMap[key] = {stopped=countStopped, mx=maxY}
                    end
                end
            end

            cube = cube + 1
            if cube > #cubes then
                cube = 1
            end

            heightAtBlock[countStopped] = maxY
            at = {x=3, y=maxY + cubeHeight[cube] + 3}
            countStopped = countStopped + 1
        else
            at.y = nextY
        end

        move = move + 1
        if move > #moves then
            move = 1
        end
    end

    local k = 0
    for y, _ in pairs(field) do
        k = math.max(k, y)
    end

    return k
end

if util.is_main(arg, ...) then
    local moves = day17.parseFile("input/day17_input.txt")
    local cubes = day17.cubes()
    local maxY = day17.simulate(moves, cubes, 2022)
    local maxYPart2 = day17.simulate(moves, cubes, 1000000000000)

    print("[day 17] tetris tower height:", maxY)
    print("[day 17] tetris tower height:", maxYPart2 - 1) -- MINUS ONE ?!
end

return day17