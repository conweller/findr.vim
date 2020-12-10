local M = {}

local vim = vim
local api = require('findr/api')

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

local prev_input = -1

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
    winnum = api.call_function('winnr', {})
    view.init(filetype)
    api.command('lcd '..directory)
    M.reset()
    if source.history then
        use_history = source.history
    else
        use_history = false
    end
    if use_history then
        model.history.source()
    end
    bufnum = api.call_function('bufnr',{})
end

function M.update()
    local input = user_io.getinput(prompt)
    if input ~= prev_input then
        num_tab = 0
        model.update(input, source.table)
        selected_loc = math.min(#model.display+1, 2)
        view.redraw(model.display, input, selected_loc)
    end
    prev_input = input
end

function M.select_next()
    local success = model.select_next()
    selected_loc = selected_loc + ( success and 1 or 0 )
    if selected_loc == api.call_function('winheight',{'.'})+1 then
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
    api.command('startinsert!')
    num_tab = 0
end

function M.history_prev()
    model.history.prev()
    local dir, input = model.history.get()
    local idx, jump_point = model.history.get_jumpoint()
    M.change_dir(dir)
    model.history.set_jumpoint(idx, jump_point)
    view.setinput(prompt, input)
    api.command('startinsert!')
    num_tab = 0
end


local function reset_scroll()
    api.command('call feedkeys("\\<c-o>zh", "n")')
end

local function hard_reset_scroll()
    api.command('set wrap')
    api.command('set nowrap')
end

function M.reset()
    num_tab = 0
    model.reset()
    startloc = 1
    selected_loc = 2
    if use_history then
        local cwd = api.call_function('getcwd',{})
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
    api.command('normal ze')
    api.command('startinsert!')
end

function M.change_dir(dir)
    if dir == '~' or api.call_function('isdirectory', {dir}) == 1 then
        api.command('lcd '..dir)
        M.reset()
    end
end

function M.parent_dir()
    local input = user_io.getinput(prompt)
    M.change_dir('../')
    view.setinput(prompt, input)
end

local function on_prompt()
    local pos
    if api.vim8 then
        pos = api.call_function('getcurpos', {})[5]-1
    else
        pos = vim.api.nvim_win_get_cursor(0)[2]
    end
    return pos == string.len(prompt)
end

function M.backspace()
    if on_prompt() then
        if filetype == 'findr-files' then
            M.parent_dir()
        end
    else
        reset_scroll()
        if api.vim8 then
            api.command('call feedkeys("\\<left>\\<delete>", "n")')
        else
            vim.api.nvim_command('call nvim_feedkeys("\\<BS>", "n", v:true)')
        end
    end
end

function M.clear()
    if not on_prompt() then
        if api.vim8 then
            local pos = api.call_function('getcurpos', {})[5]-1
            local line = api.call_function('getline', {1})
            local input = string.sub(line,pos+1)
            view.setinput(prompt, input)
            api.call_function('setpos', {'.', {0, 1, string.len(prompt)+1}})
            if string.len(line) == pos+1 then
                api.command('call feedkeys("\\<left>", "n")')
            end
        else
            local pos = vim.api.nvim_win_get_cursor(0)[2]
            local line = vim.api.nvim_call_function('getline', {startloc})
            local input = string.sub(line,pos+1,string.len(line))
            view.setinput(prompt, input)
            vim.api.nvim_win_set_cursor(0, {1, string.len(prompt)})
        end
        hard_reset_scroll()
    end
end

function M.delete_prev_word()
    if not on_prompt() then
        if api.vim8 then
            local pos = api.call_function('getcurpos', {})[5]-1
            local line = api.call_function('getline', {1})
            local before = string.sub(line, string.len(prompt)+1,pos+1)
            local del_idx = string.find(before, "%s*[^ ]*%s*$")-1
            before = string.sub(before, 0, del_idx)
            local input = string.sub(line,pos+1,string.len(line))
            view.setinput(prompt, before..input)
            api.call_function('setpos', {'.', {0, 1, string.len(prompt) + string.len(before)+1}})
            if string.len(line) == pos+1 then
                api.command('call feedkeys("\\<left>", "n")')
            end
        else
            local pos = vim.api.nvim_win_get_cursor(0)[2]
            local line = vim.api.nvim_call_function('getline', {startloc})
            local input = string.sub(line,pos+1,string.len(line))
            local before = string.sub(line, string.len(prompt)+1,pos+1)
            local del_idx = string.find(before, "%s*[^ ]*%s*$")-1
            before = string.sub(before, 0, del_idx)
            view.setinput(prompt, before..input)
            vim.api.nvim_win_set_cursor(0, {1, string.len(prompt) + string.len(before)})
        end
        hard_reset_scroll()
    elseif filetype == 'findr-files' then
            M.parent_dir()
    end
end

function M.clear_to_parent()
    if not on_prompt() then
        if api.vim8 then
            local pos = api.call_function('getcurpos', {})[5]-1
            local line = api.call_function('getline', {1})
            local input = string.sub(line,pos+1)
            view.setinput(prompt, input)
            api.call_function('setpos', {'.', {0, 1, string.len(prompt)+1}})
            if string.len(line) == pos+1 then
                api.command('call feedkeys("\\<left>", "n")')
            end
        else
            local pos = vim.api.nvim_win_get_cursor(0)[2]
            local line = vim.api.nvim_call_function('getline', {startloc})
            local input = string.sub(line,pos+1,string.len(line))
            view.setinput(prompt, input)
            vim.api.nvim_win_set_cursor(0, {1, string.len(prompt)})
        end
        hard_reset_scroll()
    elseif filetype == 'findr-files' then
            M.parent_dir()
    end
end


function M.left()
    if not on_prompt() then
        api.command('call feedkeys("\\<left>", "n")')
        reset_scroll()
    end
end

function M.delete()
    local pos
    local line
    if api.vim8 then
        pos = api.call_function('getpos', {'.'})[2]-1
        line = api.call_function('getline', {startloc})
    else
        pos = vim.api.nvim_win_get_cursor(0)[2]
        line = vim.api.nvim_call_function('getline', {startloc})
    end
    if pos ~= string.len(line) then
        api.command('call feedkeys("\\<delete>", "n")')
    end
end

function M.expand()
    local input = user_io.getinput(prompt)
    if input == '~' then
        M.change_dir('~')
    else
        local filename = user_io.get_filename(prompt)
        if api.call_function('isdirectory', {filename})  == 1 then
            M.change_dir(filename)
        elseif num_tab >= 1 then
            M.edit()
            api.command('call feedkeys("\\<esc>", "n")')
        else
            num_tab = num_tab + 1
        end

    end
end

function M.quit()
    api.command(winnum..'windo echo ""')
    api.command('silent bw '..bufnum)
end

function M.edit(editcmd)
    local fname
    if filetype == 'findr-files' then
        fname = user_io.get_filename(prompt)
    else
        fname = user_io.get_selected(prompt)
    end
    local command = source.sink(fname, editcmd)
    if use_history then
        model.history.update(user_io.get_dir_file_pair(prompt))
        model.history.write()
    end
    M.quit()
    api.command(winnum..'windo '..command)
end


maps.set()

return M
