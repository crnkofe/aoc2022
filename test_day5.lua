TestDay5 = {}

lu = require('luaunit')
day5 = require('day5')


function TestDay5:testSample()
    local fn = "input/day5_sample.txt"
    local t = day5.parseState(fn)
    local t2 = day5.parseState(fn)

    local inOrderStacks = day5.processInstructions(t, fn, true)
    local bulkOrderStacks = day5.processInstructions(t2, fn, false)
    lu.assertEquals(day5.solution(inOrderStacks), "CMZ")
    lu.assertEquals(day5.solution(bulkOrderStacks), "MCD")
end

os.exit(lu.LuaUnit.run())