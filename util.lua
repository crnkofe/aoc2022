util = {}

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

function util.sgn(n)
    if n > 0 then
        return 1
    elseif n < 0 then
        return -1
    else
        return 0
    end

end

return util