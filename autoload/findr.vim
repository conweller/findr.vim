function! findr#winopts()
  let [max_height, max_width] = [g:findr_floating_window.max_height, g:findr_floating_window.max_width]
  let height = min([&lines - 4, max_height])
  let width = min([&columns - 4, max_width])
  let row = 1
  let col = 1

  if g:findr_floating_window.position == 'center'
      let col = float2nr((&columns - width)/2)
      let row = float2nr((&lines - height)/2)
  end

  return {
       \ 'relative': 'editor',
       \ 'col': col,
       \ 'row': row,
       \ 'height': height,
       \ 'width': width,
       \ 'style': 'minimal',
       \ }
endfunction

