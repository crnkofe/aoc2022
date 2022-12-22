util = require('util')
point = require("point")

day22 = {}

function day22.parse(filename)
    local g = {}
    local gDone
    local rowIdx = 1
    local startingPoint = nil
    local move = ""
    local minp, maxp = point.maxint2(), point.minint2()
    day22.size = 50

    for row in io.lines(filename) do
        if row == "" then
            gDone = true
        end
        if not gDone then
            local regionLine = ""
            if g[rowIdx] == nil then
                g[rowIdx] = {}
            end
            for i=1,#row do
                local ch = string.sub(row, i, i)
                if ch == "#" then
                    g[rowIdx][i] = ch
                elseif ch == "." then
                    if startingPoint == nil then
                        startingPoint = {x=i, y=rowIdx}
                        day22.originalStart = {x=i, y=rowIdx}
                    end
                    g[rowIdx][i] = ch
                end

                if ch == nil or ch == " " then
                    regionLine = regionLine .. " "
                else
                    regionLine = regionLine .. string.format("%d", day22.pointRegionID({x=i, y=rowIdx}))
                end

                if ch == '#' or ch == "." then
                    minp.x = math.min(minp.x, i)
                    minp.y = math.min(minp.y, rowIdx)

                    maxp.x = math.max(maxp.x, i)
                    maxp.y = math.max(maxp.y, rowIdx)
                end
            end
            --print(regionLine)
        end
        -- last row will be set as instructions
        move = row
        rowIdx = rowIdx+1
    end
    return g, startingPoint, move, minp, maxp
end

function day22.exists(g, p)
    return g[p.y] ~= nil and g[p.y][p.x] ~= nil
end

function day22.pointInRegion(p, lp, mp)
    return p.x >= lp.x and p.x <= mp.x and p.y >= lp.y  and p.y <= mp.y
end

function day22.pointRegionID(p)
    if day22.pointInRegion(p, day22.originalStart, point.sum2(day22.originalStart, point.p2(49, 49))) then
        return 1
    end

    if day22.pointInRegion(p, point.sum2(day22.originalStart, point.p2(50, 0)), point.sum2(day22.originalStart, point.p2(99, 49))) then
        return 2
    end

    if day22.pointInRegion(p, point.sum2(day22.originalStart, point.p2(0, 50)), point.sum2(day22.originalStart, point.p2(49, 99))) then
        return 3
    end

    if day22.pointInRegion(p, point.p2(1, 101),  point.p2(50, 150)) then
        return 4
    end

    if day22.pointInRegion(p, point.p2(51, 101),  point.p2(100, 150)) then
        return 5
    end

    if day22.pointInRegion(p, point.p2(1, 151),  point.p2(50, 200)) then
        return 6
    end

    return nil
end

function day22.rotateDirection(direction, x, y)
    while direction[1].x ~= x or direction[1].y ~= y do
        local first = table.remove(direction, 1)
        table.insert(direction, first)
    end
end


