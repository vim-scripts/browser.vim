" File Name: browser.vim
" Maintainer: Moshe Kaminsky <kaminsky@math.huji.ac.il>
" Last Update: September 26, 2004
" Description: web browser plugin for vim
" Version: 0.4
"

" don't run twice or when 'compatible' is set
if exists('g:browser_plugin_version') || &compatible
  finish
endif
let g:browser_plugin_version = 0.4

" add <dir>/perl to the perl include path, for each dir in runtimepath. This 
" way we can install the modules in a vim directory, instead of the global 
" perl directory. We insert them in reverse order to preserve the meaning: 
" stuff in the home directory takes precedence over global stuff, etc.
" Use this opportunity to bail out if there is no perl support
if has('perl')
  function! s:AddIncludePath()
    perl <<EOF
      use File::Spec;
      my $rtp = VIM::Eval('&runtimepath');
      my @path = split /,/, $rtp;
      unshift @INC, File::Spec->catdir($_, 'perl') foreach @path;
EOF
  endfunction
  call s:AddIncludePath()
  delfunction s:AddIncludePath
else
  echoerr 'The browser plugin requires a perl enabled vim. Sorry!'
  finish
end

""""""""""" Settings """"""""""""""""
" These are default settings. Can be overridden in some 
" after/plugin/browser.vim

" markup
let g:browser_bold_start='_*'
let g:browser_bold_end='*_'
";x let g:browser_bold_highlight='Bold'
let g:browser_italic_start='_/'
let g:browser_italic_end='/_'
";x let g:browser_italic_highlight='Function'
let g:browser_underline_start='_-'
let g:browser_underline_end='-_'

" directory where all the data is kept. Default is the 'browser' subdir of the
" first writeable component of 'runtimepath'
";x let g:browser_data_dir = $HOME . '/.vim/browser/'

" bookmarks
" The directory where all bookmark files are stored.
" set to empty to disable bookmarks
";x let g:browser_addrbook_dir = ''

let g:browser_default_addrbook = 'default'

" scheme handlers: nice examples for unix
let g:browser_mailto_handler = 'xterm -e mutt %s &'
let g:browser_ftp_handler = 'xterm -e ncftp %s &'

let g:browser_assumed_encoding = 'utf-8'

";x let g:browser_cookies_file = g:browser_data_dir . '/cookies.txt';

let g:browser_from_header = $EMAIL

let g:browser_page_modifiable = 0

"""""""""""""" commands """""""""""""""""""
" long commands. The short versions from version 0.1 are in browser_short.vim

" opening
command! -bar -nargs=+ -complete=custom,BrowserCompleteBrowse Browse 
      \call BrowserBrowse(<q-args>)
command! -bar -bang -nargs=+ -complete=custom,BrowserCompleteBrowse 
      \BrowserSplit call BrowserBrowse(<q-args>, <q-bang>)
command! -bar BrowserFollow call BrowserFollow()
command! -bar -nargs=? -complete=dir BrowserSaveLink 
      \call BrowserSaveLink(<f-args>)
command! -bar -bang BrowserReload call BrowserReload(<q-bang>)

" history
command! -bar -range=1 BrowserBack call BrowserBack(<count>)
command! -bar -range=1 BrowserPop call BrowserBack(<count>)
command! -bar -range=1 BrowserForward call BrowserForward(<count>)
command! -bar -range=1 BrowserTag call BrowserForward(<count>)
command! -bar BrowserHistory call BrowserHistory()
command! -bar BrowserTags call BrowserHistory()

" bookmarks
command! -bar -nargs=1 -bang BrowserBookmark 
      \call BrowserBookmark(<f-args>, <q-bang>)
command! -bar -nargs=1 -bang -complete=custom,BrowserCompleteBkmkFile 
      \BrowserAddrBook call BrowserChangeBookmarkFile(<f-args>, <q-bang>)
command! -bar -nargs=? -complete=custom,BrowserCompleteBkmkFile 
      \BrowserListBookmarks call BrowserListBookmarks(<f-args>)

" forms
command! -bar -range=1 BrowserNextChoice call BrowserNextChoice(<count>)
command! -bar -range=1 BrowserPrevChoice call BrowserPrevChoice(<count>)
command! -bar BrowserClick call BrowserClick()
command! -bar -range=1 BrowserTextScrollUp call BrowserTextScroll(<count>)
command! -bar -range=1 BrowserTextScrollDown call BrowserTextScroll(-<count>)

" other
command! -bar BrowserShowHeader call BrowserShowHeader()
command! -bar BrowserHideHeader call BrowserHideHeader()
command! -bar -bang BrowserViewSource call BrowserViewSource(<q-bang>)
command! -bar -range=1 BrowserNextLink call BrowserNextLink(<count>)
command! -bar -range=1 BrowserPrevLink call BrowserPrevLink(<count>)
command! -bar -nargs=? -complete=dir BrowserImageSave 
      \call BrowserImage('save', <f-args>)

