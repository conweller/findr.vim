local M = {}

local function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -ap '..directory..'')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    table.sort(t, function(a,b)
        if a == '.' then
            return true
        elseif a ~= '.' and b == '..' then
            return false
        elseif string.len(a) == string.len(b) then
            return a < b
        else
            return string.len(a) < string.len(b)
        end
    end)
    return t
end

function M.table()
    return scandir('.')
end

return M
