local M = {}

local vim = vim

local view = require('findr.view')
local model = require('findr.model')
local sources = require('findr.sources')
local user_io = require('findr.controller.user_io')
local maps  = require('findr.controller.maps')



local startloc = 1
local selected_loc = 2
local winnum = -1

function M.init()
    winnum = vim.fn.winnr()
    view.init()
    M.reset()
end

function M.quit()
    vim.api.nvim_command(winnum..'windo echo ""')
    vim.api.nvim_command('bw findr')
end

function M.update()
    local input = user_io.getinput()
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
    view.redraw(model.display, user_io.getinput(), selected_loc)
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
    view.redraw(model.display, user_io.getinput(), selected_loc)
end

function M.reset()
    model.reset()
    startloc = 1
    selected_loc = 2
    view.setinput('')
    model.update('', sources.files.table)
    view.redraw(model.display, '', selected_loc)
    vim.api.nvim_command('startinsert!')
end

function M.change_dir()
    local input = user_io.getinput()
    if input == '~' then
        vim.api.nvim_command('lcd ~')
    elseif selected_loc == 1 then
        vim.api.nvim_command('lcd ' .. user_io.get_filename())
    else
        vim.api.nvim_command('lcd '..model.get_selected())
    end
    M.reset()
end

function M.quit()
    vim.api.nvim_command(winnum..'windo echo ""')
    vim.api.nvim_command('bw findr')
end

function M.edit()
    local fname = user_io.get_filename()
    vim.api.nvim_command(winnum..'windo edit ' .. fname)
    M.quit()
end

maps.set()

return M
