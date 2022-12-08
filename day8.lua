
util = require('util')

day8 = { }

function day8.countVisibleTrees(filename)
    -- idea for part 1:
    -- head through rows left->right and back (keep track of max current height from point of view)
    -- mark: (row, col) in hashmap
    -- transpose lines
    -- repeat procedure on transposed lines, and take care to correctly mark revers (row, col)

    local visibleTrees = {}
    local transposed = {}

    -- scenicScores left to right, right to left, top to bottom, bottom to top
    local scenicScores = {}
    for i=1,4 do
        scenicScores[i] = {}
    end

    local row = 1
    for line in io.lines(filename) do
        local maxHeight = -1
        for col=1,#line do
            local height = math.tointeger(string.sub(line, col, col))
            if transposed[col] == nil then
                transposed[col] = { height }
            else
                table.insert(transposed[col], height)
            end

            if height > maxHeight then
                maxHeight = height
                visibleTrees[string.format("%d-%d", row, col)] = true
            end

            if col > 1 then
                local scenicScore = 0
                for sc = (col-1),1,-1 do
                    local scHeight = math.tointeger(string.sub(line, sc, sc))
                    scenicScore = scenicScore+1
                    if (scHeight >= height) then
                        break
                    end
                end
                scenicScores[1][string.format("%d-%d", row, col)] = scenicScore
            else
                scenicScores[1][string.format("%d-%d", row, 1)] = 0
            end
        end

        maxHeight = -1
        for col=#line,1,-1 do
            local height = math.tointeger(string.sub(line, col, col))
            if height > maxHeight then
                maxHeight = height
                visibleTrees[string.format("%d-%d", row, col)] = true
            end

            if col < #line then
                local scenicScore = 0
                for sc = (col+1),#line do
                    local scHeight = math.tointeger(string.sub(line, sc, sc))
                    scenicScore = scenicScore+1
                    if (scHeight >= height) then
                        break
                    end
                end
                scenicScores[2][string.format("%d-%d", row, col)] = scenicScore
            else
                scenicScores[2][string.format("%d-%d", row, #line)] = 0
            end
        end

        row = row + 1
    end

    for col, rowNumeric in pairs(transposed) do
        local maxHeight = -1
        local previousHeight = 0
        for row=1,#rowNumeric do
            local height = rowNumeric[row]
            if height > maxHeight then
                maxHeight = height
                visibleTrees[string.format("%d-%d", row, col)] = true
            end

            if row > 1 then
                local scenicScore = 0
                for sc = (row-1),1,-1 do
                    local scHeight = rowNumeric[sc]
                    scenicScore = scenicScore+1
                    if (scHeight >= height) then
                        break
                    end
                end
                scenicScores[3][string.format("%d-%d", row, col)] = scenicScore
            else
                scenicScores[3][string.format("%d-%d", 1, col)] = 0
            end
        end

        maxHeight=-1
        previousHeight = 0
        for row=#rowNumeric,1,-1 do
            local height = rowNumeric[row]
            if height > maxHeight then
                maxHeight = height
                visibleTrees[string.format("%d-%d", row, col)] = true
            end

            if row < #rowNumeric then
                local scenicScore = 0
                for sc = (row+1),#rowNumeric do
                    local scHeight = rowNumeric[sc]
                    scenicScore = scenicScore+1
                    if (scHeight >= height) then
                        break
                    end
                end
                scenicScores[4][string.format("%d-%d", row, col)] = scenicScore
            else
                scenicScores[4][string.format("%d-%d", #rowNumeric, col)] = 0
            end
        end
    end

    local maxScenicScore = 0
    local maxPos = nil
    local count = 0
    for r=1,row-1 do
        for c=1,row-1 do
            local key = string.format("%d-%d", r, c)
            local currentScenicScore = 1
            for i=1,4 do
                currentScenicScore = currentScenicScore * scenicScores[i][key]
            end

            if currentScenicScore > maxScenicScore then
                maxScenicScore = currentScenicScore
                maxPos = key
            end
        end
    end
    for k, v in pairs(visibleTrees) do
        count = count + 1
    end
    return count, maxScenicScore
end

if util.is_main(arg, ...) then
    local countVisibleTrees, maxScenicScore = day8.countVisibleTrees("input/day8_input.txt")
    print("[day 8] count visible trees:", countVisibleTrees)
    print("[day 8] max scenic score:", maxScenicScore)
end

return day8