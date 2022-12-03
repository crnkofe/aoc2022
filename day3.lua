util = require('util')

day3 = { }

-- make sure table returns 0 as default (instead of null)
function day3.setDefault (t, d)
    local mt = {__index = function () return d end}
    setmetatable(t, mt)
end

-- part 1
function day3.countPriorities(filename)
    local totalPriority = 0
    for line in io.lines(filename) do
        local commonCh = ""
        local items = {}
        day3.setDefault(items,0)
        for i = 1,(#line/2) do
            local ch = string.sub(line, i, i)
            local newCount = items[ch]+1
            items[ch] = newCount
        end
        for i = #line/2+1,#line do
            local ch = string.sub(line, i, i)
            if items[ch] ~= 0 then
                -- found item that exists in both left and right part
                -- assuming there is only one match
                commonCh = ch
            end
        end
        totalPriority = totalPriority + day3.priority(commonCh)
    end
    return totalPriority
end

-- part 2
function day3.countTriplePriorities(filename)
    local totalPriority = 0
    -- currentElf ranges from 0-3
    local currentElf = -1
    local elves = {}
    for line in io.lines(filename) do
        currentElf = (currentElf+1)%3
        lst = {}
        local items = {}
        day3.setDefault(items,0)
        -- first find unique items in each of consecutive three lines
        -- store them as a simple hashmap map[ch]=1
        for i = 1,#line do
            local ch = string.sub(line, i, i)
            lst[ch] = 1
        end
        elves[currentElf+1] = lst
        if currentElf == 2 then
            -- iterate through keys of first elf rucksack
            -- check that second and third elf rucksacks contain the common element
            for k,v in pairs(elves[1]) do
                if elves[2][k] ~= nil and elves[3][k] ~= nil then
                    totalPriority = totalPriority + day3.priority(k)
                end
            end
        end
    end
    return totalPriority
end

function day3.priority(ch)
    if ch == "" then
        return 0
    end

    local chOd = string.byte(ch)
    local chPriority = 0
    if chOd >= 97 then -- ord(a) = 97
        chPriority = chOd - 97 + 1
    else
        chPriority = chOd - 65 + 27
    end
    return chPriority
end

if util.is_main(arg, ...) then
    print("[day 3] sum priorities:", day3.countPriorities("input/day3_input.txt"))
    print("[day 3] sum elf group priorities:", day3.countTriplePriorities("input/day3_input.txt"))
end

return day3
