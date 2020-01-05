if exists("b:current_syntax")
  finish
endif
syn match FindrDirPartial '^.*/'
syn match FindrDir '^.*/$'
