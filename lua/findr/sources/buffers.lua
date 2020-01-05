local M = {}
local vim = vim

function list_buffers()
    local buffers = vim.api.nvim_list_bufs()
    local t = {}
    for _, buffer in ipairs(buffers) do
        if vim.api.nvim_buf_is_loaded(buffer) then
            table.insert(t,vim.api.nvim_buf_get_name(buffer))
        end
    end
    return t
end

function M.table()
    return list_buffers()
end

function M.sink(selected)
    return 'buffer '..selected
end

M.filetype = 'findr'

return M
