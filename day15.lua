util = require('util')

day15 = {}

function day15.parseFile(filename)
    local locations = {}
    for line in io.lines(filename) do
        for sx, sy, bx, by in line:gmatch("Sensor at x=([-]*%d+), y=([-]*%d+): closest beacon is at x=([-]*%d+), y=([-]*%d+)") do
            table.insert(locations, { sensor={ x=math.tointeger(sx), y=math.tointeger(sy) }, beacon={ x=math.tointeger(bx), y=math.tointeger(by)} })
        end
    end
    return locations
end

function day15.manhattan(p1, p2)
    return math.abs(p1.x - p2.x) + math.abs(p1.y - p2.y)
end

function day15.paint(locations, lineIdx)
    local map = {}

    local minp, maxp = { x=math.maxinteger, y=math.maxinteger }, { x=math.mininteger, y=math.mininteger }
    for _, p in ipairs(locations) do
        local absManhattan = day15.manhattan(p.sensor, p.beacon)
        local pointsFor = 0

        if map[p.sensor.y] == nil then
            map[p.sensor.y] = {}
        end
        map[p.sensor.y][p.sensor.x] = "S"
        if map[p.beacon.y] == nil then
            map[p.beacon.y] = {}
        end
        map[p.beacon.y][p.beacon.x] = "B"

        local y = lineIdx
        for x=-absManhattan,absManhattan,1 do
            if math.abs(x) + math.abs(y - p.sensor.y) <= absManhattan then
                local tp = { x=p.sensor.x + x, y=y }
                if tp.x < minp.x then
                    minp.x = tp.x
                end
                if tp.x > maxp.x then
                    maxp.x = tp.x
                end
                if tp.y < minp.y then
                    minp.y = tp.y
                end
                if tp.y > maxp.y then
                    maxp.y = tp.y
                end

                if map[tp.y] == nil then
                    map[tp.y] = {}
                end

                if map[tp.y][tp.x] == nil then
                    map[tp.y][tp.x] = '#'
                end
                pointsFor = pointsFor+1
            end
        end
    end

    local countNone = 0
    local y = lineIdx
    for x=minp.x,maxp.x,1 do
        if map[y] ~= nil and map[y][x] ~= nil then
            if map[y][x] == "#" then
                countNone = countNone + 1
            end
        else
        end
    end
    return countNone
end

function day15.add(p1, p2)
    return {x=p1.x + p2.x, y=p1.y + p2.y}
end

function day15.insert(c, p, v)
    if c[p.y] == nil then
        c[p.y] = {}
    end
    c[p.y][p.x] = v
end

function day15.contains(c, p)
    return c[p.y] ~= nil and c[p.y][p.x] ~= nil
end

-- returns nil if intersection, point if intersection
-- p1, p2 is a line of form y=+x + n_1
-- p3, p4 is a line of form y=-x + n_3
function day15.lineIntersect(b1, expManh1, b2, expManh2, p1, p3)
    local n1 = p1.y - p1.x
    local n3 = p3.y + p3.x

    local commonX = (n3 - n1) // 2
    local y1 = commonX + n1
    local ptIn = {x=commonX, y=y1}
    if day15.manhattan(b1, ptIn) == expManh1 and day15.manhattan(b2, ptIn) == expManh2 then
        return ptIn
    else
        return nil
    end
end

function day15.intersect(locations)
    -- the idea is to find all intersections between all edges of beacons
    -- include also the beacon default diamond edges
    -- the goal point to find will be between 4 edges (if we're lucky there will be only one)
    local edges = {}
    for i=1,#locations-1 do
        local p1 = locations[i]

        local dist1 = day15.manhattan(p1.sensor, p1.beacon)
        local pts1 = {
            day15.add(p1.sensor, {x=-dist1, y=0}),
            day15.add(p1.sensor, {x=0, y=dist1}),
            day15.add(p1.sensor, {x=dist1, y=0}),
            day15.add(p1.sensor, {x=0, y=-dist1})
        }
        for pti=1,#pts1 do
            day15.insert(edges, pts1[pti], true)
        end

        for j=i+1,#locations do
            local p2 = locations[j]
            local dist2 = day15.manhattan(p2.sensor, p2.beacon)
            local pts2 = {
                day15.add(p2.sensor, {x=-dist2, y=0}),
                day15.add(p2.sensor, {x=0, y=dist2}),
                day15.add(p2.sensor, {x=dist2, y=0}),
                day15.add(p2.sensor, {x=0, y=-dist2})
            }
            for ptj=1,#pts2 do
                day15.insert(edges, pts2[ptj], true)
            end

            -- assuming a diamond shape with points
            --  2
            -- 1 3
            --  4
            -- find intersections between first/second location: 1-2/2-3, 1-2/1-4, 4-3/1-4, 4-3/2-3,
            -- then find intersections between first/second location: 1-4/1-2, 1-4/4-3, 2-3/1-2, 2-3/4-3
            local ptlst = {
                {p1=pts1[1], p2=pts2[2]},
                {p1=pts1[1], p2=pts2[1]},
                {p1=pts1[4], p2=pts2[1]},
                {p1=pts1[4], p2=pts2[2]},

                {p1=pts2[1], p2=pts1[1]},
                {p1=pts2[4], p2=pts1[1]},
                {p1=pts2[1], p2=pts1[2]},
                {p1=pts2[4], p2=pts1[2]},
            }
            for ptx=1,#ptlst do
                local ptin = day15.lineIntersect(p1.sensor, dist1, p2.sensor, dist2, ptlst[ptx].p1, ptlst[ptx].p2)
                if ptin ~= nil then
                    day15.insert(edges, ptin, true)
                end
            end

        end
    end

    for y, row in pairs(edges) do
        for x, _ in pairs(row) do
            local p={x=x, y=y}
            if day15.contains(edges, day15.add(p, {x=2, y=0})) and
                    day15.contains(edges, day15.add(p, {x=1, y=1})) and
                    day15.contains(edges, day15.add(p, {x=1, y=-1})) then
                local targetPoint = {x=p.x+1, y=p.y}
                return targetPoint.x * 4000000 + y
            end
        end
    end

    return nil
end

if util.is_main(arg, ...) then
    local loc = day15.parseFile("input/day15_input.txt")
    local painted = day15.paint(loc, 2000000)
    print("[day 15] unavailable position counts:", painted)
    print("[day 15] tuning frequency", day15.intersect(loc))
end

return day15