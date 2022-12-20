util = require('util')

day20 = {}

function day20.printState(state)
    local s = ""
    for x = 1, #state do
        if x > 1 then
            s = s .. ","
        end
        s = s .. string.format(state[x].v)
    end
    print(s)
end

function day20.parseFile(filename)
    local state = {}
    local i = 1
    for line in io.lines(filename) do
        table.insert(state, { i = i, v = math.tointeger(line) })
        i = i + 1
    end

    for oi = 1, #state do
        local fi = nil
        for si = 1, #state do
            if state[si].i == oi then
                fi = si
                break
            end
        end

        local el = state[fi]
        local v = el.v

        local newPos = 0
        if ((fi - 1) + v) % (#state - 1) == 0 then
            newPos = #state
        else
            newPos = ((fi - 1) + v) % (#state - 1) + 1
        end

        if newPos == fi then
            -- do nothing
        else
            table.remove(state, fi)
            table.insert(state, newPos, el)
        end
    end

    local zeroIndex = 0
    local orderedLst = {}
    for i = 1, #state do
        local fi = nil
        for si = 1, #state do
            if state[si].i == i then
                if state[si].v == 0 then
                    zeroIndex = si
                end
                table.insert(orderedLst, state[si])
                break
            end
        end
    end

    local pos1000 = ((zeroIndex + 1000 - 1) % #state) + 1
    local pos2000 = ((zeroIndex + 2000 - 1) % #state) + 1
    local pos3000 = ((zeroIndex + 3000 - 1) % #state) + 1
    return state[pos1000].v + state[pos2000].v + state[pos3000].v
end


function day20.parseFile2(filename)
    local decryptionKey = 811589153
    local state = {}
    local i = 1
    for line in io.lines(filename) do
        table.insert(state, { i = i, v = math.tointeger(line) * decryptionKey})
        i = i + 1
    end

    for step=1,10 do
        for oi = 1, #state do
            local fi = nil
            for si = 1, #state do
                if state[si].i == oi then
                    fi = si
                    break
                end
            end

            local el = state[fi]
            local v = el.v

            local newPos = 0
            if ((fi - 1) + v) % (#state - 1) == 0 then
                newPos = #state
            else
                newPos = ((fi - 1) + v) % (#state - 1) + 1
            end

            if newPos == fi then
                -- do nothing
            else
                table.remove(state, fi)
                table.insert(state, newPos, el)
            end
        end
    end

    local zeroIndex = 0
    local orderedLst = {}
    for i = 1, #state do
        local fi = nil
        for si = 1, #state do
            if state[si].i == i then
                if state[si].v == 0 then
                    zeroIndex = si
                end
                table.insert(orderedLst, state[si])
                break
            end
        end
    end

    local pos1000 = ((zeroIndex + 1000 - 1) % #state) + 1
    local pos2000 = ((zeroIndex + 2000 - 1) % #state) + 1
    local pos3000 = ((zeroIndex + 3000 - 1) % #state) + 1
    return state[pos1000].v + state[pos2000].v + state[pos3000].v
end


if util.is_main(arg, ...) then
    local filename = "input/day20_input.txt"
    local sumOf = day20.parseFile(filename)
    print("[day 20] coordinates sum:", sumOf)

    local sumOf2 = day20.parseFile2(filename)
    print("[day 20] coordinates sum with dec. key:", sumOf2)
end

return day20