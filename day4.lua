util = require('util')

day4 = { }

function day4.countIncludedIntervals(filename)
    -- 2-4,6-8
    regex = "(%d+)-(%d+),(%d+)-(%d+)"
    local countIncludedIntervals = 0
    for line in io.lines(filename) do
        for lFromRaw, lToRaw, rFromRaw, rToRaw in string.gmatch(line, regex) do
            lFrom, lTo, rFrom, rTo = math.tointeger(lFromRaw), math.tointeger(lToRaw), math.tointeger(rFromRaw), math.tointeger(rToRaw)
            local leftContainsRight = lFrom <= rFrom and lTo >= rTo
            local rightContainsLeft = rFrom <= lFrom and rTo >= lTo
            if leftContainsRight or rightContainsLeft then
                countIncludedIntervals = countIncludedIntervals + 1
            end
        end
    end
    return countIncludedIntervals
end

function day4.countPartiallyIntersectedRanges(filename)
    -- 2-4,6-8
    regex = "(%d+)-(%d+),(%d+)-(%d+)"
    local countIncludedIntervals = 0
    for line in io.lines(filename) do
        for lFromRaw, lToRaw, rFromRaw, rToRaw in string.gmatch(line, regex) do
            lFrom, lTo, rFrom, rTo = math.tointeger(lFromRaw), math.tointeger(lToRaw), math.tointeger(rFromRaw), math.tointeger(rToRaw)
            local leftContainsOneOfRight = lFrom <= rFrom and lTo >= rFrom or lFrom <= rTo and lTo >= rTo
            local rightContainsOneOfLeft = rFrom <= lFrom and rTo >= lFrom or rFrom <= lTo and rTo >= lTo
            if leftContainsOneOfRight or rightContainsOneOfLeft then
                countIncludedIntervals = countIncludedIntervals + 1
            end
        end
    end
    return countIncludedIntervals
end


if util.is_main(arg, ...) then
    print("[day 4] count included intervals:", day4.countIncludedIntervals("input/day4_input.txt"))
    print("[day 4] count partially intersected intervals:", day4.countPartiallyIntersectedRanges("input/day4_input.txt"))
end

return day4