setlocal ft=findr.findr-files


imap <buffer><nowait> / <plug>findr_cd
imap <buffer><nowait> <tab> <plug>findr_cd
imap <buffer><nowait> <c-l> <plug>findr_cd


if has('nvim')
    imap <buffer><nowait> <m-p>  <plug>findr_hist_prev
    imap <buffer><nowait> <s-up>  <plug>findr_hist_prev
    imap <buffer><nowait> <m-n>  <plug>findr_hist_next
    imap <buffer><nowait> <s-down>  <plug>findr_hist_next
end
