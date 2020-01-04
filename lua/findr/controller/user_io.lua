local M = {}

local model = require('findr.model')
local startloc = 1

function M.getpath()
    return vim.fn.getcwd() .. '/'
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
    local selected = model.get_selected()
    if selected ~= nil then
        return M.getpath() .. model.get_selected()
    else
        return M.getpath() .. M.getinput()
    end
end

return M
