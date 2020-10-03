local M = {}
local vim = vim
local api = require('findr/api')

local function tabline_visible()
    local tabs = vim.api.nvim_list_tabpages()
    local show_tabs = vim.api.nvim_get_option('showtabline')
    if show_tabs == 2 or (show_tabs == 1 and tabs[2] ~= nil) then
        return 1
    end
    return 0
end

function M.new_floating(filetype)
    local use_border = vim.api.nvim_get_var('findr_enable_border') == 1
    local border = vim.api.nvim_get_var('findr_border')
    local columns = vim.api.nvim_get_option('columns')
    local lines = vim.api.nvim_get_option('lines')
    local winopts = api.get_var('findr_floating_window')
    local height, width, options = nil

    if type({}) == type(winopts) and winopts['window'] ~= nil then
      options = vim.api.nvim_eval(winopts['window'])
      width = options['width']
      height = options['height']
    else
      height = math.min(lines - (4+tabline_visible()), 20)
      width = math.min(100, columns-4)
      options = {
          relative = 'editor',
          row = 1 + tabline_visible(),
          col = math.floor((columns-width) / 2),
          width = width,
          height = height,
          style = 'minimal'
      }
    end

    if use_border then
        local top = border.top[1] .. string.rep(border.top[2], width-2) .. border.top[3]
        local mid = border.middle[1] .. string.rep(border.middle[2], width-2) .. border.middle[3]
        local bot = border.bottom[1] .. string.rep(border.bottom[2], width-2) .. border.bottom[3]
        local border_buf = vim.api.nvim_create_buf(false, true)
        local lines = {top}
        for i=1,height-2,1 do
            table.insert(lines, mid)
        end
        table.insert(lines, bot)
        vim.api.nvim_open_win(border_buf, true, options)
        vim.api.nvim_buf_set_lines(border_buf, 0, -1, true, lines)
        vim.api.nvim_command('setlocal winhl=Normal:FindrBorder')
        options.row = options.row + 1
        options.height = options.height - 2
        options.col =  options.col + 2
        options.width = options.width - 4
        local buf = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_open_win(buf, true, options)
        vim.api.nvim_command('au BufWipeout <buffer> exe "silent bw! "'..border_buf)
    else
        local buf = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_open_win(buf, true, options)
    end


    vim.api.nvim_command('file findr')
    vim.api.nvim_command('set ft='..filetype)
    vim.api.nvim_command('setlocal winhighlight=FoldColumn:Normal,Normal:FindrNormal')
end

function M.new_split(filetype)
    api.command('botright 15new')
    api.command('file findr')
    api.command('set ft='..filetype)
    if not api.vim8 then
        api.command('setlocal winhighlight=FoldColumn:Normal,Normal:FindrNormal')
    end
end

return M
