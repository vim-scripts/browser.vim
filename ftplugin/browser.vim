" File Name: browser.vim
" Maintainer: Moshe Kaminsky
" Last Update: September 02, 2004
" Description: settings for a browser buffer. part of the browser plugin
" Version: 0.2

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
if has('conceal')
  setlocal conceallevel=2
endif
let &winheight=&helpheight
