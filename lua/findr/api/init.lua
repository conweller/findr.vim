local M = {}

local vim = vim
M.vim8 = false

if not vim.api then
    M.vim8 = true
end

function M.get_var(var)
    if M.vim8 then
        return vim.eval('g:'..var)
    else
        return vim.api.nvim_get_var(var)
    end
end

local function table_to_vim_list(t)
    local res = {}
    for _, val in ipairs(t) do
        if type( val ) ~= "table" then
            table.insert(res, tostring(val))
        else
            table.insert(res, vim.list(table_to_vim_list(val)))
        end
    end
    return res
end

function M.call_function(fun, args)
    if M.vim8 then
        local vargs = table_to_vim_list(args)
        local vim_fun =  vim.funcref(fun)
        return vim_fun(table.unpack(vargs))
    else
        return vim.api.nvim_call_function(fun, args)
    end
end

function M.command(command_name)
    if M.vim8 then
        vim.command(command_name)
    else
        vim.api.nvim_command(command_name)
    end
end

function M.set_map(mode, name, script, options)
    if M.vim8 then
        local vscript = string.gsub(script, '^<cmd>', '<c-o>:')
        vim.command('inoremap <silent> '..name..' '..vscript)
    else
        vim.api.nvim_set_keymap(mode, name, script, options)
    end
end

return M
