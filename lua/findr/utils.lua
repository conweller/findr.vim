M = {}

function M.tablelength(T)
    local count = 0
    for _, _ in ipairs(T) do
        count = count + 1
    end
    return count
end

function M.split(line)
    local t = {}
    for str in string.gmatch(line, "[^%s]+") do
        table.insert(t, str)
    end
    return t
end

function M.slice(tbl, first, last, step)
    local sliced = {}

    for i = first or 1, last or #tbl, step or 1 do
        sliced[#sliced+1] = tbl[i]
    end

    return sliced
end

return M
