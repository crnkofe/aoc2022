util = require('util')
point = require("point")

day23 = {}

function day23.parseElves(filename)
    local row = 1
    local g = {}
    local minp, maxp = point.maxint2(), point.minint2()
    for line in io.lines(filename) do
        for col=1,#line do
            if g[row] == nil then
                g[row] = {}
            end
            if string.sub(line, col, col) == "#" then
                g[row][col] = "N"
                minp = point.min2(minp, point.p2(col, row))
                maxp = point.max2(maxp, point.p2(col, row))
            end
        end
        row = row+1
    end
    return g, minp, maxp
end

function day23.exists(g, p)
    return g[p.y] ~= nil and g[p.y][p.x] ~= nil
end

function day23.add(g, p, from)
    if g[p.y] == nil then
        g[p.y] = {}
    end
    if g[p.y][p.x] == nil then
        g[p.y][p.x] = {}
    end
    table.insert(g[p.y][p.x], from)
end

function day23.set(g, p, v)
    if g[p.y] == nil then
        g[p.y] = {}
    end
    g[p.y][p.x] = v
end

function day23.simulate(g, minp, maxp)
    local nw, n, ne = point.p2(-1, -1), point.p2(0, -1), point.p2(1, -1)
    local sw, s, se = point.p2(-1, 1), point.p2(0, 1), point.p2(1, 1)
    local w, e = point.p2(-1, 0), point.p2(1, 0)
    local allDirections = { n, ne, e, se, s, sw, w, nw}

    local checks = {
        function(p, g, prop)
            if not day23.exists(g, point.sum2(p, ne)) and not day23.exists(g, point.sum2(p, n)) and not day23.exists(g, point.sum2(p, nw)) then
                local np = point.sum2(p, n)
                day23.add(prop, np, p)
                return true
            else
                return false
            end
        end,
        function(p, g, prop)
            if not day23.exists(g, point.sum2(p, se)) and not day23.exists(g, point.sum2(p, s)) and not day23.exists(g, point.sum2(p, sw)) then
                local sp = point.sum2(p, s)
                day23.add(prop, sp, p)
                return true
            else
                return false
            end
        end,
        function(p, g, prop)
            if not day23.exists(g, point.sum2(p, nw)) and not day23.exists(g, point.sum2(p, w)) and not day23.exists(g, point.sum2(p, sw)) then
                local wp = point.sum2(p, w)
                day23.add(prop, wp, p)
                return true
            else
                return false
            end
        end,
        function(p, g, prop)
            if not day23.exists(g, point.sum2(p, ne)) and not day23.exists(g, point.sum2(p, e)) and not day23.exists(g, point.sum2(p, se)) then
                local ep = point.sum2(p, e)
                day23.add(prop, ep, p)
                return true
            else
                return false
            end
        end
    }

    local resAt10 = 0
    for i=1,10000 do
        local newG = {}
        local prop = {}
        local countMoved = 0
        for row, cols in pairs(g) do
            for col, _ in pairs(cols) do
                local p = point.p2(col, row)

                local countNeighbours = 0
                for i=1,#allDirections do
                    if day23.exists(g, point.sum2(p, allDirections[i])) then
                        countNeighbours = countNeighbours + 1
                    end
                end

                if countNeighbours == 0 then
                    day23.add(prop, p, p)
                else
                    local moved = false
                    for c=1,#checks do
                        if checks[c](p, g, prop) then
                            moved = true
                            countMoved = countMoved + 1
                            break
                        end
                    end
                    if not moved then
                        day23.add(prop, p, p)
                    end
                end
            end
        end
        for row, cols in pairs(prop) do
            for col, pts in pairs(cols) do
                if #pts == 1 then
                    local np = pts[1]
                    day23.set(newG, point.p2(col, row), g[np.y][np.x])
                else
                    for pi=1,#pts do
                        local np = pts[pi]
                        day23.set(newG, np, g[np.y][np.x])
                    end
                end
            end
        end
        g = newG

        minp = point.maxint2()
        maxp = point.minint2()
        for row, cols in pairs(g) do
            for col, pts in pairs(cols) do
                local np = point.p2(col, row)
                minp = point.min2(np, minp)
                maxp = point.max2(np, maxp)
            end
        end

        local emptySpots = day23.printG(newG, minp, maxp)
        table.insert(checks, table.remove(checks, 1))
        if i == 10 then
            resAt10 = emptySpots
        end
        if countMoved == 0 then
            return g, minp, maxp, resAt10, i
        end
    end
    return g, minp, maxp, resAt10, 0
end

function day23.printG(g, mip, mxp)
    local doPrint = true
    if day23.mute ~= nil then
        doPrint = false
    end

    local countEmpty = 0
    local countTotal = 0
    local row = mip.y
    while row <= mxp.y do
        local vrow = ""
        local col = mip.x
        while col <= mxp.x do
            if g[row] ~= nil and g[row][col] ~= nil then
                vrow = vrow .. g[row][col]
            else
                vrow = vrow .. "."
                countEmpty = countEmpty + 1
            end
            col = col+1
            countTotal = countTotal + 1
        end
        if doPrint then
            print(vrow)
        end
        row = row + 1
    end
    if doPrint then
        print("", countEmpty, countTotal)
    end
    return countEmpty
end

if util.is_main(arg, ...) then
    day23.mute = true
    local filename = "input/day23_input.txt"
    local g, mip, mxp = day23.parseElves(filename)
    local g, minp, maxp, resAt10, finalStep = day23.simulate(g, mip, mxp)
    print("[day 23] count empty places in area:", resAt10)
    print("[day 23] count steps until elves in formation:", finalStep)
end

return day23