local utils = require('findr/utils')
local vim = vim

local M = {}

local index = 0
local jump_point = -1
local history = {}
local max_len = vim.api.nvim_get_var('findr_max_hist')
local len = 0

local function valid_line(dir_file_pair)
    if utils.tablelength(dir_file_pair) >= 1 then
        return vim.fn.isdirectory(dir_file_pair[1]) == 1
    end
    return false
end

function M.reset(cwd)
    max_len = vim.api.nvim_get_var('findr_max_hist')
    index = 0
    jump_point = {cwd, ''}
end

function M.get_jumpoint()
    return index, jump_point
end

function M.set_jumpoint(idx, item)
    index = idx
    jump_point = item
end

function M.source()
    history = {}
    len = 0
    local file = io.open(vim.api.nvim_get_var('findr_history') ,'r')
    if file then
        for line in file:lines() do
            local dir_file_pair = vim.fn.split(line, '\\t' )
            if valid_line(dir_file_pair) then
                local dir = dir_file_pair[1]
                local input = dir_file_pair[2]
                if input == nil then
                    input = ''
                elseif vim.fn.isdirectory(dir..input) == 1 then
                    dir = dir..input
                    input = ''
                end
                dir_file_pair = {dir, input}
                table.insert(history, dir_file_pair)
                len = len + 1
            end
        end
        file:close()
    end
end
function M.update(dir_file_pair)
    if len > 0 then
        local same_dir = history[len][1] == dir_file_pair[1]
        local same_file = history[len][2] == dir_file_pair[2]
        TEST = not (same_dir and same_file)
        if not (same_dir and same_file) then
            table.insert(history, dir_file_pair)
            len = len + 1
        end
    else
        table.insert(history, dir_file_pair)
        len = len + 1
    end
end


function M.write()
    local file = io.open (vim.api.nvim_get_var('findr_history') ,'w')
    local start = math.max(len-max_len ,0)
    local end_pos = math.min(len, start+max_len)
    if file then
        for _, df_pair in ipairs(utils.slice(history, start, end_pos, 1)) do
            file:write(df_pair[1]..'\t'..df_pair[2]..'\n')
        end
        file:close()
    end
end

function M.get()
    if index == 0 then
        return jump_point[1], jump_point[2]
    else
        return history[index][1], history[index][2]
    end
end

function M.next()
    if index > 0 then
        index = (index + 1) % (len + 1)
    else
        index = 0
    end
end

function M.prev()
    if index ~= 1 then
        index = (index - 1) % (len + 1)
    else
        index = 1
    end
end

return M
