util = require('util')

day7 = { }

function day7.printPath(p)
    local path = ""
    for idx=2,#p do
        path = path .. "/" .. p[idx]
    end
    print(path)
end

function day7.processFile(filename)
    local cdRegex = '[$] cd (.+)'
    local dirRegex = 'dir (.+)'
    local lsRegex = '[$] ls'
    local fileInfoRegex = '(%d+) (.*)'

    -- dirSizes is a map from "directory" to dir size
    local dirSizes = {}

    local currentDir = {}
    for line in io.lines(filename) do
        local ls = ""
        for cmd in string.gmatch(line, lsRegex) do
            ls = cmd
        end
        -- just skip ls lines
        if ls ~= "" then
            goto continue
        end

        local cdDir = ""
        for cmd in string.gmatch(line, cdRegex) do
            cdDir = cmd
        end
        if cdDir ~= "" then
            if cdDir == ".." then
                table.remove(currentDir, #currentDir)
            else
                table.insert(currentDir, cdDir)
            end
            goto continue
        end

        local dir = ""
        for subdir in string.gmatch(line, dirRegex) do
            dir = subdir
        end
        if dir ~= "" then
            goto continue
        end

        for size, dirFilename in string.gmatch(line, fileInfoRegex) do
            -- add file size to all parent directories
            -- at the end iterate over all directories and fi
            local path = ""

            if dirSizes["/"] == nil then
                dirSizes["/"] = size
            else
                dirSizes["/"] = dirSizes["/"] + math.tointeger(size)
            end
            for idx=2,#currentDir do
                path = path .. "/" .. currentDir[idx]
                if dirSizes[path] == nil then
                    dirSizes[path] = math.tointeger(size)
                else
                    dirSizes[path] = dirSizes[path] + math.tointeger(size)
                end
            end
        end

        ::continue::
    end

    local sumBelowThreshold = 0
    local threshold = 100000
    for path, size in pairs(dirSizes) do
        if (size <= threshold) then
            sumBelowThreshold = sumBelowThreshold + size
        end
    end

    -- part 2
    -- find total size
    -- find difference to 30000000 which is minimum required space
    -- find directory size that's closest to this difference
    local totalSize = dirSizes["/"]
    local discCapacity = 70000000
    local unusedSpace = discCapacity - totalSize
    -- trivial solution is to just delete everything
    local currentMinimal = totalSize
    for path, size in pairs(dirSizes) do
        if ((unusedSpace + size) >= 30000000) and (size < currentMinimal) then
            currentMinimal = size
        end
    end
    return sumBelowThreshold, currentMinimal
end

if util.is_main(arg, ...) then
    local sumBelowThreshold, minDirToFreeSize = day7.processFile("input/day7_input.txt")
    print("[day 7] sum dirs of size belo 1e5:", sumBelowThreshold)
    print("[day 7] min dir to free up space:", minDirToFreeSize)
end

return day7