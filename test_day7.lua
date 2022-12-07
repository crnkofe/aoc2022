TestDay7 = {}

lu = require('luaunit')
day7 = require('day7')

function TestDay7:testSample()
    local sumBelowThreshold, minDirToFreeSize = day7.processFile("input/day7_sample.txt")
    lu.assertEquals(sumBelowThreshold, 95437)
    lu.assertEquals(minDirToFreeSize, 24933642)
end

os.exit(lu.LuaUnit.run())