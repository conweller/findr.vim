" autocmd! CursorMovedI <buffer> call findr#redraw()
autocmd! CursorMovedI <buffer> lua findr.controller.update()

setlocal bufhidden=delete
setlocal noshowmode
setlocal signcolumn=no
setlocal buftype=nofile
setlocal noswapfile
setlocal nocursorline
setlocal nowrap
setlocal norelativenumber
setlocal signcolumn=no
setlocal nonumber

" Unmap: {{{
imap <buffer> <s-up> <nop>
imap <buffer> <s-down> <nop>
imap <buffer> <M-p> <nop>
imap <buffer> <M-n> <nop>
imap <buffer> <c-t> <nop>
imap <buffer> <c-d> <nop>
imap <buffer> <c-w> <nop>
imap <buffer> <c-h> <nop>
imap <buffer> <Insert> <nop>
" }}}

imap <buffer> <cr> <plug>findr_edit
imap <buffer> <c-l> <plug>findr_edit
imap <buffer> <tab> <plug>findr_edit

imap <buffer> <up>   <plug>findr_prev
imap <buffer> <c-p>  <plug>findr_prev
imap <buffer> <c-k>  <plug>findr_prev

imap <buffer> <c-j> <plug>findr_next
imap <buffer> <c-n> <plug>findr_next
imap <buffer> <down> <plug>findr_next

imap <buffer> <c-c> <plug>findr_quit
imap <buffer> <esc> <plug>findr_quit

imap <buffer> <backspace> <plug>findr_bs
imap <buffer> <delete> <plug>findr_delete
imap <buffer> <c-u> <plug>findr_clear

imap <buffer> <left> <plug>findr_left
