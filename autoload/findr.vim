lua require("findr")
" Variables: {{{
if !exists('g:findr_enable_border')
  let g:findr_enable_border = 1
endif

if !exists('g:findr_border')
  let g:findr_border = {
        \   'top':    ['┌', '─', '┐'],
        \   'middle': ['│', ' ', '│'],
        \   'bottom': ['└', '─', '┘'],
        \ }
endif

if !exists('g:findr_max_hist')
  let g:findr_max_hist = 100
endif

let s:cur_dir = getcwd()
let s:start_loc = 1
let s:hist_loc = 0
let s:hist = []
let s:hist_jump_from = getcwd()
let s:selected_loc = s:start_loc+1
let s:winnum = 1
let s:use_floating_win = v:true
let s:old_input = -1
let s:old_dir = -1
let s:first_line = ''
let s:histfile = -1
" }}}
" Logic: {{{
function! findr#get_input()
  let line = getline(s:start_loc)
  if line !='' && line[-1] != '/'
    return join(split(split(line. ' ', '/')[-1]))
  endif
  return ''
endfunction

function! findr#get_choice()
  return getline(s:selected_loc)
endfunction

function! s:valid_source(line)
  let dir_file_pair =split(a:line, "\t")
  if len(dir_file_pair) == 2
    return isdirectory(dir_file_pair[0])
  endif
  let g:a = len(dir_file_pair)
  return v:false
endfunction

function! findr#source_hist(histfile)
    call writefile([], a:histfile, 'a')
    let s:hist = readfile(a:histfile)
    if s:hist == ['']
      let s:hist = []
    endif
    call filter(s:hist, 's:valid_source(v:val)')
    let s:histfile = a:histfile
endfunction

function! findr#prev_hist()
  if len(s:hist) > 0
    if s:hist_loc == 0
      let s:hist_loc = len(s:hist)
    elseif s:hist_loc > 1
      let s:hist_loc = s:hist_loc - 1
    endif
    call findr#select_hist()
  endif
endfunction

function! findr#next_hist()
  if len(s:hist) > 0 && s:hist_loc > 0
    let s:hist_loc = (s:hist_loc + 1) % (len(s:hist)+1)
    call findr#select_hist()
  endif
endfunction

function! findr#select_hist()
  if s:hist_loc !=0
    let hist = split(s:hist[s:hist_loc-1],'\t')
    let dir = hist[0]
    let file = hist[1]
    if file == './' || '.'
      let file = ''
    elseif file == '../' || '..'
      let dir = fnamemodify(dir, ':p:h:h')
      let file = ''
    endif
  elseif s:hist_loc == 0
    let dir = s:hist_jump_from
    let file = ''
  endif
  execute 'lcd ' dir
  call luaeval('findr.reset()')
  let s:old_dir = s:cur_dir
  let s:cur_dir = getcwd()
  let s:selected_loc = min([line('$'), s:start_loc+1])
  call setline(s:start_loc, s:short_path() . file)
  call findr#redraw()
  normal $
  startinsert!
endfunction

function! findr#write_hist(selected)
  if s:histfile != -1
    let selected = a:selected
    if a:selected == ''
      let selected = './'
    endif
    if len(s:hist) == 0
      call add(s:hist, s:cur_dir . '	' . selected)
    elseif s:hist[-1] != s:cur_dir . '	' . selected
      call add(s:hist, s:cur_dir . '	' . selected)
    endif
    let start = max([len(s:hist) - g:findr_max_hist, 0])
    call writefile(s:hist[start:], s:histfile)
  endif
endfunction
" }}}
" UI: {{{
" Selection: {{{
function! findr#scroll_up()
  call luaeval('findr.scroll_up(1)')
  let scrolled = luaeval('findr.display')
  call map(scrolled, 's:slashifdir(v:val)')
  call deletebufline('%', s:start_loc + 1, line('$'))
  call s:setlines(scrolled)
endfunction

function! findr#scroll_down()
  call luaeval('findr.scroll_down(1)')
  let scrolled = luaeval('findr.display')
  call map(scrolled, 's:slashifdir(v:val)')
  call deletebufline('%', s:start_loc + 1, line('$'))
  call s:setlines(scrolled)
endfunction

