" autocmd! CursorMovedI <buffer> call findr#redraw()
autocmd! CursorMovedI <buffer> lua findr.controller.update()
setlocal bufhidden=delete
setlocal signcolumn=no
setlocal buftype=nofile
setlocal noswapfile
setlocal nocursorline

" Unmap: {{{
imap <buffer> <c-t> <nop>
imap <buffer> <c-d> <nop>
imap <buffer> <Insert> <nop>
imap <buffer> <c-w> <nop>
" }}}

" imap <buffer> <tab> <Plug>findr_cd
" imap <buffer> / <plug>findr_cd
imap <buffer> <tab> <cmd>lua findr.controller.change_dir()<cr>
" imap <buffer> <c-l> <plug>findr_cd
" imap <buffer> <c-h> <plug>findr_parent_dir

" imap <buffer> <cr> <plug>findr_edit

" imap <buffer> <up>   <plug>findr_prev
" imap <buffer> <c-p>  <plug>findr_prev
" imap <buffer> <c-k>  <plug>findr_prev

" imap <buffer> <down> <plug>findr_next
imap <buffer> <down>  <cmd>lua findr.controller.select_next()<cr>
imap <buffer> <c-n>  <cmd>lua findr.controller.select_next()<cr>
imap <buffer> <c-p>  <cmd>lua findr.controller.select_prev()<cr>
imap <buffer> <up>  <cmd>lua findr.controller.select_prev()<cr>
" imap <buffer> <c-j>  <plug>findr_next

" imap <buffer> <c-c> <plug>findr_quit
" imap <buffer> <esc> <plug>findr_quit

" imap <buffer> <backspace> <plug>findr_bs
" imap <buffer> <delete> <plug>findr_delete
" imap <buffer> <c-u> <plug>findr_clear

" imap <buffer> <m-p>  <plug>findr_hist_prev
" imap <buffer> <m-n>  <plug>findr_hist_next
" imap <buffer> <s-up>  <plug>findr_hist_prev
" imap <buffer> <s-down>  <plug>findr_hist_next
