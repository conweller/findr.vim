local M = {}
local vim = vim
local api = require('findr/api')


function M.set()
    local opts = { noremap = true, silent=true }
    api.set_map('i', '<plug>findr_cd', '<cmd>lua findr.controller.expand()<cr>', opts)
    api.set_map('i', '<plug>findr_next', '<cmd>lua findr.controller.select_next()<cr>', opts)
    api.set_map('i', '<plug>findr_prev', '<cmd>lua findr.controller.select_prev()<cr>', opts)
    api.set_map('i', '<plug>findr_hist_next', '<cmd>lua findr.controller.history_next()<cr>', opts)
    api.set_map('i', '<plug>findr_hist_prev', '<cmd>lua findr.controller.history_prev()<cr>', opts)
    api.set_map('i', '<plug>clear_to_parent', '<cmd>lua findr.controller.clear_to_parent("../")<cr>', opts)
    api.set_map('i', '<plug>findr_bs', '<cmd>lua findr.controller.backspace()<cr>', opts)
    api.set_map('i', '<plug>findr_word_delete', '<cmd>lua findr.controller.delete_prev_word()<cr>', opts)
    api.set_map('i', '<plug>findr_clear', '<cmd>lua findr.controller.clear()<cr>', opts)
    api.set_map('i', '<plug>findr_delete', '<cmd>lua findr.controller.delete()<cr>', opts)
    api.set_map('i', '<plug>findr_left', '<cmd>lua findr.controller.left()<cr>', opts)

    api.set_map('i', '<plug>findr_edit', '<esc>:lua findr.controller.edit()<cr>', opts)
    api.set_map('i', '<plug>findr_vsplit', '<esc>:lua findr.controller.edit("vs")<cr>', opts)
    api.set_map('i', '<plug>findr_split', '<esc>:lua findr.controller.edit("split")<cr>', opts)
    api.set_map('i', '<plug>findr_tabedit', '<esc>:lua findr.controller.edit("tabedit")<cr>', opts)
    api.set_map('i', '<plug>findr_quit', '<esc>:lua findr.controller.quit()<cr>', opts)
end

return M
