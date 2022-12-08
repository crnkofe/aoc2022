TestDay8 = {}

lu = require('luaunit')
day8 = require('day8')

function TestDay8:testSample()
    local countVisibleTrees, maxScenicScore = day8.countVisibleTrees("input/day8_sample.txt")
    lu.assertEquals(countVisibleTrees, 21)
    lu.assertEquals(maxScenicScore, 8)
end

os.exit(lu.LuaUnit.run())