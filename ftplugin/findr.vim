autocmd! TextChangedI <buffer> call findr#redraw()
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
inoremap <silent> <buffer> <up> <c-o>:call findr#prev_item()<cr>
inoremap <silent> <buffer> <down> <c-o>:call findr#next_item()<cr>
inoremap <silent> <buffer> <c-p> <c-o>:call findr#prev_item()<cr>
inoremap <silent> <buffer> <c-n> <c-o>:call findr#next_item()<cr>
inoremap <silent> <buffer> <c-g> <esc>:call findr#quit()<cr>
inoremap <silent> <buffer> <c-c> <esc>:call findr#quit()<cr>
inoremap <silent> <buffer> <esc> <esc>:call findr#quit()<cr>
inoremap <silent> <buffer> <backspace> <c-o>:call findr#delete()<cr>
