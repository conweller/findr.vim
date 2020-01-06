local M = {}

local vim = vim

local model = require('findr/model')
local startloc = 1

function M.getpath()
    return vim.api.nvim_call_function('getcwd', {}) .. '/'
end

-- TODO: Generalize
function M.getinput(prompt)
    local line = vim.api.nvim_call_function('getline', {startloc})
    local input = string.sub(line, string.len(prompt)+1, string.len(line))
    if not input or string.find(input, '/$') then
        return ''
    end
    return input
end

function M.get_filename(prompt)
    local selected = model.get_selected()
    if selected ~= nil then
        return M.getpath() .. model.get_selected()
    else
        return M.getpath() .. M.getinput(prompt)
    end
end

function M.get_selected(prompt)
    local selected = model.get_selected()
    if selected ~= nil then
        return model.get_selected()
    else
        return M.getinput(prompt)
    end
end

function M.get_dir_file_pair(prompt)
    local selected = model.get_selected()
    if selected ~= nil then
        return { M.getpath(), model.get_selected() }
    else
        if M.getinput(prompt) ~= '' then
            return { M.getpath(),  M.getinput(prompt) }
        else
            return { M.getpath(),  '' }
        end
    end
end

return M
