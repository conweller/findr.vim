autocmd! CursorMovedI <buffer> call findr#redraw()
setlocal nonumber
setlocal norelativenumber
setlocal nocursorline
setlocal statusline=findr
setlocal bufhidden=delete
setlocal buftype=nofile
setlocal noswapfile
setlocal nofoldenable 

inoremap <silent> <buffer> <tab> <esc>:call findr#change_dir()<cr>a
inoremap <silent> <buffer> / <esc>:call findr#change_dir()<cr>a
inoremap <silent> <buffer> <cr> <esc>:call findr#edit()<cr>
inoremap <silent> <buffer> <up>   <esc>:call findr#prev_item()<cr>a
inoremap <silent> <buffer> <c-p>  <esc>:call findr#prev_item()<cr>a
inoremap <silent> <buffer> <down> <esc>:call findr#next_item()<cr>a
inoremap <silent> <buffer> <c-n>  <esc>:call findr#next_item()<cr>a
inoremap <silent> <buffer> <c-c> <esc>:call findr#quit()<cr>
inoremap <silent> <buffer> <esc> <esc>:call findr#quit()<cr>
inoremap <silent> <buffer> <backspace> <c-o>:call findr#delete()<cr>