function! findr#next_item()
  if s:selected_loc > winheight('.')-1
    if  getline(winheight('.')+1) != s:first_line
      call findr#scroll_down()
    endif
  elseif s:selected_loc < line('$')
    let s:selected_loc += 1
  else
    let s:selected_loc = line('$')
  endif
  call findr#redraw_highlights()
endfunction

function! findr#prev_item()
  if s:selected_loc > s:start_loc
    if s:selected_loc == s:start_loc + 1 && getline(s:selected_loc) != s:first_line
      call findr#scroll_up()
    else
      let s:selected_loc -=  1
    endif
  else
    let s:selected_loc = s:start_loc
  endif
  call findr#redraw_highlights()
endfunction
" }}}
" Display: {{{
function! s:slashifdir(line)
  if isdirectory(s:cur_dir . '/'. a:line)
    return a:line . '/'
  endif
  return a:line
endfunction

function! s:setlines(array)
  call setline(s:start_loc+1, a:array)
endfunction

function! s:tabline_visible()
  let tabnum = tabpagenr()
  let count = 0
  tabdo let count+=1
  execute tabnum.'tabnext'
  return count > 1 && &showtabline
endfunction

function! findr#floating()
 let width = min([&columns - 4, max([80, &columns - 20])])
  let buf = nvim_create_buf(v:false, v:true)
  call setbufvar(buf, '&signcolumn', 'no')

  " let height = float2nr(15)
  let height= &lines-(4+s:tabline_visible())
  let width = float2nr(80)
  let horizontal = float2nr((&columns - width) / 2)
  let vertical = 1 + s:tabline_visible()
  let opts = {
        \ 'relative': 'editor',
        \ 'row': vertical,
        \ 'col': horizontal,
        \ 'width': width,
        \ 'height': height,
        \ 'style': 'minimal'
        \ }
  if g:findr_enable_border
    let top = g:findr_border.top[0] .    repeat(g:findr_border.top[1], width - 2) . g:findr_border.top[2]
    let mid = g:findr_border.middle[0] . repeat(g:findr_border.middle[1], width - 2) . g:findr_border.middle[2]
    let bot = g:findr_border.bottom[0] . repeat(g:findr_border.bottom[1], width - 2) . g:findr_border.bottom[2]
    let lines = [top] + repeat([mid], height - 2) + [bot]
    let s:buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(s:buf, 0, -1, v:true, lines)
    call nvim_open_win(s:buf, v:true, opts)
    let opts.row += 1
    let opts.height -= 2
    let opts.col += 2
    let opts.width -= 4
    set winhl=Normal:FindrBorder
    call nvim_open_win(nvim_create_buf(v:true, v:false), v:true, opts)
    au BufWipeout <buffer> exe 'bw! '.s:buf
  else
    call nvim_open_win(nvim_create_buf(v:true, v:false), v:true, opts)
  endif
  file findr
  setlocal winhighlight=FoldColumn:Normal,Normal:FindrNormal
endfunction

