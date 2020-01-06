local M = {}
local vim = vim

local function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a '..directory..'')
    for filename in pfile:lines() do
        i = i + 1
        if vim.api.nvim_call_function('isdirectory', {filename}) == 1 then
            t[i] = filename .. '/'
        else
            t[i] = filename
        end
    end
    pfile:close()
    table.sort(t, function(a,b)
        if a == './' then
            return true
        elseif b == './' then
            return false
        elseif a == '../' then
            return true
        elseif b == '../' then
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

function M.sink(selected)
    return 'edit '.. selected
end

function M.prompt()
    local cwd = vim.api.nvim_call_function('getcwd', {})
    cwd = vim.api.nvim_call_function('pathshorten', {cwd})
    cwd = cwd == '/' and '/' or cwd .. '/'
    return cwd
end

M.filetype = 'findr-files'
M.history = true

return M
