util = require('util')
point = require('point')

day18 = {}

function day18.parseFile(filename)
    local voxelMap = {}
    local totalArea = 0
    local minp, maxp = point.maxint3(), point.minint3()
    local possibleNeighbours = { {x=1, y=0, z=0}, {x=-1, y=0, z=0}, {x=0, y=1, z=0}, {x=0, y=-1, z=0}, {x=0, y=0, z=1}, {x=0, y=0, z=-1} }
    for line in io.lines(filename) do
        for rx, ry, rz in line:gmatch("(%d+),(%d+),(%d+)") do
            local p3 = { x=math.tointeger(rx), y=math.tointeger(ry), z=math.tointeger(rz) }
            for _, pn in pairs(possibleNeighbours) do
                local np = point.sum3(p3, pn)
                if util.contains(voxelMap, {np.x, np.y, np.z}) then
                    totalArea = totalArea - 1
                else
                    totalArea = totalArea + 1
                end
            end
            minp = point.min3(minp, p3)
            maxp = point.max3(maxp, p3)
            util.upsert(voxelMap, {p3.x, p3.y, p3.z}, 1)
        end
    end

    -- idea for part 2:
    -- extend boundary by 1 in both min, max directions
    -- 3d flood fill from any starting pixel and count times we hit voxelMap (outer surface area)
    local boundMin = point.sum3(minp, point.p3(-1, -1, -1))
    local boundMax = point.sum3(maxp, point.p3(1, 1, 1))
    local processed = {}
    local counts = {}
    local toBeProcessed = { boundMin }
    local actualSurface = 0
    while #toBeProcessed > 0 do
        local p = table.remove(toBeProcessed)
        -- this piece of code can generate multiple same neighbours so we need to filter them out
        if not util.contains(processed, {p.x, p.y, p.z}) then
            if util.contains(voxelMap, {p.x, p.y, p.z}) then
                if not util.contains(counts, {p.x, p.y, p.z}) then
                    util.upsert(counts, {p.x, p.y, p.z}, 1)
                else
                    util.upsert(counts, {p.x, p.y, p.z}, counts[p.x][p.y][p.z] + 1)
                end
                actualSurface = actualSurface + 1
            else
                for _, pn in pairs(possibleNeighbours) do
                    -- neighbouring point
                    local np = point.sum3(p, pn)
                    -- check if in bounds
                    if np.x < boundMin.x or np.y < boundMin.y or np.z < boundMin.z then
                        goto continue
                    end
                    if np.x > boundMax.x or np.y > boundMax.y or np.z > boundMax.z then
                        goto continue
                    end
                    -- check if not already processed
                    if util.contains(processed, {np.x, np.y, np.z}) then
                        goto continue
                    end
                    table.insert(toBeProcessed, np)
                    ::continue::
                end
                util.upsert(processed, {p.x, p.y, p.z}, 1)
            end
        end
    end
    return totalArea, actualSurface
end

if util.is_main(arg, ...) then
    local moves, actualSurface = day18.parseFile("input/day18_input.txt")
    print("[day 18] voxel surface with pockets:", moves)
    print("[day 18] voxel surface without pockets:", actualSurface)
end

return day17