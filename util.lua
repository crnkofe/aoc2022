util = {}

-- upsert inserts a value into subtable of table t[key1][key2][key3]...[keyN] = value
-- if any key is none it creates an empty table there
function util.upsert(t, keys, value)
    local currentTable = t
    for i=1,#keys do
        local key = keys[i]
        if i == #keys then
            currentTable[keys[#keys]] = value
        else
            local newTable = {}
            if currentTable[key] == nil then
                currentTable[key] = newTable
            else
                newTable = currentTable[key]
            end
            currentTable = newTable
        end
    end
end

-- check if something exists at t[key1][key2]...[keyN]
function util.contains(t, keys)
    local currentTable = t
    for i=1,#keys do
        local key = keys[i]
        if currentTable[key] == nil then
            return false
        else
            currentTable = currentTable[key]
        end
    end
    return true
end

function util.is_main(_arg, ...)
    local n_arg = _arg and #_arg or 0;
    if n_arg == select("#", ...) then
        for i=1,n_arg do
            if _arg[i] ~= select(i, ...) then
                print(_arg[i], "does not match", (select(i, ...)))
                return false;
            end
        end
        return true;
    end
    return false;
end

function util.pprint(t)
    print(util.pprints(t))
end

function util.pprints(t)
    if type(t) == "nil" then
        return "null"
    elseif type(t) == "boolean" then
        if t then
            return "true"
        else
            return "false"
        end
    elseif type(t) == "number" then
        return string.format("%d", t)
    elseif type(t) == "string" then
        return string.format("\"%s\"", t)
    elseif type(t) == "table" then
        -- can be either array or map

        -- if all k,v are the same then treat this as array
        local allSame = true
        for k, v in pairs(t) do
            if k ~= v then
                allSame = false
            end
        end

        if allSame then
            local line = ""
            for i=1,#t do
                if i > 1 then
                    line = line .. ","
                end
                line = line .. util.pprints(t[i])
            end
            return string.format("[%s]", line)
        else
            local line = ""
            for k, v in pairs(t) do
                if line ~= "" then
                    line = line .. ","
                end
                line  = line .. util.pprints(k) .. ":" .. util.pprints(v)
            end
            return string.format("{%s}", line)
        end
    end
end

function util.sgn(n)
    if n > 0 then
        return 1
    elseif n < 0 then
        return -1
    else
        return 0
    end

end

function util.slice (tbl, s, e)
    local pos, new = 1, {}

    for i = s, e do
        new[pos] = tbl[i]
        pos = pos + 1
    end

    return new
end

return util