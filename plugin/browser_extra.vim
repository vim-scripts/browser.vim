" File Name: browser_extra.vim
" Maintainer: Moshe Kaminsky
" Last Update: September 03, 2004
" Description: extra browser commands. Part of the browser plugin.
" Version: 0.2

" don't run twice or when 'compatible' is set
if exists('g:browser_extra_version') || &compatible
  finish
endif
let g:browser_extra_version = g:browser_plugin_version

" search using google
command! -bar -nargs=+ Google Browse http://www.google.com/search?q= <args>

" vim site stuff

" search for a script/tip
command! -bar -nargs=+ -complete=custom,BrowserVimSearchTypes VimSearch 
      \call BrowserVimSearch(<q-args>)

" go to a given script/tip by number
command! -bar -nargs=1 VimScript 
      \Browse http://vim.sourceforge.net/scripts/script.php?script_id= <args>
command! -bar -nargs=1 VimTip 
      \Browse http://vim.sourceforge.net/tips/tip.php?tip_id= <args>

function! BrowserVimSearchTypes(...)
  return "script\ncolorscheme\nftplugin\ngame\nindent\nsyntax\nutility\ntip"
endfunction

function! BrowserVimSearch(Args)
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
endfunction
  
