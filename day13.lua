util = require('util')

day13 = {}

function day13.lineToArray(line)
    local stack = { }
    local currentNum = nil
    for i=1,#line do
        local ch = string.sub(line, i, i)
        if ch == "[" then
            table.insert(stack, {})
        elseif ch == "]" then
            if currentNum ~= nil then
                table.insert(stack[#stack], currentNum)
                currentNum = nil
            end
            local last = stack[#stack]
            table.remove(stack, #stack)
            if #stack == 0 then
                table.insert(stack, last)
            else
                table.insert(stack[#stack], last)
            end

        elseif ch == "," then
            if currentNum ~= nil then
                table.insert(stack[#stack], currentNum)
                currentNum = nil
            end
        else
            if currentNum == nil then
                currentNum = 0
            end
            currentNum = currentNum*10 + math.tointeger(ch)
        end
    end
    return stack[1]
end

function day13.pprint(stack)
    if type(stack) == "number" then
        return string.format("%d", stack)
    end

    contents = ""
    for i=1,#stack do
        if i > 1 then
            contents = contents .. ","
        end
        contents = contents .. day13.pprint(stack[i])
    end
    return "[" .. contents .. "]"
end


-- 1 means right order
-- 0 mean unknown
-- -1 means wrong order
function day13.compare(l, r)
    if (type(l) == "table") and (type(r) == "table") then
        local comparisonResult = 0
        for i=1,#l do
            if i > #r then
                return -1
            end
            comparisonResult = day13.compare(l[i], r[i])
            if comparisonResult ~= 0 then
                return comparisonResult
            end
        end
        if comparisonResult == 0 then
            if #l < #r then
                return 1
            end
        end
        return 0
    end

    if (type(l) == "number") and (type(r) == "table") then
        return day13.compare({ l }, r)
    end

    if (type(l) == "table") and (type(r) == "number") then
        return day13.compare(l, { r })
    end

    if (type(l) == "number") and (type(r) == "number") then
        if l < r then
            return 1
        elseif l > r then
            return -1
        elseif l == r then
            return 0
        end
    end
end

function day13.parseCount(filename, addDividers)
    local packets = {}
    local sumIndices = 0
    local i, first, second, index = 0, {}, {}, 1
    for line in io.lines(filename) do
        if i % 3 == 0 then
            first = line
        elseif i % 3 == 1 then
            second = line
            local s1, s2 = day13.lineToArray(first), day13.lineToArray(second)
            local isValid = day13.compare(s1, s2)
            if (isValid > 0) then
                sumIndices = sumIndices + index
            end
            table.insert(packets, s1)
            table.insert(packets, s2)
            index = index + 1
        end

        i = i + 1
    end

    local d1, d2 = day13.lineToArray("[[2]]"), day13.lineToArray("[[6]]")
    if addDividers then
        table.insert(packets, d1)
        table.insert(packets, d2)
    end

    table.sort(packets, function(s1,s2) return day13.compare(s1, s2) > 0 end)
    local decoderKey = 1
    for pi=1,#packets do
        if (day13.pprint(packets[pi]) == "[[2]]") or (day13.pprint(packets[pi]) == "[[6]]") then
            day13.pprint(packets[pi])
            decoderKey = decoderKey * pi
        end
    end
    return sumIndices, decoderKey
end

if util.is_main(arg, ...) then
    local sumIndices, _ = day13.parseCount("input/day13_input.txt", false)
    local _, decoderKey = day13.parseCount("input/day13_input.txt", true)
    print("[day 13] count in-order transmissions:", sumIndices)
    print("[day 13] decoder key:", decoderKey)
end

return day13