local M = {}

local vim = vim
local utils = require('findr/utils')
local window = require('findr/view.window')
local namespace = vim.api.nvim_create_namespace('')
local virtual_text = ' '

local INPUT_LOC = 1

function M.init(filetype)
    local use_floating = vim.api.nvim_get_var('findr_floating_window')==1
    if use_floating then
        window.new_floating(filetype)
    else
        window.new_split(filetype)
    end
    virtual_text = string.rep(' ', vim.api.nvim_call_function('winwidth', {'.'}))
end

function M.setinput(prompt, input)
    local line = prompt .. input
    vim.api.nvim_call_function('setline', {INPUT_LOC, line})
end

local function draw_candidates(display_table, winheight)
    local t={}
    for idx, line in ipairs(display_table) do
        A = line
        if idx < winheight then
            line = line.display
            table.insert(t,line)
        else
            break
        end
    end
    vim.api.nvim_buf_set_lines(0,INPUT_LOC, -1, true, t)
end

local function add_highlights(input, selected_loc)
    local highlight_matches = vim.api.nvim_get_var('findr_highlight_matches') == 1
    vim.api.nvim_buf_clear_namespace(0 , namespace, 0, 1)
    vim.api.nvim_buf_set_virtual_text(0, namespace, selected_loc-1, {{virtual_text,'FindrSelected'}}, {})
    vim.api.nvim_call_function('clearmatches', {})
    vim.api.nvim_call_function('matchadd', {'FindrSelected', '\\%' .. selected_loc .. 'l.*'})
    if highlight_matches then
        for _, str in ipairs(utils.split(input)) do
            vim.api.nvim_call_function('matchadd', {'FindrMatch','\\%>'..INPUT_LOC..'l\\c'..vim.api.nvim_call_function('escape',{str, '*?,.\\{}[]~'})})
        end
    end
end

function M.redraw(display_table, input, selected_loc)
    local winheight = vim.api.nvim_call_function('winheight',{'.'})
    draw_candidates(display_table, winheight)
    add_highlights(input, selected_loc)
end
return M
