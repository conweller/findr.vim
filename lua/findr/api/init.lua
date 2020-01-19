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

function M.call_function(fun, args)
    if M.vim8 then
        local vim_fun =  vim.funcref(fun)
        return vim_fun(table.upack(args))
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
        vim.command(mode..'noremap <silent> '..name..' '..script)
    else
        vim.api.nvim_set_keymap(mode, name, script, options)
    end
end

return M
