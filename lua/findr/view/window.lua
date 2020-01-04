local M = {}
local vim = vim

function M.new_split(args)

end

function M.new_split()
    vim.api.nvim_command('botright 10new')
    vim.api.nvim_command('file findr')
    vim.api.nvim_command('set ft=findr')
    vim.api.nvim_command('setlocal winhighlight=FoldColumn:Normal,Normal:FindrNormal')
end

return M
