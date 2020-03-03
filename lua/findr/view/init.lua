local M = {}

local vim = vim
local api = require('findr/api')
local utils = require('findr/utils')
local window = require('findr/view.window')
local namespace
if not api.vim8 then
    namespace = vim.api.nvim_create_namespace('')
end
local virtual_text = ' '

local INPUT_LOC = 1

function M.init(filetype)
    local use_floating = api.get_var('findr_floating_window') == 1 or type(api.get_var('findr_floating_window')) == type({})
    if use_floating and not api.vim8 then
        window.new_floating(filetype)
    else
        window.new_split(filetype)
    end
    virtual_text = string.rep(' ', api.call_function('winwidth', {'.'}))
end

function M.setinput(prompt, input)
    local line = prompt .. input
    api.call_function('setline', {INPUT_LOC, line})
end

local function draw_candidates(display_table, winheight)
    local t={}
    for idx, line in ipairs(display_table) do
        if idx < winheight then
            line = line.display
            table.insert(t,line)
        else
            break
        end
    end
    if api.vim8 then
        local empty = {}
        for i=1,winheight,1 do
            table.insert(empty, '')
        end
        api.call_function('setline', {INPUT_LOC+1, empty})
        api.call_function('setline', {INPUT_LOC+1, t})
    else
        vim.api.nvim_buf_set_lines(0,INPUT_LOC, -1, true, t)
    end
end

local function add_highlights(input, selected_loc)
    local highlight_matches = api.get_var('findr_highlight_matches') == 1
    if not api.vim8 then
        vim.api.nvim_buf_clear_namespace(0 , namespace, 0, 1)
        vim.api.nvim_buf_set_virtual_text(0, namespace, selected_loc-1, {{virtual_text,'FindrSelected'}}, {})
    end
    api.call_function('clearmatches', {})
    api.call_function('matchadd', {'FindrSelected', '\\%' .. selected_loc .. 'l.*'})
    if highlight_matches then
        for _, str in ipairs(utils.split(input)) do
            api.call_function('matchadd', {'FindrMatch','\\%>'..INPUT_LOC..'l\\c'..api.call_function('escape',{str, '*?,.\\{}[]~'})})
        end
    end
end

function M.redraw(display_table, input, selected_loc)
    local winheight = api.call_function('winheight',{'.'})
    draw_candidates(display_table, winheight)
    add_highlights(input, selected_loc)
end
return M
