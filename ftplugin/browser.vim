" File Name: browser.vim
" Maintainer: Moshe Kaminsky
" Last Modified: Mon 22 Nov 2004 08:02:28 AM IST
" Description: settings for a browser buffer. part of the browser plugin
" Version: 1.0

" make sure the browser buffers are not associated with any files
setlocal buftype=nofile
setlocal nobuflisted
setlocal bufhidden=hide
setlocal noswapfile
" folding is used only for the header fields
setlocal foldmethod=marker
" the only editing that should be going on is text inputs in forms. Make sure 
" we don't get any extra lines there
setlocal formatoptions=

if g:browser_page_modifiable
  if maparg('<Esc>', 'i')
    iunmap <Esc>
  endif
else
  setlocal nomodifiable
  inoremap <buffer> <silent> <Esc> <Esc>:setlocal nomodifiable<CR>
endif

setlocal linebreak
if strlen(g:browser_sidebar) > 1
  setlocal nowrap
endif

