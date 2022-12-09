TestDay9 = {}

lu = require('luaunit')
day9 = require('day9')

function TestDay9:testSample()
    lu.assertEquals(day9.countTailVisited("input/day9_sample.txt", 1), 13)
    lu.assertEquals(day9.countTailVisited("input/day9_sample.txt", 9), 1)
end

os.exit(lu.LuaUnit.run())