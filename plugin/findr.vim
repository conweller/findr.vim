let g:findr_history =  expand('<sfile>:h:r') . '/../.findr_history'
lua findr = require('findr')

" call findr#source_hist(s:histfile)

" command! Findr call findr#launch()
command! Findr lua findr.controller.init()

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
