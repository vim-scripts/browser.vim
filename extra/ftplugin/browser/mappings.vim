" File Name: mappings.vim
" Maintainer: Moshe Kaminsky <kaminsky@math.huji.ac.il>
" Last Update: September 26, 2004
" Description: mappings for browser windows. Part of the browser plugin
" Version: 0.4

nnoremap <silent> <buffer>  :BrowserFollow<CR>
nnoremap <silent> <buffer> g<LeftMouse> :BrowserFollow<CR>
nnoremap <silent> <buffer> <C-LeftMouse> :BrowserFollow<CR>
nnoremap <silent> <buffer>  :execute v:count1 . 'BrowserBack'<CR>
nnoremap <silent> <buffer> g<RightMouse> 
      \:execute v:count1 . 'BrowserBack'<CR>
nnoremap <silent> <buffer> <C-RightMouse> 
      \:execute v:count1 . 'BrowserBack'<CR>
nnoremap <silent> <buffer> <Tab> :execute v:count1 . 'BrowserNextLink'<CR>
nnoremap <silent> <buffer> <S-Tab> :execute v:count1 . 'BrowserPrevLink'<CR>
nnoremap <silent> <buffer> <C-N> :execute v:count1 . 'BrowserNextChoice'<CR>
nnoremap <silent> <buffer> <C-P> :execute v:count1 . 'BrowserPrevChoice'<CR>
nnoremap <silent> <buffer> <C-Up> 
      \:execute v:count1 . 'BrowserTextScrollDown'<CR>
nnoremap <silent> <buffer> <C-Down> 
      \:execute v:count1 . 'BrowserTextScrollUp'<CR>
if g:browser_page_modifiable
  nnoremap <silent> <buffer> <CR> :BrowserClick<CR>
else
  nmap <silent> <buffer> <CR> :BrowserClick<CR><C-L>
  inoremap <silent> <buffer> <C-L> <C-O><C-L>
  cnoremap <buffer> <C-L> <Nop>
end
nnoremap <silent> <buffer> <space> <C-F>
nnoremap <silent> <buffer> b <C-B>
nnoremap <silent> <buffer> q :q<CR>
nnoremap <silent> <buffer> <C-R> :Reload<CR>
imap <silent> <buffer> <Tab> <Esc><Tab>
imap <silent> <buffer> <S-Tab> <Esc><S-Tab>
imap <silent> <buffer> <CR> <Esc>

