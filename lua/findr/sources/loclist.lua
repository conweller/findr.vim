local M = {}
local vim = vim
local winnum = -1

function M.table()
    local loclist = vim.api.nvim_call_function('getloclist', {winnum})
    local t = {}
    for idx, err in ipairs(loclist) do
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
    return selected..'ll'
end

M.filetype = 'findr-qf'

function M.init()
    winnum = vim.api.nvim_call_function('winnr', {})
end

return M
