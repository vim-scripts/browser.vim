" File Name: browser.vim
" Maintainer: Moshe Kaminsky <kaminsky@math.huji.ac.il>
" Last Update: August 10, 2004
" Description: web browser plugin for vim
" Version: 0.1
"

" don't run twice
if exists(':Browse')
  finish
endif

""""""""""" Settings """"""""""""""""
" markup
let g:browser_bold_start='_*'
let g:browser_bold_end='*_'
let g:browser_bold_highlight='Bold'
let g:browser_italic_start='_/'
let g:browser_italic_end='/_'
let g:browser_italic_highlight='UnderLine'

" bookmarks
let g:browser_addrbook_dir = $HOME . '/.vim/addressbooks/'
let g:browser_default_addrbook = 'default'

" scheme handlers
let g:browser_mailto_handler = 'xterm -e mutt %s &'
let g:browser_ftp_handler = 'xterm -e ncftp %s &'

let g:browser_assumed_encoding = 'utf-8'

let g:browser_from_header = $EMAIL

"""""""""""""" commands """""""""""""""""""
" opening
command! -nargs=1 -complete=custom,CompleteBrowse Browse call Browse(<f-args>)
command! -bang -nargs=1 -complete=custom,CompleteBrowse SBrowse 
      \call Browse(<f-args>, <q-bang>)
command! Follow call Follow()
command! -nargs=? -complete=dir SaveLink call SaveLink(<f-args>)
command! Reload call Reload()

" history
command! -range=1 Back call Back(<count>)
command! -range=1 Pop call Back(<count>)
command! -range=1 Forward call Forward(<count>)
command! -range=1 Tag call Forward(<count>)
command! History call History()
command! Tags call History()

" bookmarks
command! -nargs=1 -bang Bookmark call Bookmark(<f-args>, <q-bang>)
command! -nargs=1 -bang -complete=custom,CompleteBkmkFile AddrBook 
      \call ChangeBookmarkFile(<f-args>, <q-bang>)
command! -nargs=? -complete=custom,CompleteBkmkFile ListBookmarks 
      \call ListBookmarks(<f-args>)

" other
command! ShowHeader call ShowHeader()
command! HideHeader call HideHeader()
command! -bang ViewSource call ViewSource(<q-bang>)
command! -range=1 NextLink call NextLink(<count>)
command! -range=1 PrevLink call PrevLink(<count>)

"""""""""""""""""""""""""""""""""""""""""""""""
" add <dir>/perl to the perl include path, for each dir in runtimepath. This 
" way we can install the modules in a vim directory, instead of the global 
" perl directory. We insert them in reverse order to preserve the meaning: 
" stuff in the home directory takes precedence over global stuff, etc.
perl <<EOF
my $rtp = VIM::Eval('&runtimepath');
my @path = split /,/, $rtp;
unshift @INC, "$_/perl/" foreach @path;
EOF

""""""""""""" autocommands """"""""""""""""""""
augroup Browser
  au!
  autocmd WinEnter *-* call UpdateInstance()
  autocmd BufWipeout *-* call CleanBuf(expand("<afile>"))
  autocmd CursorHold *-* call ShowLinkTarget()
augroup END

"""""""""""""" functions """""""""""""""""""""""
function! UpdateInstance()
  if exists('w:browserId')
    perl VIM::Browser::winChanged
  endif
endfunction

function! CleanBuf(Buf)
  perl <<EOF
  my $buf = VIM::Eval('a:Buf');
  VIM::Browser::cleanBuf($buf);
EOF
endfunction

function! ShowLinkTarget()
  if exists('w:browserId')
    perl VIM::Browser::showLinkTarget
  endif
endfunction

function! Browse(File, ...)
  perl << EOF
  use VIM::Browser;
  my $uri = VIM::Eval('a:File');
  my $split = VIM::Eval('a:0');
  if ($split) {
    my $dir = VIM::Eval('a:1');
    VIM::Browser::browse($uri, $dir);
  } else {
    VIM::Browser::browse($uri);
  }
EOF
endfunction

function! Follow()
  perl VIM::Browser::follow
endfunction

function! Reload()
  perl VIM::Browser::reload
endfunction

function! Back(...)
  perl << EOF
  my $Offset = VIM::Eval('a:0 ? a:1 : 1');
  VIM::Browser::goHist(-$Offset);
EOF
endfunction
  
function! Forward(...)
  perl << EOF
  my $Offset = VIM::Eval('a:0 ? a:1 : 1');
  VIM::Browser::goHist($Offset);
EOF
endfunction

function! ShowHeader()
  perl VIM::Browser::addHeader
endfunction

function! HideHeader()
  perl VIM::Browser::removeHeader
endfunction

function! History()
  perl VIM::Browser::showHist
endfunction

function! ViewSource(dir)
  perl << EOF
  my $dir = VIM::Eval('a:dir');
  VIM::Browser::viewSource($dir)
EOF
endfunction

function! NextLink(count)
  perl << EOF
  my $count = VIM::Eval('a:count');
  VIM::Browser::findNextLink($count);
EOF
endfunction

function! PrevLink(count)
  perl << EOF
  my $count = VIM::Eval('a:count');
  VIM::Browser::findNextLink(-$count);
EOF
endfunction

function! Bookmark(name, del)
  perl << EOF
  my $name = VIM::Eval('a:name');
  my $del = VIM::Eval('a:del');
  VIM::Browser::bookmark($name, $del);
EOF
endfunction

function! ChangeBookmarkFile(file, create)
  perl << EOF
  use VIM::Browser;
  my $file = VIM::Eval('a:file');
  my $create = VIM::Eval('a:create');
  VIM::Browser::changeBookmarkFile($file, $create);
EOF
endfunction

function! ListBookmarks(...)
  let file = a:0 ? a:1 : ''
  perl << EOF
  use VIM::Browser;
  my $file = VIM::Eval('file');
  VIM::Browser::listBookmarks($file);
EOF
endfunction

function! SaveLink(...)
  let file = a:0 ? a:1 : ''
  perl << EOF
  my $file = VIM::Eval('file');
  VIM::Browser::saveLink($file);
EOF
endfunction

function! CompleteBkmkFile(...)
  perl <<EOF
  use VIM::Browser;
  $Vim::Variable{'result'} = VIM::Browser::listBookmarkFiles();
EOF
  return result
endfunction

function! CompleteBrowse(Arg, CmdLine, Pos)
  perl <<EOF
  use VIM::Browser;
  $$_ = $Vim::Variable{"a:$_"} foreach qw(Arg CmdLine Pos);
  $Vim::Variable{'result'} = VIM::Browser::listBrowse($Arg, $CmdLine, $Pos);
EOF
  return result
endfunction

