TestDay6 = {}

lu = require('luaunit')
day6 = require('day6')


function TestDay6:testSample()
    local samples = {
        "mjqjpqmgbljsphdztnvjfqwrcgsmlb",
        "bvwbjplbgvbhsrlpgdmjqwftvncz",
        "nppdvjthqldpwncqszvftbrmjlhg",
        "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg",
        "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw",
    }
    lu.assertEquals(day6.findMarker(samples[1], 4), 7)
    lu.assertEquals(day6.findMarker(samples[2], 4), 5)
    lu.assertEquals(day6.findMarker(samples[3], 4), 6)
    lu.assertEquals(day6.findMarker(samples[4], 4), 10)
    lu.assertEquals(day6.findMarker(samples[5], 4), 11)

    lu.assertEquals(day6.findMarker(samples[1], 14), 19)
    lu.assertEquals(day6.findMarker(samples[2], 14), 23)
    lu.assertEquals(day6.findMarker(samples[3], 14), 23)
    lu.assertEquals(day6.findMarker(samples[4], 14), 29)
    lu.assertEquals(day6.findMarker(samples[5], 14), 26)
end

os.exit(lu.LuaUnit.run())