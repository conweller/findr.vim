local M = {}

local vim = vim

local utils = require('findr/utils')
local view = require('findr/view')
local model = require('findr/model')
local sources = require('findr/sources')
local user_io = require('findr/controller/user_io')
local maps  = require('findr/controller/maps')



local startloc = 1
local selected_loc = 2
local winnum = -1
local bufnum = -1

function M.init()
    winnum = vim.fn.winnr()
    view.init()
    M.reset()
    model.history.source()
    bufnum = vim.fn.bufnr()
end

function M.quit()
    vim.api.nvim_command(winnum..'windo echo ""')
    vim.api.nvim_command('bw findr')
end

function M.update()
    local input = user_io.getinput()
    model.update(input, sources.files.table)
    selected_loc = math.min(utils.tablelength(model.display)+1, 2)
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

function M.history_next()
    model.history.next()
    local dir, input = model.history.get()
    local idx, jump_point = model.history.get_jumpoint()
    M.change_dir(dir)
    model.history.set_jumpoint(idx, jump_point)
    view.setinput(vim.fn.getcwd(), input)
    vim.api.nvim_command('startinsert!')
end

function M.history_prev()
    model.history.prev()
    local dir, input = model.history.get()
    local idx, jump_point = model.history.get_jumpoint()
    M.change_dir(dir)
    model.history.set_jumpoint(idx, jump_point)
    view.setinput(vim.fn.getcwd(), input)
    vim.api.nvim_command('startinsert!')
end

function M.reset()
    model.reset()
    startloc = 1
    selected_loc = 2
    local cwd = vim.fn.getcwd()
    model.history.reset(cwd)
    view.setinput(cwd, '')
    model.update('', sources.files.table)
    view.redraw(model.display, '', selected_loc)
    vim.api.nvim_command('startinsert!')
end

function M.change_dir(dir)
    if dir == '~' or vim.fn.isdirectory(dir) == 1 then
        vim.api.nvim_command('lcd '..dir)
        M.reset()
    end
end

function M.parent_dir()
    local input = user_io.getinput()
    M.change_dir('../')
    local cwd = vim.fn.getcwd()
    view.setinput(cwd, input)
end

function M.backspace()
    local pos = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.fn.getline(startloc)
    if string.sub(line, pos, pos) == '/' then
        M.parent_dir()
    else
        vim.api.nvim_command('call nvim_feedkeys("\\<BS>", "n", v:true)')
    end
end

-- TODO: doesn't work
function M.clear()
    local pos = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.fn.getline(startloc)
    if string.sub(line, pos, pos) ~= '/' then
        vim.api.nvim_command('call nvim_feedkeys("\\<c-u>", "n", v:true)')
    end
end

function M.delete_word()
    local pos = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.fn.getline(startloc)
    if string.sub(line, pos, pos) == '/' then
        M.parent_dir()
    else
        vim.api.nvim_command('call nvim_feedkeys("\\<c-w>", "n", v:true)')
    end
end
function M.left()
    local pos = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.fn.getline(startloc)
    if string.sub(line, pos, pos) ~= '/' then
        vim.api.nvim_command('call nvim_feedkeys("\\<left>", "n", v:true)')
    end
end

function M.delete()
    local pos = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.fn.getline(startloc)
    if pos ~= string.len(line) then
        vim.api.nvim_command('call nvim_feedkeys("\\<delete>", "n", v:true)')
    end
end

function M.expand()
    local input = user_io.getinput()
    if input == '~' then
        M.change_dir('~')
    else
        M.change_dir(user_io.get_filename())
    end
end

function M.quit()
    vim.api.nvim_command(winnum..'windo echo ""')
    vim.api.nvim_command('bw '..bufnum)
end

function M.edit()
    local fname = user_io.get_filename()
    model.history.update(user_io.get_dir_file_pair())
    model.history.write()
    M.quit()
    vim.api.nvim_command(winnum..'windo edit ' .. fname)
end


maps.set()

return M
