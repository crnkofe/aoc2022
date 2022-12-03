TestDay3 = {}

lu = require('luaunit')
day3 = require('day3')


function TestDay3:testSample()
    lu.assertEquals(157, day3.countPriorities("input/day3_sample.txt"))
    lu.assertEquals(70, day3.countTriplePriorities("input/day3_sample.txt"))
end

os.exit(lu.LuaUnit.run())