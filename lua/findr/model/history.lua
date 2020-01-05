local utils = require('findr/utils')
local vim = vim

local M = {}

local function valid_line(dir_file_pair)
    if utils.tablelength(dir_file_pair) == 2 then
        return vim.fn.isdirectory(dir_file_pair[1]) == 1
    end
    return false
end

function M.source()
    local history = {}
    local file = io.open(vim.api.nvim_get_var('findr_history') ,'r')
    if file then
        for line in file:lines() do
            local dir_file_pair = vim.fn.split(line, '\\t' )
            if valid_line(dir_file_pair) then
                table.insert(history, dir_file_pair)
            end
        end
        file:close()
    end
    return history
end


function M.update(history, dir_file_pair)
    if history[1] ~= dir_file_pair then
        table.insert(history, dir_file_pair)
    end
    return history
end


function M.write(history)
    local file = io.open (vim.api.nvim_get_var('findr_history') ,'a+')
    local start = math.max(utils.tablelength(history),0)
    if file then
        for _, df_pair in ipairs(utils.slice(history,start,start+100,1)) do
            file:write(df_pair[1]..'\t'..df_pair[2]..'\n')
        end
        file:close()
    end
end

return M
