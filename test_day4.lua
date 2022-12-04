TestDay4 = {}

lu = require('luaunit')
day4 = require('day4')


function TestDay4:testSample()
    lu.assertEquals(2, day4.countIncludedIntervals("input/day4_sample.txt"))
    lu.assertEquals(4, day4.countPartiallyIntersectedRanges("input/day4_sample.txt"))
end

os.exit(lu.LuaUnit.run())