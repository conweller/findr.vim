if !exists('g:findr_history')
    let g:findr_history =  expand('<sfile>:h:r') . '/../.findr_history'
end
let s:findr_lua_loc =  expand('<sfile>:h:r') . '/../lua/'
if !exists('g:findr_enable_border')
  let g:findr_enable_border = 1
endif

if !exists('g:findr_floating_window')
  let g:findr_floating_window = 1
endif

if !exists('g:findr_highlight_matches')
  let g:findr_highlight_matches = 1
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

exe "lua package.path = package.path .. ';". s:findr_lua_loc."?/init.lua'"
exe "lua package.path = package.path .. ';". s:findr_lua_loc."?.lua'"
lua findr = require('findr')
lua sources = require('findr/sources')

function! FindrLaunch(source, ...)
    if a:0
        exe 'lua findr.init('.a:source.', "'. a:000[0] .'")'
    else
        exe 'lua findr.init('.a:source.', "./")'
    endif
endfunction

command! -complete=dir -nargs=? Findr call FindrLaunch('sources.files', <f-args>)
command! FindrBuffers call FindrLaunch('sources.buffers', './')
command! FindrLocList call FindrLaunch('sources.loclist', './')
command! FindrQFList call FindrLaunch('sources.qflist', './')

if !highlight_exists('FindrMatch')
  hi! link FindrMatch search
endif

if !highlight_exists('FindrSelected')
  hi! link FindrSelected CursorLine
endif

if !highlight_exists('FindrDirPartial')
  hi! link FindrDirPartial string
endif

if !highlight_exists('FindrDir')
  hi! link FindrDir directory
endif

if !highlight_exists('FindrBorder')
  hi! link FindrBorder Comment
endif

if !highlight_exists('FindrNormal')
  hi! link FindrNormal Normal
endif
sign define findrselected linehl=FindrSelected

