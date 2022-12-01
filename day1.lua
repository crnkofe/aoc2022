util = require('util')

day1 = { }

function day1.calculate_elf_calories(filename)
    local elf_calories = {}
    most_elf_held_calories = 0
    last_elf_held_calories = 0
    i = 0
    for line in io.lines(filename) do
        if line ~= "" then
            last_elf_held_calories = last_elf_held_calories + math.tointeger(line)
        else
            most_elf_held_calories = math.max(most_elf_held_calories, last_elf_held_calories)

            table.insert(elf_calories,last_elf_held_calories)
            i = i + 1
            last_elf_held_calories = 0
        end
    end

    if last_elf_held_calories > 0 then
        table.insert(elf_calories, last_elf_held_calories)
    end

    -- sort ascending largest calory holder first
    table.sort(elf_calories, function(a,b) return a > b end)
    return elf_calories
end

function day1.calculate_top_k(lst, n)
    sum_k = 0
    for i=1,n do
        sum_k = sum_k + lst[i]
    end
    return sum_k
end

if util.is_main(arg, ...) then
    local elf_calories = day1.calculate_elf_calories("input/day1_input.txt")
    print("[day 1] most calories held: ", elf_calories[1])
    print("[day 2] top 3 calories held:", day1.calculate_top_k(elf_calories, 3))
end

return day1
