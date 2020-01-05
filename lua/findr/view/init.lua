local M = {}

local vim = vim
local utils = require('findr/utils')
local window = require('findr/view.window')

local INPUT_LOC = 1

function M.init()
    local use_floating = vim.api.nvim_get_var('findr_floating_window')==1
    if use_floating then
        window.new_floating()
    else
        window.new_split()
    end
end

function M.setinput(cwd, input)
    local line = cwd
    line = line == '/' and '/' or line .. '/'
    line = line .. input
    vim.fn.setline(INPUT_LOC, line)
end

local function draw_candidates(display_table, winheight)
    local display = utils.slice(display_table, INPUT_LOC , winheight-1, 1)
    vim.fn.nvim_buf_set_lines(0,INPUT_LOC, -1, true, display)
end

local function add_highlights(input, selected_loc)
    local highlight_matches = vim.api.nvim_get_var('findr_highlight_matches') == 1
    vim.fn.clearmatches()
    vim.fn.matchadd('FindrSelected', '\\%' .. selected_loc .. 'l.*')
    if highlight_matches then
        for _, str in ipairs(utils.split(input)) do
            vim.fn.matchadd('FindrMatch','\\%>'..INPUT_LOC..'l\\c'..vim.fn.escape(str, '*?,.\\{}[]~'))
        end
    end
end

function M.redraw(display_table, input, selected_loc)
    local winheight = vim.fn.winheight('.')
    draw_candidates(display_table, winheight)
    add_highlights(input, selected_loc)
end
return M
