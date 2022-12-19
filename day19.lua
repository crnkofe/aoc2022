util = require('util')
point = require('point')

day19 = {}

function day19.parseFile(filename)
    local blueprints = {}
    local blueprint = {}
    for line in io.lines(filename) do
        if line == "" then
            table.insert(blueprints, blueprint)
        end

        for num in line:gmatch("Blueprint (%d+)") do
            blueprint = { maxRequired={ ore=0, clay=0, obsidian=0} }
            goto continue
        end

        for robotName, num, oreType in line:gmatch("Each (%a+) robot costs (%d+) (%a+).$") do
            blueprint[robotName] = { [oreType] = math.tointeger(num) }
            if blueprint.maxRequired[oreType] == nil then
                blueprint.maxRequired[oreType] = math.tointeger(num)
            else
                blueprint.maxRequired[oreType] = math.max(math.tointeger(num), blueprint.maxRequired[oreType])
            end
            goto continue
        end

        for robotName, cost1, ore1, cost2, ore2 in line:gmatch("Each (%a+) robot costs (%d+) (%a+) and (%d+) (%a+).$") do
            blueprint[robotName] = { [ore1] = math.tointeger(cost1), [ore2] = math.tointeger(cost2) }
            if blueprint.maxRequired[ore1] == nil then
                blueprint.maxRequired[ore1] = math.tointeger(cost1)
            else
                blueprint.maxRequired[ore1] = math.max(math.tointeger(cost1), blueprint.maxRequired[ore1])
            end

            if blueprint.maxRequired[ore2] == nil then
                blueprint.maxRequired[ore2] = math.tointeger(cost2)
            else
                blueprint.maxRequired[ore2] = math.max(math.tointeger(cost2), blueprint.maxRequired[ore2])
            end

            goto continue
        end

        :: continue ::
    end
    table.insert(blueprints, blueprint)
    return blueprints
end

function day19.dfsMaxResources2(blueprints)
    day19.maxStep = 33
    local geodesMult = 1
    for bk = 1, 3 do
        local blueprint = blueprints[bk]
        day19.geodeAtStep = {}
        day19.entries = 0
        day19.currentBlueprint = blueprint
        local blueprintGeods = day19.dfsForBlueprint({ ["ore"] = { robotCount = 1, oreMined = 0 } }, 1)
        print("***************************")
        print("blueprint", bk, blueprintGeods, day19.entries)
        print("***************************")
        geodesMult = geodesMult * blueprintGeods
    end
    return geodesMult
end

function day19.dfsMaxResources1(blueprints)
    local geodes = 0
    day19.maxStep = 25
    for bk = 1, #blueprints do
        local blueprint = blueprints[bk]
        day19.geodeAtStep = {}
        day19.entries = 0
        day19.currentBlueprint = blueprint
        local blueprintGeods = day19.dfsForBlueprint({ ["ore"] = { robotCount = 1, oreMined = 0 } }, 1)
        print("***************************")
        print("blueprint", bk, blueprintGeods, day19.entries)
        print("***************************")
        geodes = geodes + bk * blueprintGeods
    end
    return geodes
end

-- build a robot if it's possible and return new state after building a robot
-- otherwise return nil
function day19.build(robotName, requirements, state)
    local newState = day19.copyState(state)
    for oreType, oreCount in pairs(requirements) do
        if state[oreType] == nil then
            -- no ore of type available
            return nil
        end
        if state[oreType].oreMined >= oreCount then
            newState[oreType] = { robotCount = state[oreType].robotCount, oreMined = state[oreType].oreMined - oreCount }
        else
            return nil
        end
    end
    if newState[robotName] == nil then
        util.upsert(newState, { robotName }, { robotCount = 1, oreMined = 0 })
    else
        newState[robotName].robotCount = newState[robotName].robotCount + 1
    end
    return newState
end

function day19.dfsForBlueprint(originalState, step)
    day19.entries = day19.entries + 1
    if step >= day19.maxStep then
        if originalState["geode"] ~= nil then
            return originalState["geode"].oreMined
        else
            return 0
        end
    end

    local state = day19.copyState(originalState)
    local maxGeodes = 0
    local nodes = { "geode", "obsidian", "ore", "clay" }
    local build = false
    while not build and step < day19.maxStep do
        -- micro optimization - no point in building anything on last step
        for ni = 1, #nodes do
            local robot = nodes[ni]
            local requirements = day19.currentBlueprint[robot]
            if day19.currentBlueprint.maxRequired[robot] ~= nil then
                -- two options here - either we have too much robots or too many resources
                if state[robot] ~= nil and state[robot].robotCount >= day19.currentBlueprint.maxRequired[robot] then
                    -- skipping because too many robots already
                    goto continue
                end

                if state[robot] ~= nil and state[robot].oreMined ~= nil and state[robot].oreMined >= 2 * day19.currentBlueprint.maxRequired[robot] then
                    -- skipping because of too much resource in stash
                    goto continue
                end
            end

            local newState = day19.build(robot, requirements, state)
            if newState ~= nil then
                build = true
                for robotName, mined in pairs(newState) do
                    if robotName == robot then
                        newState[robotName].oreMined = mined.oreMined + mined.robotCount-1
                    else
                        newState[robotName].oreMined = mined.oreMined + mined.robotCount
                    end
                end
                maxGeodes = math.max(maxGeodes, day19.dfsForBlueprint(newState, step + 1))
            end

            ::continue::
        end

        for robotName, mined in pairs(state) do
            state[robotName].oreMined = mined.oreMined + mined.robotCount
        end

        step = step + 1
    end
    return maxGeodes
end

function day19.copyState(originalState)
    local state = {}
    for robotName, mined in pairs(originalState) do
        util.upsert(state, { robotName }, {})
        state[robotName].robotCount = mined.robotCount
        state[robotName].oreMined = mined.oreMined
    end
    return state
end

if util.is_main(arg, ...) then
    local blueprints = day19.parseFile("input/day19_input.txt")
    util.pprint(blueprints)

    local geodesMult = day19.dfsMaxResources1(blueprints)
    print("[day 19] max minable total:", geodesMult) ---- 2193 is correct - this part doesn't work after modifications for part 2
    --
    local maxGeodes3 = day19.dfsMaxResources2(blueprints)
    print("[day 19] max minable total at step 32:", maxGeodes3)
end

return day17