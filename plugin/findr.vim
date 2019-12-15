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
