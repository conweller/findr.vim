" Variables: {{{
let s:cur_dir = getcwd()
let s:start_loc = 1
let s:selected_loc = s:start_loc+1
let s:winnum = 1
" let s:use_virtual = v:true
let s:use_floating_win = v:true
let s:old_input = ''

" TODO: make this more portable
" let s:hist_file = 'Todo'
" let s:hist = readfile(s:hist_file)
" let s:hist_loc = len(s:hist) - 1
" }}}
" Logic: {{{
function! findr#get_input()
  let line = getline(s:start_loc)
  if line !='' && line[-1] != '/'
    return split(line. ' ', '/')[-1]
  endif
  return ''
endfunction

function! findr#get_choice()
  return getline(s:selected_loc)
endfunction

function! findr#gen_completion(inputs, candidates)
  let res = []
  for candidate in a:candidates
    let match = v:true
    for input in a:inputs
      let input = substitute(input, '\~', '\\\~', 'g')
      let input = substitute(input, '\*\+', '*', 'g')
      if match(tolower(candidate), tolower(input)) == -1
        let match = v:false
        break
      endif
    endfor
    if match
      if isdirectory(s:cur_dir . '/' . candidate)
        call add(res, candidate . '/')
      else
        call add(res, candidate)
      endif
    endif
  endfor
  return res
endfunction

function! s:str_compare_smaller(i1, i2)
  return strlen(a:i1) - strlen(a:i2)
endfunction

function! findr#list_files()
  let file_str = glob('*')."\n".glob('.[^.]*')
  let files = split(file_str,'\n')
  return sort(files, "s:str_compare_smaller")
endfunction

function! findr#update()
endfunction
" }}}
" UI: {{{
" Selection: {{{
function! findr#next_item()
  if s:selected_loc < line('$')
    let s:selected_loc += 1
  else
    let s:selected_loc = line('$')
  endif
  call findr#redraw_highlights()
endfunction

function GetSelected()
  return s:selected_loc
endfunction

function! findr#prev_item()
  if s:selected_loc > s:start_loc
    let s:selected_loc -=  1
  else
    let s:selected_loc = s:start_loc
  endif
  call findr#redraw_highlights()
endfunction
" }}}
" Display: {{{

function! s:tabline_visible()
  let tabnum = tabpagenr()
  let count = 0
  tabdo let count+=1
  execute tabnum.'tabnext'
  return count > 1 && &showtabline
endfunction

let s:border = v:true

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
  if s:border == v:true
    let top = "┌" . repeat("─", width - 2) . "┐"
    let mid = "│" . repeat(" ", width - 2) . "│"
    let bot = "└" . repeat("─", width - 2) . "┘"
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
  setlocal foldcolumn=1
  setlocal winhighlight=FoldColumn:Normal,Normal:Normal
endfunction

function! findr#redraw()
  call deletebufline('%', s:start_loc + 1, line('$'))
  let completions = findr#gen_completion(split(findr#get_input()), findr#list_files())
  call setline(s:start_loc-1, '')
  call setline(s:start_loc+1, completions)
  if s:old_input == s:cur_dir . '/' . findr#get_input()
    let s:selected_loc = min([s:selected_loc, line('$')])
  else
    let s:selected_loc = min([s:start_loc+1, line('$')])
  endif
  let s:old_input = s:cur_dir . '/' . findr#get_input()
  call findr#redraw_highlights()
endfunction

function! Input()
  return s:old_input == s:cur_dir . '/' . findr#get_input()
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
  if split(findr#get_input()) == ['~']
    lcd ~
  elseif split(findr#get_input()) == ['..']
    lcd ..
  elseif isdirectory(s:cur_dir . '/' . findr#get_choice())
    execute 'lcd ' . s:cur_dir . '/' . findr#get_choice()
  elseif split(findr#get_input()) != []
    if isdirectory(s:cur_dir . '/' . split(findr#get_input())[0])
      execute 'lcd ' . s:cur_dir . '/' . findr#get_input()
    else 
      return
    endif
  else
    return
  endif
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

function! findr#bs()
  let curline = getline(s:start_loc)
  if curline !='' && split(curline,'\c')[-1] == '/'
    execute 'lcd ..'
    let s:selected_loc = min([line('$'), s:start_loc+1])
    let s:cur_dir = getcwd()
    call setline(s:start_loc, s:short_path())
    normal $
    startinsert!
    call findr#redraw()
  else
    let [_b, line, _col, _o, col] = getcurpos()
    let curline=curline[0:col-3] . curline[col-1:]
    call setline(s:start_loc, curline)
    call cursor('.', col-1)
  endif
endfunction

function! findr#clear()
  let [_b, line, _col, _o, col] = getcurpos()
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
  execute s:winnum . "windo edit " . s:cur_dir . '/' . choice
  call findr#quit()
endfunction

function! findr#quit()
  execute s:winnum . 'windo echo ""'
  bw findr
endfunction

function! findr#cwd()
  echo s:cur_dir . '/' . findr#get_choice()
endfunction


function! findr#launch()
  let s:winnum = winnr()
  let s:selected_loc = s:start_loc+1
  let s:cur_dir = getcwd()
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
inoremap <silent> <plug>findr_bs <cmd>call findr#bs()<cr>
inoremap <silent> <plug>findr_clear <cmd>call findr#clear()<cr>
inoremap <silent> <plug>findr_edit <esc>:<c-u>call findr#edit()<cr>
inoremap <silent> <plug>findr_quit <esc>:<c-u>call findr#quit()<cr>
" }}}
" vim: set sw=2 ts=2 sts=2 et tw=80 ft=vim fdm=marker:
