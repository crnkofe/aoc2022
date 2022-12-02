TestDay2 = {}

lu = require('luaunit')
day1 = require('day2')

function TestDay2:testSample()
    local strategy = {}
    strategy["X"] = 1
    strategy["Y"] = 2
    strategy["Z"] = 3
    local moves = { { p1="Y", p2="A" }, { p1="X", p2="B" },  { p1="Z", p2="C" } }
    lu.assertEquals(day2.scorePlayer1(strategy, moves), player1Points)
    lu.assertEquals(day2.scoreStrategicPlayer1(strategy, moves), 12)
end

os.exit(lu.LuaUnit.run())