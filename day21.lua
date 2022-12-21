util = require('util')
bn = require("bn")

day21 = {}

function day21.parseMonkeys(filename)
    local monkeys = {}
    for line in io.lines(filename) do
        --root: pppw + sjmn
        --dbpl: 5
        --cczh: sllz + lgvd
        for monkey, ml, op, mr in line:gmatch("(%a+): (%a+) (.) (%a+)") do
            table.insert(monkeys, { monkey=monkey, ml=ml, op=op, mr=mr })
        end

        for monkey, c in line:gmatch("(%a+): (%d+)") do
            table.insert(monkeys, { monkey=monkey, c=math.tointeger(c) })
        end
    end
    return monkeys
end

function day21.parseFile(filename)
    local monkeys = day21.parseMonkeys(filename)
    local comps = {}
    while comps["root"] == nil do
        for mi=#monkeys,1,-1 do
            local m = monkeys[mi]
            if m.c ~= nil then
                comps[m.monkey] = m.c
                table.remove(monkeys, mi)
            elseif comps[m.ml] ~= nil and comps[m.mr] ~= nil then
                if m.op == "*" then
                    comps[m.monkey] = comps[m.ml] * comps[m.mr]
                elseif m.op == "/" then
                    comps[m.monkey] = comps[m.ml] // comps[m.mr]
                elseif m.op == "+" then
                    comps[m.monkey] = comps[m.ml] + comps[m.mr]
                elseif m.op == "-" then
                    comps[m.monkey] = comps[m.ml] - comps[m.mr]
                end
                table.remove(monkeys, mi)
            end
        end
    end
    return comps["root"]
end

function day21.parseMonkeys2(filename)
    local monkeys = day21.parseMonkeys(filename)
    for mi=1,#monkeys do
        if monkeys[mi].monkey == "root" then
            monkeys[mi].op = "="
        end
    end
    return monkeys
end

function day21.setHumanInput(monkeys, num)
    for mi=1,#monkeys do
        if monkeys[mi].monkey == "humn" then
            monkeys[mi].c = num
        end
    end
end

function day21.parseFile2(filename, num)
    local monkeys = day21.parseMonkeys2(filename)
    local comps = {}
    local i = num
    local done = false
    while not done do
        day21.setHumanInput(monkeys, i)

        comps = {}
        local processedMonkeys = {}
        while comps["root"] == nil do
            for mi=#monkeys,1,-1 do
                if processedMonkeys[mi] ~= nil then
                    goto continue
                end
                local m = monkeys[mi]
                if m.c ~= nil then
                    comps[m.monkey] = bn(m.c)
                    processedMonkeys[mi] = true
                elseif comps[m.ml] ~= nil and comps[m.mr] ~= nil then
                    if m.op == "*" then
                        comps[m.monkey] = bn(comps[m.ml]) * bn(comps[m.mr])
                    elseif m.op == "/" then
                        comps[m.monkey] = bn(comps[m.ml]) // bn(comps[m.mr])
                    elseif m.op == "+" then
                        comps[m.monkey] = bn(comps[m.ml]) + bn(comps[m.mr])
                    elseif m.op == "-" then
                        comps[m.monkey] = bn(comps[m.ml]) - bn(comps[m.mr])
                    elseif m.op == "=" then
                        if comps[m.ml] < comps[m.mr] then
                            done = true
                        elseif comps[m.ml] == comps[m.mr] then
                            done = true
                        end
                        comps[m.monkey] = bn(comps[m.ml]) == bn(comps[m.mr])
                    end
                    processedMonkeys[mi] = true
                end
                ::continue::
            end
        end
        i = i + bn(1)
    end

    return comps["root"]
end


if util.is_main(arg, ...) then
    local filename = "input/day21_input.txt"
    local sumOf = day21.parseFile(filename)
    print("[day 21] root says:", sumOf)
    print("[day 21] no-automation done for part 2: 3352886133831 ; is solution?", day21.parseFile2(filename, bn(3352886133831)))
end

return day21