""""""""""""" autocommands """"""""""""""""""""
augroup Browser
  au!
  autocmd WinEnter VimBrowser:-*/*- call BrowserUpdateInstance()
  autocmd BufWipeout VimBrowser:-*/*- call BrowserCleanBuf(expand("<afile>"))
  autocmd CursorHold VimBrowser:-*/*- call BrowserShowLinkTarget()
  autocmd BufLeave Browser-TextArea-* call BrowserSetTextArea()
  autocmd WinEnter Browser-TextArea-* resize 10
augroup END

"""""""""""""" functions """""""""""""""""""""""
function! BrowserUpdateInstance()
  perl VIM::Browser::winChanged
endfunction

function! BrowserCleanBuf(Buf)
  perl <<EOF
  my $buf = VIM::Eval('a:Buf');
  VIM::Browser::cleanBuf($buf);
EOF
endfunction

function! BrowserShowLinkTarget()
  perl VIM::Browser::showLinkTarget
endfunction

function BrowserSetTextArea()
  perl VIM::Browser::setTextArea
endfunction

function! BrowserBrowse(File, ...)
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

function! BrowserFollow()
  perl VIM::Browser::follow
endfunction

function! BrowserReload(force)
  perl <<EOF
  my $force = VIM::Eval('a:force');
  VIM::Browser::reload($force);
EOF
endfunction

function! BrowserBack(...)
  perl <<EOF
  my $Offset = VIM::Eval('a:0 ? a:1 : 1');
  VIM::Browser::goHist(-$Offset);
EOF
endfunction
  
function! BrowserForward(...)
  perl << EOF
  my $Offset = VIM::Eval('a:0 ? a:1 : 1');
  VIM::Browser::goHist($Offset);
EOF
endfunction

function! BrowserShowHeader()
  perl VIM::Browser::addHeader
endfunction

function! BrowserHideHeader()
  perl VIM::Browser::removeHeader
endfunction

function! BrowserHistory()
  perl VIM::Browser::showHist
endfunction

function! BrowserViewSource(dir)
  perl << EOF
  my $dir = VIM::Eval('a:dir');
  VIM::Browser::viewSource($dir)
EOF
endfunction

function! BrowserNextLink(count)
  perl << EOF
  my $count = VIM::Eval('a:count');
  VIM::Browser::findNextLink($count);
EOF
endfunction

function! BrowserPrevLink(count)
  perl << EOF
  my $count = VIM::Eval('a:count');
  VIM::Browser::findNextLink(-$count);
EOF
endfunction

function! BrowserClick()
  perl VIM::Browser::clickInput
endfunction

function! BrowserNextChoice(count)
  perl << EOF
  my $count = VIM::Eval('a:count');
  VIM::Browser::nextInputChoice($count);
EOF
endfunction

function! BrowserPrevChoice(count)
  perl << EOF
  my $count = VIM::Eval('a:count');
  VIM::Browser::nextInputChoice(-$count);
EOF
endfunction

function! BrowserTextScroll(count)
  perl <<EOF
  my $count = VIM::Eval('a:count');
  VIM::Browser::scrollText($count);
EOF
endfunction

function! BrowserBookmark(name, del)
  perl << EOF
  my $name = VIM::Eval('a:name');
  my $del = VIM::Eval('a:del');
  VIM::Browser::bookmark($name, $del);
EOF
endfunction

function! BrowserChangeBookmarkFile(file, create)
  perl << EOF
  use VIM::Browser;
  my $file = VIM::Eval('a:file');
  my $create = VIM::Eval('a:create');
  VIM::Browser::changeBookmarkFile($file, $create);
EOF
endfunction

function! BrowserListBookmarks(...)
  let file = a:0 ? a:1 : ''
  perl << EOF
  use VIM::Browser;
  my $file = VIM::Eval('file');
  VIM::Browser::listBookmarks($file);
EOF
endfunction

function! BrowserSaveLink(...)
  let file = a:0 ? a:1 : ''
  perl << EOF
  my $file = VIM::Eval('file');
  VIM::Browser::saveLink($file);
EOF
endfunction

function! BrowserImage(Action, ...)
  let arg = a:0 ? a:1 : ''
  perl << EOF
  my $action = VIM::Eval('a:Action');
  my $arg = VIM::Eval('arg');
  VIM::Browser::handleImage($action, $arg);
EOF
endfunction

function! BrowserCompleteBkmkFile(...)
  perl <<EOF
  use VIM::Browser;
  $Vim::Variable{'result'} = VIM::Browser::listBookmarkFiles();
EOF
  return result
endfunction

function! BrowserCompleteBrowse(Arg, CmdLine, Pos)
  perl <<EOF
  use VIM::Browser;
  $$_ = $Vim::Variable{"a:$_"} foreach qw(Arg CmdLine Pos);
  $Vim::Variable{'result'} = VIM::Browser::listBrowse($Arg, $CmdLine, $Pos);
EOF
  return result
endfunction


""" Vim modeline: (Must be the last line in the file!)
""" vim: set co=80 lines=25:
