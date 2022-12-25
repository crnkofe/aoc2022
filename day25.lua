util = require('util')
point = require("point")

day25 = {}

function day25.toDecimal(analog)
    local rev = string.reverse(analog)
    local powr = 1
    local num = 0
    for i=1,#rev do
        local ch = rev.sub(rev, i, i)
        if ch == "2" then
            num = num + powr * 2
        elseif ch == "1" then
            num = num + powr
        elseif ch == "0" then
            -- do nothing
        elseif ch == "-" then
            num = num - powr
        elseif ch == "=" then
            num = num - powr * 2
        end
        powr = powr * 5
    end
    return num
end

function day25.parseAnalogNumbers(filename)
    local sum = 0
    for line in io.lines(filename) do
        sum = sum + day25.toDecimal(line)
    end
    return sum
end

function day25.inverse(num, originalNum, pow, limit)
    if pow > limit and num ~= 0 then
        return nil
    end
    if math.abs(num) > 5 * math.abs(originalNum) then
        return nil
    end

    local options = {[-2]="=", [-1]="-", [0]="0", [1]="1", [2]="2"}
    if pow == 1 then
        local analogRemainder = num - (num // 5) * 5
        if analogRemainder > 2 then
            analogRemainder = num - ((num // 5) * 5 + 5)
        end

        local result = day25.inverse(num - analogRemainder, originalNum, pow*5, limit)
        if result == nil then
            return nil
        end
        return result .. options[analogRemainder]
    else
        local newPow = pow*5
        for k, s in pairs(options) do
            local newNum = num - k*pow
            if newNum == 0 then
                return s
            else
                local res = day25.inverse(newNum, originalNum, newPow, limit)
                if res ~= nil then
                    return res .. s
                end
            end
        end
        return nil
    end
end

function day25.inverse2(num, pow)
    local options = {[-2]="=", [-1]="-", [0]="0", [1]="1", [2]="2"}
    if pow == 1 then
        if options[num] ~= nil then
            return options[num]
        else
            return nil
        end
    else
        local newPow = pow // 5
        for k, s in pairs(options) do
            local newNum = num - k*pow
            -- expect to converge to new number
            if math.abs(newNum) > math.abs(num) then
                goto continue
            end
            if newNum == 0 then
                return s
            else
                local res = day25.inverse2(newNum, newPow)
                if res ~= nil then
                    return s .. res
                end
            end
            ::continue::
        end
        return nil
    end
end


if util.is_main(arg, ...) then
    local filename = "input/day25_input.txt"
    local totalSum = day25.parseAnalogNumbers(filename)
    local pow = 5
    for i=1,18 do
        pow = pow * 5
    end
    local n = totalSum
    local analog = day25.inverse2(n, pow)
    -- local inverse = day25.toDecimal(analog)
    print("[day 25] fancy number notation:", analog)
end

return day25