" File Name: browser_extra.vim
" Maintainer: Moshe Kaminsky
" Last Update: November 12, 2004
" Description: extra browser commands. Part of the browser plugin.
" Version: 1.0

" don't run twice or when 'compatible' is set
if exists('g:browser_extra_version') || &compatible
  finish
endif
let g:browser_extra_version = g:browser_plugin_version

"""" searching """"
command! -bang -bar -nargs=+ -complete=custom,BrowserSearchSrvComplete 
          \SearchUsing call BrowserSearchUsing(<q-bang>, <q-args>)

if ! exists('g:browser_search_engine')
  let g:browser_search_engine = 'google'
endif

command! -bang -bar -nargs=* Search 
        \call BrowserSearchUsing(<q-bang>, 
                                \g:browser_search_engine . ' ' . <q-args>)

vnoremap <unique> <silent> <C-S> 
      \<C-C>:
      \call <SID>saveReg('s')<CR>gv"sy:
      \Search <C-R>s<CR>:
      \let @s=<SID>saveReg('s')<CR>

nnoremap <unique> <C-S> :Search<CR>

function! <SID>saveReg(reg)
  let res = exists('s:saved_' . a:reg) ? s:saved_{a:reg} : ''
  let s:saved_{a:reg} = getreg(a:reg)
  return res
endfunction

if !exists('g:browser_keyword_search')
  let g:browser_keyword_search = 'dictionary'
endif

command! -bang -bar -nargs=* Keyword 
        \call BrowserSearchUsing(<q-bang>, 
                                \g:browser_keyword_search . ' ' .<q-args>)


nnoremap <unique> <C-K> :Keyword<CR>

" search using google
command! -bang -bar -nargs=* Google SearchUsing<bang> google <args>

" dictionary search
command! -bang -bar -nargs=? Dictionary SearchUsing<bang> dictionary <args>

command! -bang -bar -nargs=* Thesaurus SearchUsing<bang> thesaurus <args> 

"""" vim site stuff """"

" search for a script/tip
command! -bar -bang -nargs=+ -complete=custom,BrowserVimSearchTypes VimSearch 
      \call BrowserVimSearch(<q-bang>,  <q-args>)

" go to a given script/tip by number
command! -bar -nargs=1 VimScript 
      \Browse http://vim.sourceforge.net/scripts/script.php?script_id= <args>
command! -bar -nargs=1 VimTip 
      \Browse http://vim.sourceforge.net/tips/tip.php?tip_id= <args>

function! BrowserVimSearchTypes(...)
  return "script\ncolorscheme\nftplugin\ngame\nindent\nsyntax\nutility\ntip"
endfunction

function! BrowserVimSearch(Bang, Args)
  if a:Bang == '!'
    let g:browser_sidebar = 'VimSearch'
  endif
  perl <<EOF
  use VIM::Browser;
  local $_ = VIM::Eval('a:Args');
  my $type = $1 if s/^\s*(\w+)//o;
  $type = '' if $type eq 'script';
  my $uri = 'http://vim.sourceforge.net/' .
    ( $type eq 'tip' ? 
      'tips/tip_search_results.php?' :
      "scripts/script_search_results.php?script_type=$type&" ) . 'keywords=';
  VIM::Browser::browse("$uri $_");
EOF
  let g:browser_sidebar = 0
endfunction
  
function! BrowserSearchUsing(Bang, Args)
  let service = matchstr(a:Args, '^[^ ]*')
  let words = substitute(a:Args, '^[^ ]* *', '', '')
  if ! strlen(words)
    let words = expand('<cword>')
  endif
  if a:Bang == '!'
    let g:browser_sidebar = service
  endif
  execute 'Browse :_search:' . service . ' ' . words
  let g:browser_sidebar = 0
endfunction

function! BrowserSearchSrvComplete(Arg, CmdLine, Pos)
  let result = BrowserCompleteBrowse(':_search:', a:CmdLine, a:Pos)
  let result = substitute(result, ':_search:', '', 'g')
  return result
endfunction
