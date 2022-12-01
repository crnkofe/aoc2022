TestDay1 = {}

lu = require('luaunit')
day1 = require('day1')

function TestDay1:testSample()
    local calories = day1.calculate_elf_calories("input/day1_sample.txt")
    lu.assertEquals(calories[1], 24000)
    lu.assertEquals(day1.calculate_top_k(calories, 3), 45000)
end

os.exit(lu.LuaUnit.run())