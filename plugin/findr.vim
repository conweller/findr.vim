let s:histfile =  expand('<sfile>:h:r') . '/../.findr_history'

call findr#source_hist(s:histfile)

command! Findr call findr#launch()

if !highlight_exists('FindrSelected')
  hi! link FindrSelected search
endif

if !highlight_exists('FindrSelectedDir')
  hi! link FindrSelectedDir search
endif

if !highlight_exists('FindrSelectedDirPartial')
  hi! link FindrSelectedDirPartial search
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
