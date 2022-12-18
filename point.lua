point = {}

function point.p2(x, y)
    return {x=x, y=y}
end

function point.p3(x, y, z)
    return {x=x, y=y, z=z}
end

function point.minint3()
    local mi = math.mininteger
    return point.p3(mi, mi, mi)
end

function point.maxint3()
    local mx = math.maxinteger
    return point.p3(mx, mx, mx)
end

function point.min3(pl, pr)
    return {x=math.min(pl.x, pr.x), y=math.min(pl.y, pr.y), z=math.min(pl.z, pr.z)}
end

function point.sum3(pl, pr)
    return {x=pl.x + pr.x, y=pl.y + pr.y, z=pl.z + pr.z}
end

function point.max3(pl, pr)
    return {x=math.max(pl.x, pr.x), y=math.max(pl.y, pr.y), z=math.max(pl.z, pr.z)}
end

return point