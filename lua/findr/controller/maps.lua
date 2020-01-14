local M = {}
local vim = vim


function M.set()
    local opts = { noremap = true, silent=true }
    vim.api.nvim_set_keymap('i', '<plug>findr_cd', '<cmd>lua findr.controller.expand()<cr>', opts)
    vim.api.nvim_set_keymap('i', '<plug>findr_next', '<cmd>lua findr.controller.select_next()<cr>', opts)
    vim.api.nvim_set_keymap('i', '<plug>findr_prev', '<cmd>lua findr.controller.select_prev()<cr>', opts)
    vim.api.nvim_set_keymap('i', '<plug>findr_hist_next', '<cmd>lua findr.controller.history_next()<cr>', opts)
    vim.api.nvim_set_keymap('i', '<plug>findr_hist_prev', '<cmd>lua findr.controller.history_prev()<cr>', opts)
    vim.api.nvim_set_keymap('i', '<plug>clear_to_parent', '<cmd>lua findr.controller.clear_to_parent("../")<cr>', opts)
    vim.api.nvim_set_keymap('i', '<plug>findr_bs', '<cmd>lua findr.controller.backspace()<cr>', opts)
    vim.api.nvim_set_keymap('i', '<plug>findr_word_delete', '<cmd>lua findr.controller.delete_word()<cr>', opts)
    vim.api.nvim_set_keymap('i', '<plug>findr_clear', '<cmd>lua findr.controller.clear()<cr>', opts)
    vim.api.nvim_set_keymap('i', '<plug>findr_delete', '<cmd>lua findr.controller.delete()<cr>', opts)
    vim.api.nvim_set_keymap('i', '<plug>findr_left', '<cmd>lua findr.controller.left()<cr>', opts)

    vim.api.nvim_set_keymap('i', '<plug>findr_edit', '<esc>:lua findr.controller.edit()<cr>', opts)
    vim.api.nvim_set_keymap('i', '<plug>findr_quit', '<esc>:lua findr.controller.quit()<cr>', opts)
end

return M
