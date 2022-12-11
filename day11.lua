util = require('util')
bn = require("bn")

day11 = {}

function day11.parseGameState(filename)
    local monkeys = {}
    local nameRegex = "Monkey (%d+):"
    local startingItemRegex = "Starting items: (.+)$"
    local startingItemNumberRegex = "(%d+)"
    local testDivisibleByRegex = "Test: divisible by (%d+)"
    local testThrowRegex = "If (.+): throw to monkey (%d+)"
    local operationRegex = "Operation: new = (%w+) ([*+-/]?) (%w+)"
    local currentMonkeyName = 0
    local itemId = 0
    for line in io.lines(filename) do
        if line == "" then
            goto continue
        end

        for name in string.gmatch(line, nameRegex) do
            currentMonkeyName = math.tointeger(name)
            monkeys[currentMonkeyName] = { countInspected = 0 }
            goto continue
        end

        for startingItems in string.gmatch(line, startingItemRegex) do
            for num in startingItems.gmatch(startingItems, startingItemNumberRegex) do
                if monkeys[currentMonkeyName].heldItems == nil then
                    monkeys[currentMonkeyName].heldItems = { { id = itemId, val =  bn(math.tointeger(num))} }
                else
                    table.insert(monkeys[currentMonkeyName].heldItems, { id = itemId, val = bn(math.tointeger(num)), cycle = { }, foundCycle = false })
                end
                itemId = itemId + 1
            end
            goto continue
        end

        for divisibleBy in string.gmatch(line, testDivisibleByRegex) do
            monkeys[currentMonkeyName].divisibleBy = bn(divisibleBy)
            goto continue
        end

        for left, op, right in string.gmatch(line, operationRegex) do
            monkeys[currentMonkeyName].operation = { l = left, op = op, r = right }
        end

        for condition, targetMonkey in string.gmatch(line, testThrowRegex) do
            local cond = (condition == "true")
            if monkeys[currentMonkeyName].throwTo == nil then
                monkeys[currentMonkeyName].throwTo = {}
            end
            monkeys[currentMonkeyName].throwTo[cond] = math.tointeger(targetMonkey)
            goto continue
        end

        :: continue ::
    end
    return monkeys
end

function day11.printGameState(state)
    for monkeyName = 0, #state do
        print(" monkey name:", monkeyName)
        local heldItems = ""
        for i = 1, #state[monkeyName].heldItems do
            if heldItems ~= "" then
                heldItems = heldItems .. ", "
            end
            heldItems = heldItems .. state[monkeyName].heldItems[i].val
        end

        print("  held items:", heldItems)
        print("divide check:", state[monkeyName].divisibleBy)
        print("          op:", string.format("%s %s %s", state[monkeyName].operation.l, state[monkeyName].operation.op, state[monkeyName].operation.r))
        print("    throw to:", string.format("%d or %d", state[monkeyName].throwTo[true], state[monkeyName].throwTo[false]))

        print(" ")
    end
end

function day11.startGame(state, rounds, initialWorryLevel)
    local inspections = {}
    for mi = 1, #state+1 do
        inspections[mi] = 0
    end

    local worryLevel = bn(1)
    if initialWorryLevel == 0 then
        for mi = 0, #state do
            worryLevel = worryLevel * bn(state[mi].divisibleBy)
        end
    else
        worryLevel = bn(initialWorryLevel)
    end

    for turn = 1, rounds do
        if turn % 1000 == 0 then
            print(string.format("Turn %d out of %d", turn, rounds))
        end
        for mi = 0, #state do
            -- monkey seems to always throw the item to another trooper
            for i = 1, #state[mi].heldItems do
                local heldItem = state[mi].heldItems[i]
                inspections[mi+1] = inspections[mi+1] + 1

                local op = state[mi].operation
                local r = bn(heldItem.val)
                if op.r ~= "old" then
                    r = bn(math.tointeger(op.r))
                end

                if state[mi].operation.op == "*" then
                    heldItem.val = heldItem.val * r
                elseif state[mi].operation.op == "+" then
                    heldItem.val = heldItem.val + r
                end

                if initialWorryLevel == 0 then
                    heldItem.val = heldItem.val % worryLevel
                else
                    heldItem.val = heldItem.val / worryLevel
                end
                local remainder = heldItem.val % state[mi].divisibleBy
                local divisible = remainder == bn(0)
                local throwToMonkeyIdx = state[mi].throwTo[divisible]

                table.insert(state[throwToMonkeyIdx].heldItems, heldItem)
            end
            state[mi].heldItems = {}
        end
    end

    table.sort(inspections)
    return bn(inspections[#inspections]) * bn(inspections[#inspections - 1])
end

if util.is_main(arg, ...) then
    local filename = "input/day11_input.txt"
    local gameState1 = day11.parseGameState(filename)
    local gameState2 = day11.parseGameState(filename)
    local inspections1 = day11.startGame(gameState1, 20, 3)
    print("[day 11] monkey business", inspections1)
    print("[day 11] WARNING: this is going to take a few minutes...")
    local inspections2 = day11.startGame(gameState2, 10000, 0)
    print("[day 11] monkey business part 2", inspections2)
end

return day11