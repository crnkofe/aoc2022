util = require('util')

day14 = {}

function day14.parseFile(filename)
    local world = {}
    local minPoint, maxPoint = {x=500, y=0}, {x=500, y=0}
    for line in io.lines(filename) do
        local lastPoint = nil
        for el in line:gmatch("([^-> ]+)") do
            for x, y in string.gmatch(el, "(%d+),(%d+)") do
                currentPoint = { x = math.tointeger(x), y = math.tointeger(y) }
                if minPoint == nil then
                    minPoint = { x = currentPoint.x, y = currentPoint.y }
                else
                    minPoint = { x = math.min(currentPoint.x, minPoint.x), y = math.min(currentPoint.y, minPoint.y) }
                end

                if maxPoint == nil then
                    maxPoint = { x = currentPoint.x, y = currentPoint.y }
                else
                    maxPoint = { x = math.max(currentPoint.x, maxPoint.x), y = math.max(currentPoint.y, maxPoint.y) }
                end

                if lastPoint ~= nil then
                    -- trace point
                    for xi = math.min(currentPoint.x, lastPoint.x), math.max(currentPoint.x, lastPoint.x), 1 do
                        for yi = math.min(currentPoint.y, lastPoint.y), math.max(currentPoint.y, lastPoint.y), 1 do
                            if world[yi] == nil then
                                world[yi] = { }
                            end
                            world[yi][xi] = "#"
                        end
                    end
                end
                lastPoint = { x = currentPoint.x, y = currentPoint.y }
            end
        end
    end
    return world, minPoint, maxPoint
end

function day14.simulate(g, minp, maxp, start, floor)
    local canEmit = true

    local countParticles = 0
    while canEmit do
        --print("round ", countParticles+1)
        --day14.printChart(g, minp, maxp)
        local particle = day14.emit(g, minp, maxp, start, floor)
        if particle == nil then
            canEmit = false
        else
            if g[particle.y] == nil then
                g[particle.y] = {}
            end
            g[particle.y][particle.x] = "o"

            if particle.x > maxp.x then
                maxp.x = particle.x
            end
            if particle.x < minp.x then
                minp.x = particle.x
            end
            countParticles = countParticles + 1
        end
    end
    return countParticles
end


function day14.isFree(g, p, floor)
    if floor ~= nil and p.y >= floor then
        return false
    end

    if g[p.y] == nil or g[p.y] ~= nil and g[p.y][p.x] == nil then
        return true
    else
        return false
    end
end

function day14.emit(g, minp, maxp, op, floor)
    if not day14.isFree(g, op, floor) then
        return nil
    end
    local p = { x=op.x, y=op.y }
    local np = {x=p.x, y=p.y}
    while not stopped and not oob do
        if day14.isFree(g, {x=np.x, y=np.y+1}, floor) then
            -- check one position below
            np = { x=np.x, y=np.y+1 }
        elseif day14.isFree(g, {x=np.x-1, y=np.y+1}, floor) then
            -- check one position below and to the left
            np = { x=np.x-1, y=np.y+1 }
        elseif day14.isFree(g, {x=np.x+1, y=np.y+1}, floor) then
            -- check one position below and to the right
            np = { x=np.x+1, y=np.y+1 }
        end

        -- check if stopped moving
        if np.x == p.x and np.y == p.y then
            if not day14.isFree(g, np, floor) then
                return nil
            else
                return np
            end
        end

        -- out of bounds check
        if floor == nil and np.y > maxp.y then
            return nil
        end

        p = np
    end
end

function day14.printChart(chart, minp, maxp)
    for y = math.min(minp.y, maxp.y), math.max(minp.y, maxp.y+2),1 do
        local line = ""
        for x = math.min(minp.x, maxp.x), math.max(minp.x, maxp.x),1 do
            if chart[y] ~= nil and chart[y][x] ~= nil then
                line = line .. chart[y][x]
            else
                line = line .. "."
            end
        end
        print(line)
    end
end

if util.is_main(arg, ...) then
    local g, minp, maxp = day14.parseFile("input/day14_input.txt")
    local rounds = day14.simulate(g, minp, maxp, {x=500, y=0})
    print("[day 14] sandbox rounds:", rounds)

    local g1, minp, maxp = day14.parseFile("input/day14_input.txt")
    local roundsWithInfiniteFloor = day14.simulate(g1, minp, maxp, {x=500, y=0}, maxp.y+2)
    print("[day 14] sandbox rounds on infinite floor:", roundsWithInfiniteFloor)
end

return day14