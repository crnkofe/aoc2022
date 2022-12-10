util = require('util')

day10 = {}

function day10.loadProgram(filename, limit)
    local noop = "noop"
    local addx = "(addx) ([-]*%d+)"
    local program = {}
    for line in io.lines(filename) do
        if line == noop then
            table.insert(program, { name="noop" })
            goto continue
        end

        for cmd, val1 in string.gmatch(line, addx) do
            table.insert(program, { name=cmd, vals={ math.tointeger(val1) }, cycle=0 })
            goto continue
        end

        ::continue::
    end
    return program
end

function day10.executeProgram(program, limit)
    local registers = {
        x=1
    }
    local state={
        pc=1
    }

    local noop = "noop"
    local addx = "addx"

    -- part 1
    local signalStrength = 0
    -- part 2
    local stdout = ""

    -- ic stands for instruction cycle
    for ic=1,limit do
        if (ic - 20) >= 0 then
            if (((ic - 20) % 40) == 0) then
                signalStrength = signalStrength + registers.x * ic
            end
        end

        local xposmod = (ic - 1) % 40
        if (xposmod == registers.x - 1) or (xposmod == registers.x) or (xposmod == registers.x + 1) then
            stdout = stdout .. "#"
        else
            stdout = stdout .. "."
        end

        if ic > 1 and (xposmod == 39) then
            stdout = stdout .. "\n"
        end

        local cmd = program[state.pc]
        if cmd.name == noop then
            state.pc = state.pc + 1
        elseif cmd.name == addx then
            if cmd.cycle == 0 then
                cmd.cycle = cmd.cycle + 1
            else
                cmd.cycle = 0
                registers.x = registers.x + cmd.vals[1]
                state.pc = state.pc + 1
            end
        end

        if state.pc > #program then
            break
        end
    end
    return signalStrength, stdout
end

function day10.printProgram(program)
    print("*START*")
    for idx, p in pairs(program) do
        if p.name == "noop" then
            print(p.name)
        elseif p.name == "addx" then
            print(p.name, p.vals[1])
        end
    end
    print("*END*")
end

if util.is_main(arg, ...) then
    local program = day10.loadProgram("input/day10_input.txt")
    local signalStrength, stdout = day10.executeProgram(program, 240)
    print("[day 10] signal strength:", signalStrength)
    print(string.format("[day 10] crt stdout\n%s", stdout))
end

return day10