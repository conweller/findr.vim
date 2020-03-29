local M = {}
local vim = vim
local api = require('findr/api')

local function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a '..directory..'')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = {}
        if api.call_function('isdirectory', {filename}) == 1 then
            t[i]['display'] = filename .. '/'
        else
            t[i]['display'] = filename
        end
        t[i]['value'] = filename
    end
    pfile:close()
    table.sort(t, function(a,b)
        a = a['display']
        b = b['display']
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

function M.sink(selected, editcmd)
    editcmd = editcmd or 'edit'
    return editcmd..' '.. selected
end

function M.prompt()
    local cwd = api.call_function('getcwd', {})
    if api.get_var('findr_shorten_path') == 2 then
        cwd = api.call_function('pathshorten', {cwd})
    elseif api.get_var('findr_shorten_path') == 1  and api.call_function('winwidth', {'$'}) < (string.len(cwd) + 10) then
        cwd = api.call_function('pathshorten', {cwd})
    end
    cwd = cwd == '/' and '/' or cwd .. '/'
    return cwd
end

M.filetype = 'findr-files'
M.history = true
if api.vim8 then
    M.history = false
end

return M
