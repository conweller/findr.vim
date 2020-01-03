local M = {}

local vim = vim
local utils = require('findr.utils')

local INPUT_LOC = 1


local function draw_candidates(display_table, winheight)
    local display = utils.slice(display_table, INPUT_LOC , winheight-1, 1)
    vim.fn.nvim_buf_set_lines(0,INPUT_LOC, -1, true, display)
end

local function add_highlights(input, selected_loc)
    vim.fn.clearmatches()
    vim.fn.matchadd('FindrSelected', '\\%' .. selected_loc .. 'l.*')
end

function M.redraw(display_table, input, selected_loc)
    local winheight = vim.fn.winheight('.')
    draw_candidates(display_table, winheight)
    add_highlights(input, selected_loc)
end
return M
