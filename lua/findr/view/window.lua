local M = {}
local vim = vim

local function tabline_visible()
    local tabs = vim.api.nvim_list_tabpages()
    if tabs[2] ~= nil then
        return 1
    end
    return 0
end

function M.new_float()

    local columns = vim.api.nvim_get_option('columns')
    local lines = vim.api.nvim_get_option('lines')

    local height = lines - (4+tabline_visible())
    local width = math.min(80, columns-4)
    local horizontal = math.floor((columns-width) / 2)
    local vertical = 1 + tabline_visible()

    local options = {
        relative = 'editor',
        row = vertical,
        col = horizontal,
        width = width,
        height = height,
        style = 'minimal'
    }
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_open_win(buf, true, options)
    vim.api.nvim_command('file findr')
    vim.api.nvim_command('set ft=findr')
    vim.api.nvim_command('setlocal winhighlight=FoldColumn:Normal,Normal:FindrNormal')
end

function M.new_split()
    vim.api.nvim_command('botright 10new')
    vim.api.nvim_command('file findr')
    vim.api.nvim_command('set ft=findr')
    vim.api.nvim_command('setlocal winhighlight=FoldColumn:Normal,Normal:FindrNormal')
end

return M
