TestDay13 = {}

lu = require('luaunit')
day13 = require('day13')

function TestDay13:testSample()
    local sumIndices, _ = day13.parseCount("input/day13_sample.txt", false)
    local _, decoderKey = day13.parseCount("input/day13_sample.txt", true)
    lu.assertEquals(sumIndices, 13)
    lu.assertEquals(decoderKey, 140)
end

os.exit(lu.LuaUnit.run())