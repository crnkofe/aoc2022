-- in memoriam: Buči the budgie (2014-2022)

util = require('util')

day6 = { }

function day6.findMarker(s, countDistinct)
    local chars = {}
    for i=1,#s do
        local ch = string.sub(s, i, i)
        table.insert(chars, ch)
        if #chars > countDistinct then
            table.remove(chars, 1)
        end
        for ch1=1,#chars-1 do
            for ch2=ch1+1,#chars do
                if (chars[ch1] == chars[ch2]) then
                    goto continue
                end
            end
        end

        if (i >= 4) then
            return i
        end

        ::continue::
    end
    return 0
end

function day6.processFile(filename, countDistinct)
    local lastResult = 0
    for line in io.lines(filename) do
        lastResult = day6.findMarker(line, countDistinct)
    end
    return lastResult
end

if util.is_main(arg, ...) then
    print("[day 6] start-of-marker of len  4:", day6.processFile("input/day6_input.txt", 4))
    print("[day 6] start-of-marker of len 14:", day6.processFile("input/day6_input.txt", 14))
end

return day6