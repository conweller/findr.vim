local M = {}

local model = require('findr.model')
local startloc = 1

function M.getpath()
    local line = vim.fn.getline(startloc)
    local path = string.match( line, '.*/')
    return path
end

function M.getinput()
    local line = vim.fn.getline(startloc)
    local input = string.match('/'..line, '^.+/(.+)$')
    if not input or string.find(input, '/$') then
        return ''
   end
    return input
end

function M.get_filename()
    return M.getpath() .. model.get_selected()
end

return M
