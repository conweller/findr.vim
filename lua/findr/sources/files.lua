local M = {}
local vim = vim

local function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a '..directory..'')
    for filename in pfile:lines() do
        i = i + 1
        if vim.fn.isdirectory(filename) == 1 then
            t[i] = filename .. '/'
        else
            t[i] = filename
        end
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

function M.sink()
-- TODO
end

M.actions = {
    parent_dir = 0, -- TODO
}

M.filetype = 'findr'

return M
