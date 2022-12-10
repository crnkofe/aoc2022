TestDay10 = {}

lu = require('luaunit')
day10 = require('day10')

function TestDay10:testSample()
    local program = day10.loadProgram("input/day10_input.txt")
    local signalStrength, stdout = day10.executeProgram(program, 220)
    lu.assertEquals(signalStrength, 14420)
end

os.exit(lu.LuaUnit.run())