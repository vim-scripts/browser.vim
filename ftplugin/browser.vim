" File Name: browser.vim
" Maintainer: Moshe Kaminsky
" Last Update: August 10, 2004
" Description: settings for a browser buffer. part of the browser plugin
" Version: 0.1

setlocal buftype=nofile
setlocal nobuflisted
setlocal bufhidden=hide
setlocal foldmethod=marker
setlocal noswapfile
if has('conceal')
  setlocal conceallevel=2
endif
let &winheight=&helpheight

nmap <buffer>  :Follow<CR>
nmap <buffer> g<LeftMouse> :Follow<CR>
nmap <buffer> <C-LeftMouse> :Follow<CR>
nmap <buffer>  :execute v:count1 . 'Back'<CR>
nmap <buffer> g<RightMouse> :execute v:count1 . 'Back'<CR>
nmap <buffer> <C-RightMouse> :execute v:count1 . 'Back'<CR>
nmap <buffer> <Tab> :execute v:count1 . 'NextLink'<CR>
nmap <buffer> <S-Tab> :execute v:count1 . 'PrevLink'<CR>

