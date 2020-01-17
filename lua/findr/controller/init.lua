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
local source = sources.files
local filetype = source.filetype
local prompt = '> '
local use_history = source.history
local num_tab = 0

function M.init(new_source, directory)
    source = new_source
    if source.init then
        source.init()
    end
    if source.filetype then
        filetype = source.filetype
    else
        filetype = 'findr'
    end
    winnum = vim.api.nvim_call_function('winnr', {})
    view.init(filetype)
    vim.api.nvim_command('lcd '..directory)
    M.reset()
    if source.history then
        use_history = source.history
    else
        use_history = false
    end
    if use_history then
        model.history.source()
    end
    bufnum = vim.api.nvim_call_function('bufnr',{})
end

function M.update()
    num_tab = 0
    local input = user_io.getinput(prompt)
    model.update(input, source.table)
    selected_loc = math.min(utils.tablelength(model.display)+1, 2)
    view.redraw(model.display, input, selected_loc)
end

function M.select_next()
    local success = model.select_next()
    selected_loc = selected_loc + ( success and 1 or 0 )
    if selected_loc == vim.api.nvim_call_function('winheight',{'.'})+1 then
        selected_loc = selected_loc - 1
        model.scroll_down()
    end
    view.redraw(model.display, user_io.getinput(prompt), selected_loc)
    num_tab = 0
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
    view.redraw(model.display, user_io.getinput(prompt), selected_loc)
    num_tab = 0
end

function M.history_next()
    model.history.next()
    local dir, input = model.history.get()
    local idx, jump_point = model.history.get_jumpoint()
    M.change_dir(dir)
    model.history.set_jumpoint(idx, jump_point)
    view.setinput(prompt, input)
    vim.api.nvim_command('startinsert!')
    num_tab = 0
end

function M.history_prev()
    model.history.prev()
    local dir, input = model.history.get()
    local idx, jump_point = model.history.get_jumpoint()
    M.change_dir(dir)
    model.history.set_jumpoint(idx, jump_point)
    view.setinput(prompt, input)
    vim.api.nvim_command('startinsert!')
    num_tab = 0
end

function M.reset()
    num_tab = 0
    model.reset()
    startloc = 1
    selected_loc = 2
    if use_history then
        local cwd = vim.api.nvim_call_function('getcwd',{})
        model.history.reset(cwd, '')
    end
    if not source.prompt then
        prompt = '> '
    else
        prompt = source.prompt()
    end
    view.setinput(prompt, '')
    model.update('', source.table)
    view.redraw(model.display, '', selected_loc)
    vim.api.nvim_command('startinsert!')
end

function M.change_dir(dir)
    if dir == '~' or vim.api.nvim_call_function('isdirectory', {dir}) == 1 then
        vim.api.nvim_command('lcd '..dir)
        M.reset()
    end
end

function M.parent_dir()
    local input = user_io.getinput(prompt)
    M.change_dir('../')
    local cwd = vim.api.nvim_call_function('getcwd',{})
    view.setinput(prompt, input)
end

local function on_prompt()
    local pos = vim.api.nvim_win_get_cursor(0)[2]
    return pos == string.len(prompt)
end

function M.backspace()
    if on_prompt() then
        if filetype == 'findr-files' then
            M.parent_dir()
        end
    else
        vim.api.nvim_command('call nvim_feedkeys("\\<BS>", "n", v:true)')
    end
end

function M.clear()
    if not on_prompt() then
        local pos = vim.api.nvim_win_get_cursor(0)[2]
        local line = vim.api.nvim_call_function('getline', {startloc})
        local input = string.sub(line,pos+1,string.len(line))
        view.setinput(prompt, input)
        vim.api.nvim_win_set_cursor(0, {1, string.len(prompt)})
    end
end

function M.clear_to_parent()
    if not on_prompt() then
        local pos = vim.api.nvim_win_get_cursor(0)[2]
        local line = vim.api.nvim_call_function('getline', {startloc})
        local input = string.sub(line,pos+1,string.len(line))
        view.setinput(prompt, input)
        vim.api.nvim_win_set_cursor(0, {1, string.len(prompt)})
    elseif filetype == 'findr-files' then
            M.parent_dir()
    end
end

function M.delete_word()
    if on_prompt() then
        if filetype == 'findr-files' then
            M.parent_dir()
        end
    else
        vim.api.nvim_command('call nvim_feedkeys("\\<c-w>", "n", v:true)')
    end
end

function M.left()
    if not on_prompt() then
        vim.api.nvim_command('call nvim_feedkeys("\\<left>", "n", v:true)')
    end
end

function M.delete()
    local pos = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_call_function('getline', {startloc})
    if pos ~= string.len(line) then
        vim.api.nvim_command('call nvim_feedkeys("\\<delete>", "n", v:true)')
    end
end

function M.expand()
    local input = user_io.getinput(prompt)
    if input == '~' then
        M.change_dir('~')
    else
        local filename = user_io.get_filename(prompt)
        if vim.api.nvim_call_function('isdirectory', {filename})  == 1 then
            M.change_dir(filename)
        elseif num_tab >= 1 then
            M.edit()
            vim.api.nvim_command('call nvim_feedkeys("\\<esc>", "n", v:true)')
        else
            num_tab = num_tab + 1
        end

    end
end

function M.quit()
    vim.api.nvim_command(winnum..'windo echo ""')
    vim.api.nvim_command('silent bw '..bufnum)
end

function M.edit()
    local fname
    if filetype == 'findr-files' then
        fname = user_io.get_filename(prompt)
    else
        fname = user_io.get_selected(prompt)
    end
    local command = source.sink(fname)
    if use_history then
        model.history.update(user_io.get_dir_file_pair(prompt))
        model.history.write()
    end
    M.quit()
    vim.api.nvim_command(winnum..'windo '..command)
end


maps.set()

return M
