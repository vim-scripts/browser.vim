" File Name: browser.vim
" Maintainer: Moshe Kaminsky <kaminsky@math.huji.ac.il>
" Last Modified: Mon 22 Nov 2004 09:24:19 AM IST
" Description: web browser plugin for vim
" Version: 1.0
" GetLatestVimScripts: 1128 1 synmark.vim
"

" don't run twice or when 'compatible' is set
if exists('g:browser_plugin_version') || &compatible
  finish
endif
let g:browser_plugin_version = 1.0

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

let g:browser_break_lines = 1

let g:browser_sidebar_width = 25

let g:browser_sidebar = 0

let s:browser_install_dir = expand('<sfile>:p:h:h')

"""""""""""""" commands """""""""""""""""""
" long commands. The short versions from version 0.1 are in browser_short.vim

" opening
command! -bar -nargs=+ -complete=custom,BrowserCompleteBrowse Browse 
      \call BrowserBrowse(<q-args>)
command! -bar -bang -nargs=+ -complete=custom,BrowserCompleteBrowse 
      \BrowserSplit call BrowserBrowse(<q-args>, <q-bang>)
command! -bar BrowserFollow call BrowserFollow()
command! -bar BrowserSubmit call BrowserSubmit()
command! -bar -nargs=? -complete=dir BrowserSaveLink 
      \call BrowserSaveLink(<f-args>)
command! -bar -bang BrowserReload call BrowserReload(<q-bang>)

" history
command! -bar -range=1 BrowserBack call BrowserBack(<count>)
command! -bar -range=1 BrowserPop call BrowserBack(<count>)
command! -bar -range=1 BrowserForward call BrowserForward(<count>)
command! -bar -range=1 BrowserTag call BrowserForward(<count>)
command! -bar BrowserTags call BrowserHistory()
command! -bang -bar BrowserHistory if strlen(<q-bang>) | 
      \BrowserSideBar BrowserHistory | else | Browse history:// | endif

" bookmarks
command! -bar -nargs=1 -bang BrowserBookmark 
      \call BrowserBookmark(<f-args>, <q-bang>)
command! -bar -nargs=1 -bang -complete=custom,BrowserCompleteBkmkFile 
      \BrowserAddrBook call BrowserChangeBookmarkFile(<f-args>, <q-bang>)
command! -bar -nargs=? -complete=custom,BrowserCompleteBkmkFile 
      \BrowserListBookmarks call BrowserListBookmarks(<f-args>)
command! -bang -bar -nargs=? -complete=custom,BrowserCompleteBkmkFile 
      \BrowserBookmarksPage if strlen(<q-bang>) | 
      \BrowserSideBar BrowserBookmarksPage <args> | 
      \else | Browse :<args>: | endif

" forms
command! -bar -range=1 BrowserNextChoice call BrowserNextChoice(<count>)
command! -bar -range=1 BrowserPrevChoice call BrowserPrevChoice(<count>)
command! -bar BrowserClick call BrowserClick()
command! -bar -range=1 BrowserTextScrollUp call BrowserTextScroll(<count>)
command! -bar -range=1 BrowserTextScrollDown call BrowserTextScroll(-<count>)

" inline images
command! -bar -nargs=? -complete=dir BrowserImageSave 
      \call BrowserImage('save', <f-args>)
command! -bar BrowserImageView call BrowserImage('default')
command! -bar BrowserImage call BrowserImage('ask')

" other
command! -bar BrowserShowHeader call BrowserShowHeader()
command! -bar BrowserHideHeader call BrowserHideHeader()
command! -bar -bang BrowserViewSource call BrowserViewSource(<q-bang>)
command! -bar -range=1 BrowserNextLink call BrowserNextLink(<count>)
command! -bar -range=1 BrowserPrevLink call BrowserPrevLink(<count>)
command! -bar -nargs=+ -complete=command BrowserSideBar 
      \let g:browser_sidebar = matchstr(<q-args>, '^\S*') | 
      \<args> | let g:browser_sidebar = 0
command! -bar CloseSideBar perl VIM::Browser::closeSidebar;


""""""""""""" autocommands """"""""""""""""""""
" autocommands are installed only after the first call to a browser function
function! s:InstallAutoCommands()
  augroup Browser
    au!
    autocmd VimLeavePre * call s:VimLeavePre()
    autocmd BufEnter * call s:BufEnter()
    autocmd BufLeave VimBrowser:-*/*- call s:BufLeave()
    autocmd BufWinEnter VimBrowser:-*/*- call s:BufWinEnter(expand('<abuf>'))
    autocmd BufWinLeave VimBrowser:-*/*- call s:BufWinLeave(expand('<abuf>'))
    autocmd BufUnload VimBrowser:-*/*- call s:BufUnload(expand("<abuf>"))
    autocmd CursorHold VimBrowser:-*/*- call s:CursorHold()

    autocmd BufEnter Browser-TextArea-* resize 10
    autocmd BufLeave Browser-TextArea-* call s:SetTextArea()
  augroup END
endfunction

function! s:VimLeavePre()
  perl VIM::Browser::saveHist;
endfunction

function! s:BufEnter()
  if exists('w:browserId')
    perl VIM::Browser::winChanged
    resize 999
    menu .1 PopUp.View\ Source :BrowserViewSource<CR>
    menu .1 PopUp.Reload :BrowserReload<CR>
  endif
endfunction

function! s:BufLeave()
  silent! unmenu PopUp.Follow\ Link
  silent! unmenu PopUp.Save\ Link
  silent! unmenu PopUp.View\ Image
  silent! unmenu PopUp.Save\ Image
  silent! unmenu PopUp.Back
  silent! unmenu PopUp.Forward
  silent! unmenu PopUp.View\ Source
  silent! unmenu PopUp.Reload
endfunction

function! s:BufWinEnter(bufnr)
  perl <<EOF
  my $buf = VIM::Eval('a:bufnr');
  VIM::Browser::setWindowPage($buf);
EOF
endfunction

function! s:BufWinLeave(bufnr)
  perl <<EOF
  my $buf = VIM::Eval('a:bufnr');
  VIM::Browser::bufWinLeave($buf);
EOF
endfunction

function! s:BufUnload(Buf)
  perl <<EOF
  my $buf = VIM::Eval('a:Buf');
  VIM::Browser::bufUnload($buf);
EOF
endfunction

function! s:CursorHold()
  perl VIM::Browser::showLinkTarget
endfunction

function! s:SetTextArea()
  perl VIM::Browser::setTextArea
endfunction

"""""""""""""" functions """""""""""""""""""""""
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

function! BrowserSubmit()
  perl VIM::Browser::submit
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

" return the uri of the current page
function! BrowserGetUri()
  perl <<EOF
  use VIM::Browser;
  if ( my $page = $VIM::Browser::CurWin->page ) {
    $Vim::Variable{'result'} = "$page";
  } else {
    $Vim::Variable{'result'} = '';
  }
EOF
  return result
endfunction

"""" completion """"
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
