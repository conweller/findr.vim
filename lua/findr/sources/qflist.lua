local M = {}
local vim = vim

function M.table()
    local qflist = vim.api.nvim_call_function('getqflist', {})
    local t = {}
    for idx, err in ipairs(qflist) do
        local item = {}
        local name = vim.api.nvim_call_function('bufname', {err.bufnr})
        name = vim.api.nvim_call_function('pathshorten', {name})
        item.display = name..' '..err.lnum..': '..err.text
        item.value = idx
        table.insert(t,item)
    end
    return t
end

function M.sink(selected)
    return selected..'cc'
end

M.filetype = 'findr-qf'

return M
