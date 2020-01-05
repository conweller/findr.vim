local M = {}

local vim = vim

local model = require('findr/model')
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

function M.get_dir_file_pair()
    local selected = model.get_selected()
    if selected ~= nil then
        return { M.getpath(), model.get_selected() }
    else
        if M.getinput() ~= '' then
            return { M.getpath(),  M.getinput() }
        else
            return { M.getpath(),  '' }
        end
    end
end

return M
