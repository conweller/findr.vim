local M = {}
local vim = vim

local function buf_valid(buf)
    if buf == vim.api.nvim_call_function('bufnr',{}) then
        return false
    elseif vim.api.nvim_call_function('buflisted', {buf}) == 1 then
        local name = vim.api.nvim_buf_get_name(buf)
        return name ~= ''
    end
    return false
end

local function list_buffers()
    local buffers = vim.api.nvim_list_bufs()
    local t = {}
    for _, buffer in ipairs(buffers) do
        if vim.api.nvim_buf_is_loaded(buffer) and buf_valid(buffer) then
            table.insert(t,vim.api.nvim_buf_get_name(buffer))
        end
    end
    return t
end

function M.table()
    return list_buffers()
end

function M.sink(selected)
    return 'e '..selected
end

function M.prompt()
    return '> '
end

function M.display(line)
    dir = vim.api.nvim_call_function('fnamemodify', {line, ':h'})
    file = vim.api.nvim_call_function('fnamemodify', {line, ':t'})
    return vim.api.nvim_call_function('pathshorten', {dir})..'/'..file
end

M.filetype = 'findr'
M.history = false

return M
