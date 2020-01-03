local M = {}

local vim = vim

local view = require('findr.view')
local model = require('findr.model')
local sources = require('findr.sources')

local startloc = 1
local selected_loc = 2

local function getinput()
    local line = vim.fn.getline(startloc)
    local input = string.match('/'..line, '^.+/(.+)$')
    if not input or string.find(input, '/$') then
        return ''
    end
    return input
end

local function setinput(input)
    local line = vim.fn.getcwd()
    line = line == '/' and '/' or line .. '/'
    line = line .. input
    vim.fn.setline(startloc, line)
end

function M.update()
    local input = getinput()
    selected_loc = 2
    model.update(input, sources.files.table)
    view.redraw(model.display, input, selected_loc)
end

function M.select_next()
    selected_loc = selected_loc + ( model.select_next() and 1 or 0 )
    if selected_loc == vim.fn.winheight('.')+1 then
        selected_loc = selected_loc - 1
        model.scroll_down()
    end
    view.redraw(model.display, getinput(), selected_loc)
end

function M.select_prev()
    local success = model.select_prev()
    selected_loc = selected_loc - ( success and 1 or 0 )
    if selected_loc == startloc and success then
        selected_loc = selected_loc + 1
        model.scroll_up()
    elseif not success then
        selected_loc = 1
    end
    view.redraw(model.display, getinput(), selected_loc)
end

function M.get_selected()
    return model.get_selected()
end

function M.reset()
    model.reset()
    startloc = 1
    selected_loc = 2
    setinput('')
end

function M.change_dir()
    vim.api.nvim_command('lcd '..M.get_selected())
    M.reset()
    M.update()
    vim.api.nvim_command('startinsert!')
end

function scandir()
    return sources.files.table()
end

return M
