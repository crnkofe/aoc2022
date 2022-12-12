util = require('util')

day12 = {}

function day12.parseGraph(filename)
    local starts = {}
    local goal = {x=0, y=0}

    local graph = {}
    local row = 1
    for line in io.lines(filename) do
        graph[row] = {}
        for col=1,#line do
            local ch = string.sub(line, col, col)
            if ch == "S" then
                table.insert(starts, 1, { x=col, y=row})
                table.insert(graph[row], string.byte("a") - 97)
            elseif ch == "E" then
                goal = { x=col, y=row}
                table.insert(graph[row], string.byte("z") - 97)
            else
                if ch == "a" then
                    table.insert(starts, { x=col, y=row})
                end
                local chOd = string.byte(ch) - 97
                table.insert(graph[row], chOd)
            end
        end
        row = row + 1
    end
    day12.graph = graph
    day12.starts = starts
    day12.goal = goal
    return graph, start, goal
end

function day12.manhattan(p1, p2)
    xdiff, ydiff = math.abs(p2.x - p1.x), math.abs(p2.y - p1.y)
    return xdiff + ydiff
end

function day12.pindex(p)
    return p.y * day12.rowWidth + p.x
end

-- make sure table returns 0 as default (instead of null)
function day12.setDefault (t, d)
    local mt = {__index = function () return d end}
    setmetatable(t, mt)
end

function day12.astar(limitAs)
    local possiblePathLengths = {}
    day12.rowWidth = #day12.graph[1]

    for si=1,#day12.starts do
        if si > limitAs then
            break
        end
        local open = { day12.starts[si] }

        local gScore = { [day12.pindex(day12.starts[si])]=0 }
        day12.setDefault(gScore, math.maxinteger)
        local fScore = { [day12.pindex(day12.starts[si])]=day12.manhattan(day12.starts[si], day12.goal) }
        day12.setDefault(fScore, math.maxinteger)

        local cameFrom = {}

        while #open > 0 do
            local node = open[1]
            local nidx = day12.pindex(node)
            if node.x == day12.goal.x and node.y == day12.goal.y then
                local path = {}
                local from = cameFrom[nidx]
                while from ~= nil do
                    local x = {x=from%day12.rowWidth, y=from//day12.rowWidth}
                    table.insert(path, x)
                    from = cameFrom[from]
                end
                table.insert(possiblePathLengths, #path)
                open = {}
                break
            end
            table.remove(open, 1)

            local neighbours = day12.neighbours(node)
            for ni=1,#neighbours do
                local neighbour = neighbours[ni]
                local neighidx = day12.pindex(neighbour)
                local candGScore = gScore[nidx] + 1  -- 1 is always the distance to neighbour
                if candGScore < gScore[neighidx] then
                    cameFrom[neighidx] = nidx
                    gScore[neighidx] = candGScore
                    fScore[neighidx] = candGScore + day12.manhattan(neighbour, day12.goal)
                    local found = false
                    for openidx=1,#open do
                        if (open[openidx].x == neighbour.x) and  (open[openidx].y == neighbour.y) then
                            found = true
                        end
                    end
                    if not found then
                        table.insert(open, neighbour)
                    end
                end
            end
            table.sort(open, function(n1,n2) return fScore[day12.pindex(n1)] < fScore[day12.pindex(n2)] end)
        end
    end
    table.sort(possiblePathLengths)
    return possiblePathLengths[1]
end

function day12.isValidNeighbour(n)
    return n.x > 0 and n.y > 0 and n.x <= #day12.graph[1] and n.y <= #day12.graph
end

function day12.neighbours(n)
    local neighbours = {}
    local points = { { x=1, y=0 }, { x=-1, y=0 }, { x=0, y=1 }, { x=0, y=-1 } }
    for ip = 1,#points do
        local x, y = points[ip].x, points[ip].y
        local neighbour = {x=n.x + x, y=n.y + y}
        if day12.isValidNeighbour(neighbour) then
            if day12.graph[n.y][n.x] >= (day12.graph[neighbour.y][neighbour.x] - 1) then
                -- elevation check - neighbour can be at most +1 greater
                table.insert(neighbours, neighbour)
            end
       end
    end

    table.sort(neighbours, function(a,b) return day12.manhattan(a, day12.goal) < day12.manhattan(b, day12.goal) end)
    return neighbours
end

function day12.printGraph(graph)
    for row=1,#graph do
        local line = ""
        for c = 1,#graph[row] do
            local val = graph[row][c]
            if val == -1 then
                line = line .. "S"
            elseif val == -2 then
                line = line .. "E"
            else
                line = line .. string.char(val + 97)
            end
        end
        print(line)
    end
end

if util.is_main(arg, ...) then
    local graph, start, goal = day12.parseGraph("input/day12_input.txt")
    local pathLength = day12.astar(1)
    print("[day 12] shortest path:", pathLength)
    local pathLength = day12.astar(#day12.starts)
    print("[day 12] shortest of all starting paths:", pathLength)
end

return day12