util = require('util')

day4 = { }

-- rows is an iterator over input data that returns 4 numbers that represent two ranges A-B,C-D
function day4.rows(filename)
    local regex = "(%d+)-(%d+),(%d+)-(%d+)"
    local lineIter = io.lines(filename)
    return function ()
        local line = lineIter()
        if line == nil then
            return nil
        end

        for lFromRaw, lToRaw, rFromRaw, rToRaw in string.gmatch(line, regex) do
            return math.tointeger(lFromRaw), math.tointeger(lToRaw), math.tointeger(rFromRaw), math.tointeger(rToRaw)
        end
    end
end

function day4.countIncludedIntervals(filename)
    local count = 0
    for lFrom, lTo, rFrom, rTo in day4.rows(filename) do
        local leftContainsRight = lFrom <= rFrom and lTo >= rTo
        local rightContainsLeft = rFrom <= lFrom and rTo >= lTo
        count = count + ((leftContainsRight or rightContainsLeft) and 1 or 0)
    end
    return count
end

function day4.countPartiallyIntersectedRanges(filename)
    local count = 0
    for lFrom, lTo, rFrom, rTo in day4.rows(filename) do
        local leftContainsOneOfRight = lFrom <= rFrom and lTo >= rFrom or lFrom <= rTo and lTo >= rTo
        local rightContainsOneOfLeft = rFrom <= lFrom and rTo >= lFrom or rFrom <= lTo and rTo >= lTo
        count = count + ((leftContainsOneOfRight or rightContainsOneOfLeft) and 1 or 0)
    end
    return count
end


if util.is_main(arg, ...) then
    print("[day 4] count included intervals:", day4.countIncludedIntervals("input/day4_input.txt"))
    print("[day 4] count partially intersected intervals:", day4.countPartiallyIntersectedRanges("input/day4_input.txt"))
end

return day4