--
-- ----------------
-- |\       1       \
-- | \----------------
-- | |               |
-- |4|       3       |   <- 2
-- | |               |
--  \|________________
--           ^
--           5
-- 6 is backside (opposite of 3)
function day22.moveByOne(at, direction)
    local idp = day22.pointRegionID(at)
    local nextPoint = point.sum2(at, direction[1])
    local idn = day22.pointRegionID(nextPoint)
    local lp1 = day22.originalStart
    local lp2 = point.sum2(day22.originalStart, point.p2(50, 0))
    local lp3 = point.sum2(day22.originalStart, point.p2(0, 50))
    local lp4 = point.p2(1, 101)
    local lp5 = point.p2(51, 101)
    local lp6 = point.p2(1, 151)

    size = 50
    if idp == idn and idn ~= nil then
        return nextPoint
    else
        if idp == 1 then
            if idn == 2 or idn == 3 then
                return nextPoint
            elseif direction[1].x == -1 then
                -- move off to 4 and change direction
                day22.rotateDirection(direction, 1, 0)
                return point.p2(lp4.x, lp4.y + (size - 1 - (at.y - lp1.y)))
            else
                -- move to 6
                day22.rotateDirection(direction, 1, 0)
                return point.p2(lp6.x, lp6.y + (at.x - lp1.x))
            end
        elseif idp == 2 then
            if idn == 1 then
                return nextPoint
            elseif direction[1].y == 1 then
                -- move to 3
                day22.rotateDirection(direction, -1, 0)
                return point.p2(lp3.x + size -1 , lp3.y + (at.x - lp2.x))
            elseif direction[1].y == -1 then
                -- move off to 6 without changing direction
                day22.rotateDirection(direction, 0, -1)
                return point.p2(lp6.x + (at.x - lp2.x),  lp6.y + size - 1)
            else
                -- move off to 5 and mirror coords
                day22.rotateDirection(direction, -1,0)
                return point.p2(lp5.x + size - 1, lp5.y +  (size - 1 - (at.y - lp2.y)))
            end
        elseif idp == 3 then
            if idn == 1 or idn == 5 then
                return nextPoint
            elseif direction[1].x == 1 then
                -- move to 2
                day22.rotateDirection(direction, 0, -1)
                return point.p2(lp2.x + (at.y - lp3.y), lp2.y + size - 1)
            elseif direction[1].x == -1 then
                -- move to 4
                day22.rotateDirection(direction, 0, 1)
                return point.p2(lp4.x + (at.y - lp3.y), lp4.y)
            end
        elseif idp == 4 then
            if idn == 5 or idn == 6 then
                return nextPoint
            end
            if direction[1].y == -1 then
                day22.rotateDirection(direction, 1, 0)
                return point.p2(lp3.x, lp3.y + (at.x - lp4.x))
            elseif direction[1].x == -1 then
                -- move to 1
                day22.rotateDirection(direction, 1, 0)
                return point.p2(lp1.x, lp1.y + (size - 1 - (at.y - lp4.y)))
            end
        elseif idp == 5 then
            if idn == 3 or idn == 4 then
                return nextPoint
            end
            if direction[1].x == 1 then
                -- move to 2
                day22.rotateDirection(direction, -1, 0)
                return point.p2(lp2.x + size - 1, (50 - (at.y - lp5.y)))
            elseif direction[1].y == 1 then
                -- move to 6
                day22.rotateDirection(direction, -1, 0)
                return point.p2(lp6.x + size - 1, lp6.y + (at.x - lp5.x))
            end
        elseif idp == 6 then
            if idn == 4 then
                return nextPoint
            end
            if direction[1].x == -1 then
                -- 1
                day22.rotateDirection(direction, 0, 1)
                return point.p2(lp1.x + (at.y - lp6.y), lp1.y)
            elseif direction[1].x == 1 then
                -- 5
                day22.rotateDirection(direction, 0, -1)
                return point.p2(lp5.x + (at.y-lp6.y), lp5.y + size - 1)
            elseif direction[1].y == 1 then
                return point.p2(lp2.x + (at.x - lp6.x) , lp2.y)
            end
        end
    end
end

function day22.findNextPoint(g, at, direction, minp, maxp)
    if day22.part2 ~= nil and day22.part2 then
        return day22.moveByOne(at, direction)
    else
        local nextPoint = point.sum2(at, direction[1])
        if not day22.exists(g, nextPoint) then
            -- wraparound
            if direction[1].x == 1 then
                nextPoint.x = 1
            elseif direction[1].x == -1 then
                nextPoint.x = maxp.x
            elseif direction[1].y == 1 then
                nextPoint.y = 1
            elseif direction[1].y == -1 then
                nextPoint.y = maxp.y
            end
            while not day22.exists(g, nextPoint) do
                nextPoint = point.sum2(nextPoint, direction[1])
            end
        end
        return nextPoint
    end
end

function day22.move(g, start, direction, minp, maxp, by)
    if by == 0 then
        return start
    end
    for n=1,by do
        local fromRegion = day22.pointRegionID(start)
        local directionCopy = {}
        for di=1,#direction do
            table.insert(directionCopy, {x=direction[di].x, y=direction[di].y})
        end
        local nextPoint = day22.findNextPoint(g, start, directionCopy, minp, maxp)
        local toRegion = day22.pointRegionID(nextPoint)
        if g[nextPoint.y][nextPoint.x] == "." then
            start = {x=nextPoint.x, y=nextPoint.y}
            for di=1,#directionCopy do
                direction[di] = directionCopy[di]
            end
        else
            break
        end
    end
    return start
end

function day22.moveIt(filename, part2)
    local g, start, move, minp, maxp = day22.parse(filename)
    day22.part2 = part2

    local direction = { {x=1,y=0}, {x=0,y=1}, {x=-1,y=0},  {x=0,y=-1} }
    local by = 0
    for chi = 1,#move do
        local ch = string.sub(move, chi, chi)

        if ch == "R" or ch == "L" then
            start = day22.move(g, start, direction, minp, maxp, by)
            by = 0
            if ch == "R" then
                first = table.remove(direction, 1)
                table.insert(direction, first)
            else
                last = table.remove(direction, 4)
                table.insert(direction, 1, last)
            end
        else -- must be a number
            by = by * 10 + math.tointeger(ch)
        end
    end

    start = day22.move(g, start, direction, minp, maxp, by)
    local facing = 0
    if direction[1].x == 1 then
        facing = 0
    elseif direction[1].y == 1 then
        facing = 1
    elseif direction[1].x == -1 then
        facing = 2
    elseif direction[1].y == -1 then
        facing = 3
    end
    return 1000 * start.y + 4 * start.x + facing
end


if util.is_main(arg, ...) then
    local filename = "input/day22_input.txt"
    local score = day22.moveIt(filename, false)
    print("[day 22] final coordinate score flat:", score)

    local score = day22.moveIt(filename, true)
    print("[day 22] final coordinate score cubed:", score)
end

return day22