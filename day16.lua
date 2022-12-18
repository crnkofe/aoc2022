util = require('util')

day16 = {
    g={},
    e={}
}

function day16.parseFile(filename)
    local g, e = {}, {}
    for line in io.lines(filename) do
        for node, flow, neighbours in line:gmatch("Valve ([a-zA-Z]+) has flow rate=(%d+); tunnels lead to valves (.+)") do
            g[node] = math.tointeger(flow)

            local neighbourLst = {}
            for n in neighbours:gmatch("([^, ]+)") do
                table.insert(neighbourLst, n)
            end
            e[node] = neighbourLst
        end
        for node, flow, neighbours in line:gmatch("Valve ([a-zA-Z]+) has flow rate=(%d+); tunnel leads to valve (.+)") do
            g[node] = math.tointeger(flow)

            local neighbourLst = {}
            for n in neighbours:gmatch("([^, ]+)") do
                table.insert(neighbourLst, n)
            end
            e[node] = neighbourLst
        end
    end
    day16.g = g
    day16.e = e
    return g, e
end

function day16.pprint(arr)
    local line = ""
    local keys = {}
    local reversNode = {}
    for node, openAt in pairs(arr) do
        reversNode[openAt] = node
        table.insert(keys, openAt)
    end


    table.sort(keys)
    for ik=1,#keys do
        local node = reversNode[keys[ik]]
        line = line .. node .. ":" .. string.format("%d", arr[node]) .. " "
    end
    print(line)
end

function day16.copy(arr)
    local copy ={}
    for i,v in pairs(arr) do
        copy[i] = v
    end
    return copy
end

function day16.dijkstra(nodeZero)
    local dist, prev, q = {}, {}, {}
    for n,_ in pairs(day16.g) do
        dist[n] = math.maxinteger
        prev[n] = nil
        table.insert(q, n)
    end
    dist[nodeZero] = 0
    while #q > 0 do
        local ui = 1
        for qi=1,#q do
            if dist[q[qi]] < dist[q[ui]] then
                ui = qi
            end
        end
        local u = table.remove(q, ui)
        for _, v in pairs(day16.e[u]) do
            local qContainsV = false
            for i=1,#q do
                if q[i] == v then
                    qContainsV = true
                    break
                end
            end
            if qContainsV then
                local alt = dist[u] + 1
                if alt < dist[v] then
                    dist[v] = alt
                    prev[v] = u
                end
            end
        end
    end
    return dist, prev
end

function day16.maxFlow()
    local dists = {}
    local ctNodes = 0
    for n,_ in pairs(day16.g) do
        ctNodes = ctNodes + 1
        local dist, prev = day16.dijkstra(n)
        if dists[n] == nil then
            dists[n] = {}
        end
        for key, dist in pairs(dist) do
            if key ~= n then
                if dists[key] == nil then
                    dists[key] = {}
                end
                dists[key][n] = dist
                dists[n][key] = dist
            end
        end
    end
    --print("*********************")
    --print("dijkstra", ctNodes, util.pprints(dists))
    --local gc = {}
    --for key, value in pairs(day16.g) do
    --    if value > 0 then
    --        gc[key] = value
    --    end
    --end
    --print("graph", util.pprints(gc))
    --print("*********************")

    day16.dists = dists
    local maxFlow = 0

    local node = "AA"
    local remainingNodes = {}
    for nodeName,flow in pairs(day16.g) do
        if nodeName ~= node and flow > 0 then
            table.insert(remainingNodes, nodeName)
        end
    end

    local remainingTime = 30
    day16.visited = { ["AA"]=1 }
    day16.countVisits = 0
    local totalFlow, path = day16.dfsDists2("AA", 0, remainingTime, { ["AA"]=1 } )
    return totalFlow
end

function day16.dfsDists2(node, cost, remainingTime)
    day16.countVisits = day16.countVisits + 1
    if remainingTime <= 1 then
        return cost, { node }
    end

    local maxFlow = 0
    local nnPath = {}
    local anyVisited = false
    for nn, distance in pairs(day16.dists[node]) do
        if day16.g[nn] == 0 or day16.g[nn] == nil then
            goto continue
        end

        if remainingTime - (distance + 1) < 1 then
            -- can't build anything that would take more than 30 mins
            goto continue
        end

        if day16.visited[nn] == nil then
            local sumFlows = 0
            for key, _ in pairs(day16.visited) do
                if day16.visited[key] ~= nil then
                    sumFlows = sumFlows + day16.g[key]
                end
            end

            day16.visited[nn] = remainingTime
            anyVisited = true

            nnFlow, path = day16.dfsDists2(nn, cost + sumFlows * (distance + 1), remainingTime - (distance + 1))
            if nnFlow > maxFlow then
                maxFlow = nnFlow
                nnPath = path
            end
            day16.visited[nn] = nil
        end

        ::continue::
    end

    if not anyVisited then
        local sumFlows = 0
        for key, _ in pairs(day16.visited) do
            if day16.visited[key] ~= nil then
                sumFlows = sumFlows + day16.g[key]
            end
        end
        return cost + sumFlows * remainingTime,  { { n = node, s = 0 } }
    else
        return maxFlow, { { n = node, s = remainingTime }, table.unpack(nnPath) }
    end
end

-- for part 2 generate all subsets of nodes in graph (2^n of them)
-- for each subset take negative and calculate max flow on one and the other and sum it up for 24 mins
-- find max of every such calculation - this should be the result
function day16.partitionAndConquer()
    local lenG = 0
    local keys = {}
    for key, val in pairs(day16.g) do
        if val > 0 then
            lenG = lenG + 1
            if key ~= "AA" then
                table.insert(keys, key)
            end
        else
            day16.g[key] = nil
        end
    end

    local originalG = day16.g
    local remainingTime = 26

    local maxCombinedForcesFlow = 0
    for i=1,((2^lenG) // 2) do
        local mine, olifants = { ["AA"]=0 }, { ["AA"]=0 }
        local di = i
        for ki=1,#keys do
            if di % 2 == 0 then
                mine[keys[ki]] = originalG[keys[ki]]
            else
                olifants[keys[ki]] = originalG[keys[ki]]
            end
            di = di // 2
        end


        day16.g = mine
        day16.visited = { ["AA"]=1 }
        day16.countVisits = 0
        local maxMineFlow, _ = day16.dfsDists2("AA", 0, remainingTime, { ["AA"]=1 } )

        day16.g = olifants
        day16.visited = { ["AA"]=1 }
        day16.countVisits = 0
        local maxOlifantsFlow, _ = day16.dfsDists2("AA", 0, remainingTime, { ["AA"]=1 } )

        maxCombinedForcesFlow = math.max(maxCombinedForcesFlow, maxMineFlow + maxOlifantsFlow)

    end
    return maxCombinedForcesFlow
end


if util.is_main(arg, ...) then
    day16.parseFile("input/day16_input.txt")
    local maxFlow = day16.maxFlow()
    print("[day 16] max flow:", maxFlow)
    local maxCombined = day16.partitionAndConquer()
    print("[day 16] max combined forces flow:", maxCombined)
end

return day16