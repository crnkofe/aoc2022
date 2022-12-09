util = require('util')

day9 = {}

function day9.countTailVisited(filename, tailLength)
    local moveRegex = '(.) (%d+)'

    local visited = {}

    -- left, right is -N..+N
    -- down, up is -N..+N
    local head = { x=0, y=0 }
    local tails = {}
    for i=1,tailLength do
        tails[i] = { x=0, y=0 }
    end

    local directionVector = {
        ["U"] = function() return { x=0, y=1 }  end,
        ["D"] = function() return { x=0, y=-1 }  end,
        ["L"] = function() return { x=-1, y=0 } end,
        ["R"] = function() return { x=1, y=0 } end,
    }

    local pointSet = {
        [string.format("%d:%d", 0, 0)]=true,
    }

    local orderedPath = {}
    for line in io.lines(filename) do
        for direction, countRaw in string.gmatch(line, moveRegex) do
            local count = math.tointeger(countRaw)
            local vec = directionVector[direction]()
            for steps=1,count do
                head = { x=head.x + vec.x, y=head.y + vec.y }
                local next = { x=head.x, y=head.y }
                for ti=1,tailLength do
                    local df = { x=math.abs(next.x - tails[ti].x), y=math.abs(next.y - tails[ti].y) }
                    local newTail = { x=tails[ti].x, y=tails[ti].y }
                    if (df.x ~= 0) then
                        newTail.x = newTail.x + util.sgn(next.x - newTail.x)
                    end
                    if (df.y ~= 0) then
                        newTail.y = newTail.y + util.sgn(next.y - newTail.y)
                    end

                    if (newTail.x ~= next.x) or (newTail.y ~= next.y) then
                        tails[ti] = newTail
                    end
                    next = { x=tails[ti].x, y=tails[ti].y }

                    local key = string.format("%d:%d", tails[ti].x, tails[ti].y)
                    if (ti == tailLength) then
                        if #orderedPath == 0 then
                            table.insert(orderedPath, key)
                        elseif key ~= orderedPath[#orderedPath] then
                            table.insert(orderedPath, key)
                        end
                        pointSet[key] = true
                    end
                end
            end
        end
    end
    local countVisited = 0
    for k, v in pairs(pointSet) do
        countVisited = countVisited + 1
    end
    return countVisited
end

if util.is_main(arg, ...) then
    print("[day 9] count visited with snake of len 1:", day9.countTailVisited("input/day9_input.txt", 1))
    print("[day 9] count visited with snake of len 9:", day9.countTailVisited("input/day9_input.txt", 9))
end

return day9