function! findr#redraw()
  call luaeval('findr.update(_A, findr.comp_stack)', findr#get_input())
  call luaeval('findr.update_display(findr.comp_stack, _A)', winheight('.')-1)
  let completions = luaeval('findr.display')
  call map(completions, 's:slashifdir(v:val)')
  if len(completions) > 0
    let s:first_line = completions[0]
  else
    let s:first_line = ''
  endif
  call deletebufline('%', s:start_loc + 1, line('$'))
  call s:setlines(completions)
  let s:selected_loc = min([s:start_loc+1, line('$')])
  call findr#redraw_highlights()
endfunction

function! findr#redraw_highlights()
  call clearmatches()
  call matchadd('FindrDirPartial','^.*/')
  call matchadd('FindrDir','^.*/$')
  call matchadd('FindrSelected','\%'.s:selected_loc.'l.*')
  call matchadd('FindrSelectedDirPartial','^\%'.s:selected_loc.'l.*/')
  call matchadd('FindrSelectedDir','^\%'.s:selected_loc.'l.*/$')
endfunction
" }}}
" Actions {{{
function! findr#change_dir()
  if findr#get_input() == '~'
    lcd ~
    call luaeval('findr.reset()')
  elseif findr#get_input() == '-'
    if s:old_dir != -1
      execute 'lcd ' . s:old_dir
      call luaeval('findr.reset()')
    else
      call setline(s:start_loc, s:short_path())
    endif
  elseif isdirectory(s:cur_dir . '/' . findr#get_choice())
    execute 'lcd ' . s:cur_dir . '/' . findr#get_choice()
    call luaeval('findr.reset()')
  elseif split(findr#get_input()) != []
    if isdirectory(s:cur_dir . '/' . split(findr#get_input())[0])
      execute 'lcd ' . s:cur_dir . '/' . findr#get_input()
      call luaeval('findr.reset()')
    else 
      return
    endif
  else
    return
  endif
  let s:old_dir = s:cur_dir
  let s:hist_jump_from = getcwd()
  let s:cur_dir = getcwd()
  let s:selected_loc = min([line('$'), s:start_loc+1])
  call setline(s:start_loc, s:short_path())
  call findr#redraw()
  normal $
  startinsert!
endfunction

function! s:short_path()
  let shortpath = pathshorten(s:cur_dir). '/'
  if shortpath == '//'
    let shortpath = '/'
  endif
  return shortpath
endfunction

function! findr#parent_dir()
  execute 'lcd ..'
  call luaeval('findr.reset()')
  let s:selected_loc = min([line('$'), s:start_loc+1])
  let s:old_dir = s:cur_dir
  let s:hist_jump_from = getcwd()
  let s:cur_dir = getcwd()
  call setline(s:start_loc, s:short_path())
  normal $
  startinsert!
  call findr#redraw()
endfunction

function! findr#bs()
  let curline = getline(s:start_loc)
  if curline !='' && split(curline,'\c')[-1] == '/'
    call findr#parent_dir()
  else
    let [_b, line, col, _col] = getpos('.')
    let curline=curline[0:col-3] . curline[col-1:]
    call setline(s:start_loc, curline)
    call cursor('.', col-1)
  endif
endfunction

function! findr#clear()
  let [_b, line, col, _col] = getpos('.')
  let curline = getline(s:start_loc)
  let index = match(curline, '[^/]*$')-1
  call setline(s:start_loc, curline[:index].curline[col-1:])
  call cursor('.', index+2)
endfunction

function! findr#edit()
  let choice = findr#get_choice()
  if s:selected_loc == s:start_loc
    let choice = findr#get_input()
  endif
  call findr#write_hist(choice)
  execute s:winnum . "windo edit " . s:cur_dir . '/' . choice
  call findr#quit()
endfunction

function! findr#quit()
  call luaeval('findr.reset()')
  execute s:winnum . 'windo echo ""'
  bw findr
endfunction

function! findr#launch()
  let s:hist_loc = 0
  if s:histfile != -1
    call findr#source_hist(s:histfile)
  endif
  let s:winnum = winnr()
  let s:selected_loc = s:start_loc+1
  let s:cur_dir = getcwd()
  let s:hist_jump_from = getcwd()
  let s:old_input = -1
  let s:old_dir = -1
  if s:use_floating_win
    call findr#floating()
  else
    execute "botright 10split findr"
  endif
  call setline(s:start_loc, s:short_path())
  set ft=findr
  call findr#redraw()
  normal $
  startinsert!
endfunction
" }}}
" }}}
" Mappings: {{{
inoremap <silent> <plug>findr_cd <cmd>call findr#change_dir()<cr>
inoremap <silent> <plug>findr_next <cmd>call findr#next_item()<cr>
inoremap <silent> <plug>findr_prev <cmd>call findr#prev_item()<cr>
inoremap <silent> <plug>findr_parent_dir <cmd>call findr#parent_dir()<cr>
inoremap <silent> <plug>findr_bs <cmd>call findr#bs()<cr>
inoremap <silent> <plug>findr_clear <cmd>call findr#clear()<cr>
inoremap <silent> <plug>findr_edit <esc>:<c-u>call findr#edit()<cr>
inoremap <silent> <plug>findr_quit <esc>:<c-u>call findr#quit()<cr>
inoremap <silent> <plug>findr_hist_next <cmd>call findr#next_hist()<cr>
inoremap <silent> <plug>findr_hist_prev <cmd>call findr#prev_hist()<cr>
" }}}
" vim: set sw=2 ts=2 sts=2 et tw=80 ft=vim fdm=marker:
