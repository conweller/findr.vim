augroup FindrMoved
    autocmd! CursorMovedI <buffer> lua findr.controller.update()
augroup END

setlocal bufhidden=delete
setlocal signcolumn=no
setlocal buftype=nofile
setlocal noswapfile
setlocal nocursorline
setlocal nowrap
setlocal norelativenumber
setlocal signcolumn=no
setlocal nonumber
setlocal nobuflisted

" Unmap: {{{
imap <buffer> <s-up> <nop>
imap <buffer> <s-down> <nop>
imap <buffer> <M-p> <nop>
imap <buffer> <M-n> <nop>
imap <buffer> <c-d> <nop>
imap <buffer> <Insert> <nop>
" }}}

imap <buffer><nowait> <c-w> <plug>findr_word_delete

imap <buffer><nowait> <cr> <plug>findr_edit
imap <buffer><nowait> <c-l> <plug>findr_edit
imap <buffer><nowait> <tab> <plug>findr_edit
imap <buffer><nowait> <c-t> <plug>findr_tabedit
imap <buffer><nowait> <c-x> <plug>findr_split
imap <buffer><nowait> <c-v> <plug>findr_vsplit

imap <buffer><nowait> <c-h> <plug>findr_bs
imap <buffer><nowait> <c-u> <plug>findr_clear

imap <buffer><nowait> <up>   <plug>findr_prev
imap <buffer><nowait> <c-p>  <plug>findr_prev
imap <buffer><nowait> <c-k>  <plug>findr_prev

imap <buffer><nowait> <c-j> <plug>findr_next
imap <buffer><nowait> <c-n> <plug>findr_next
imap <buffer><nowait> <down> <plug>findr_next

imap <buffer><nowait> <c-c> <plug>findr_quit
imap <buffer> <esc> <plug>findr_quit
imap <buffer><nowait> <c-g> <plug>findr_quit

imap <buffer><nowait> <backspace> <plug>findr_bs
imap <buffer><nowait> <delete> <plug>findr_delete

imap <buffer><nowait> <left> <plug>findr_left

if !has('nvim')
    imap <buffer> OD <plug>findr_left
    imap <silent><buffer> OC <right>
    imap <silent><buffer> OA <plug>findr_prev
    imap <silent><buffer> OB <plug>findr_next
endif
" vim: set sw=2 ts=2 sts=2 et tw=80 ft=vim fdm=marker:

