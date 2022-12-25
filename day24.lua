util = require('util')
point = require("point")
heap = require('heap')

day24 = {}

function day24.parseCanyonPos(filename)
    local row = 1
    local g = {}
    local winds = { ["<"]={}, [">"]={}, ["^"]={}, ["v"]={}}
    local minp, maxp = point.maxint2(), point.minint2()
    for line in io.lines(filename) do
        for col=1,#line do
            if g[row] == nil then
                g[row] = {}
            end
            local ch = string.sub(line, col, col)
            if ch == "#" then
                g[row][col] = "#"
            elseif ch == "<" or ch == ">" or ch == "v" or ch == "^" then
                table.insert(winds[ch], point.p2(col, row))
            end
            minp = point.min2(minp, point.p2(col, row))
            maxp = point.max2(maxp, point.p2(col, row))
        end
        row = row+1
    end
    start = { x=2, y=1}
    goal = { x=maxp.x-1, y=maxp.y}
    return g, winds, start, goal, minp, maxp
end

function day24.exists(g, p)
    return g[p.y] ~= nil and g[p.y][p.x] ~= nil
end

function day24.add(g, p, from)
    if g[p.y] == nil then
        g[p.y] = {}
    end
    if g[p.y][p.x] == nil then
        g[p.y][p.x] = {}
    end
    table.insert(g[p.y][p.x], from)
end

function day24.set(g, p, v)
    if g[p.y] == nil then
        g[p.y] = {}
    end
    g[p.y][p.x] = v
end

function day24.neighbours(g, node, step, minp, maxp, winds)
    local options = { point.p2(1, 0),  point.p2(0, 1), point.p2(-1, 0), point.p2(0, -1), point.p2(0, 0)}

    local ns = {}
    for oi=1,#options do
        local lp = point.sum2(node.p, options[oi])
        -- check if point exists
        if lp.y < 1 or lp.y > maxp.y then
            goto continue
        end
        if day24.exists(g, lp) and g[lp.y][lp.x] == '#' then
            goto continue
        end

        local dx = maxp.x - minp.x - 1
        local dy = maxp.y - minp.y - 1
        local stephg = (step - 1) % dx + 1
        local stepvg = (step - 1) % dy + 1
        if day24.exists(day24.hg[stephg], lp) or day24.exists(day24.vg[stepvg], lp) then
            goto continue
        end
        -- check if point intersects with any wind and discard such points
        table.insert(ns, {
            id=string.format("%d-%dx%d", step+1, lp.y, lp.x),
            step=step+1,
            p=lp,
        })
        ::continue::
    end
    return ns
end

-- in order to speed up things pregenerate all neighbour wind positions at steps 1..x, 1..y
function day24.generateAllPossibleWinds(winds, minp, maxp)
    -- we need two charts since width != height
    local hg = {}
    for step=1,maxp.x-minp.x-1,1 do
        hg[step] = {}
        for dir, dirWinds in pairs(winds) do
            -- calculate current wind position
            local dx = maxp.x - minp.x - 1
            for wi=1,#dirWinds do
                local wind = dirWinds[wi]
                local nw = point.p2(0, 0)
                if dir == "<" then
                    nw = point.p2((dx - ((maxp.x - (wind.x - (step - 1))) % dx)) + minp.x, wind.y)
                elseif dir == ">" then
                    nw = point.p2(((wind.x - minp.x) + step - 1) % dx + minp.x + 1, wind.y)
                end
                if hg[step][nw.y] == nil then
                    hg[step][nw.y] = {}
                end
                hg[step][nw.y][nw.x] = "#"
            end
        end
    end

    local vg = {}
    for step=1,maxp.y - minp.y -1,1 do
        vg[step] = {}
        for dir, dirWinds in pairs(winds) do
            -- calculate current wind position
            local dy = maxp.y - minp.y - 1
            for wi=1,#dirWinds do
                local wind = dirWinds[wi]
                local nw = point.p2(0, 0)
                if dir == "v" then
                    nw = point.p2(wind.x, ((wind.y - minp.y) + step - 1) % dy + 2)
                elseif dir == "^" then
                    nw = point.p2(wind.x, (dy - (maxp.y - (wind.y - (step - 1))) % dy) + minp.y)
                end
                if vg[step][nw.y] == nil then
                    vg[step][nw.y] = {}
                end
                vg[step][nw.y][nw.x] = "#"
            end
        end
    end

    return hg, vg
end

-- each step of dijkstra is now a pair of step-position because winds move each step
function day24.dijkstra(g, minp, maxp, start, goal, winds, step, limitStep)
    local startNode = {
        id=string.format("%d-%dx%d", step, start.y, start.x),
        step=step,
        p=start,
    }
    local dist, prev, q = {}, {}, {}
    dist[startNode.id] = math.maxinteger
    prev[startNode.id] = nil

    rawQ = {}
    rawQ.cmp = function(a,b)
        local l, r = a.step + day24.manhattan(a.p, goal), b.step + day24.manhattan(b.p, goal)
        return l < r
    end

    q = heap.valueheap(rawQ)
    q:push(startNode)
    day24.hg, day24.vg = day24.generateAllPossibleWinds(winds, minp, maxp)
    dist[startNode.id] = 0
    while q:peek() ~= nil do
        local u = q:pop()
        if u.p.x == goal.x and u.p.y == goal.y then
            local step = u.step
            while u ~= nil do
                u = prev[u.id]
            end
            return step
        end
        if u.step >= limitStep then
            print("timeLimit reached", util.pprints(u))
            return
        end

        local neighbours = day24.neighbours(g, u, u.step, minp, maxp, winds)
        for _, v in pairs(neighbours) do
            local qContainsV = false
            for i=1,#q do
                if q[i].id == v.id then
                    qContainsV = true
                    break
                end
            end
            if qContainsV then
                local alt = dist[u.id] + 1
                if alt < dist[v.id] then
                    dist[v.id] = alt
                    prev[v.id] = u
                end
            else
                q:push(v)
                dist[v.id] = u.step + 1
                prev[v.id] = u
            end
        end
    end
    return dist, prev
end

function day24.manhattan(p1, p2)
    return math.abs(p1.x - p2.x) + math.abs(p1.y - p2.y)
end

if util.is_main(arg, ...) then
    day24.mute = true
    local filename = "input/day24_input.txt"
    local g, winds, start, goal, mip, mxp = day24.parseCanyonPos(filename)

    local firstSteps = day24.dijkstra(g, mip, mxp, start, goal, winds, 1, 500)
    print("[day 24] path forth steps:", firstSteps)
    local stepsBack = day24.dijkstra(g, mip, mxp, goal, start, winds, firstSteps-1, firstSteps+500)
    local stepsToGoal = day24.dijkstra(g, mip, mxp, start, goal, winds, stepsBack, stepsBack+500)
    print("[day 24] path steps forth and back:", stepsToGoal-1)
end

return day24