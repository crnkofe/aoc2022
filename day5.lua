util = require('util')

day5 = { }

function day5.printTable(t)
    for idx, stack in pairs(t) do
        local stackValues = ""
        for stackIndex, stackValue in pairs(stack) do
            stackValues = stackValues .. stackValue
        end
        print(idx, stackValues)
    end
end

function day5.parseState(filename)
    local stacks = {}
    for line in io.lines(filename) do
        local stackIndex = 1
        for i = 1,#line do
            if ((i-1) % 4 == 1) then
                if (stacks[stackIndex] == nil) then
                    stacks[stackIndex] = {}
                end
                local ch = string.sub(line, i, i)
                if (ch ~= " ") and (ch ~= "1") then
                    table.insert(stacks[stackIndex], 1, ch)
                end
                if (ch == "1") then
                    break
                end

                stackIndex = stackIndex + 1
            end
        end
        if line == "" then
            break
        end
    end
    return stacks
end

function day5.move(stacks, count, from, to, inOrder)
    local stackToLen = #stacks[to]
    for i = 1,count do
        stackFrom = stacks[from]
        stackTo = stacks[to]
        if inOrder then
            table.insert(stackTo, stackFrom[#stackFrom])
        else
            table.insert(stackTo, stackToLen+1, stackFrom[#stackFrom])
        end
        stackFrom[#stackFrom] = nil
    end
    return stacks
end

function day5.solution(stacks)
    local solution = ""
    for idx, stack in pairs(stacks) do
        if (#stack ~= 0) then
            solution = solution .. stack[#stack]
        end
    end
    return solution
end

function day5.processInstructions(stacks, filename, inOrder)
    local startProcessing = false
    local instructionRegex = 'move (%d+) from (%d+) to (%d+)'
    for line in io.lines(filename) do
        moves = {}
        if startProcessing and (line ~= "") then
            for countRaw, fromStackRaw, toStackRaw in string.gmatch(line, instructionRegex) do
                count, fromStack, toStack = math.tointeger(countRaw), math.tointeger(fromStackRaw), math.tointeger(toStackRaw)
                day5.move(stacks, count, fromStack, toStack, inOrder)
            end
        end

        if not startProcessing and (string.sub(line, 2, 2) == "1") then
            startProcessing = true
        end
    end
    return stacks
end

if util.is_main(arg, ...) then
    local fn = "input/day5_input.txt"
    local t = day5.parseState(fn)

    local inOrderStacks = day5.processInstructions(t, fn, true)
    local inOrderStackTops = day5.solution(inOrderStacks)

    local t2 = day5.parseState(fn)
    local bulkOrderStacks = day5.processInstructions(t2, fn, false)
    local bulkOrderStackTops = day5.solution(bulkOrderStacks)

    print("[day 5] rearranged stacks:", inOrderStackTops)
    print("[day 5] rearranged stacks in bulk:", bulkOrderStackTops)
end

return day5