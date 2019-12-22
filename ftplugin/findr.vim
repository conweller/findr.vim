autocmd! CursorMovedI <buffer> call findr#redraw()
setlocal nonumber
setlocal norelativenumber
setlocal nocursorline
setlocal statusline=findr
setlocal bufhidden=delete
setlocal buftype=nofile
setlocal noswapfile
setlocal nofoldenable 

imap <buffer> <tab> <Plug>findr_cd
imap <buffer> / <plug>findr_cd
imap <buffer> <cr> <plug>findr_edit
imap <buffer> <up>   <plug>findr_prev
imap <buffer> <c-p>  <plug>findr_prev
imap <buffer> <down> <plug>findr_next
imap <buffer> <c-n>  <plug>findr_next
imap <buffer> <c-c> <plug>findr_quit
imap <buffer> <esc> <plug>findr_quit
imap <buffer> <backspace> <plug>findr_bs
imap <buffer> <c-u> <plug>findr_clear
imap <buffer> <m-p>  <plug>findr_hist_prev
imap <buffer> <m-n>  <plug>findr_hist_next
