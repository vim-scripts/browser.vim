" File Name: browser_short.vim
" Maintainer: Moshe Kaminsky <kaminsky@math.huji.ac.il>
" Last Update: September 26, 2004
" Description: short versions of browser commands. Part of the browser plugin
" Version: 0.4

" don't run twice or when 'compatible' is set
if exists('g:browser_short_version') || &compatible
  finish
endif
let g:browser_short_version = g:browser_plugin_version

" opening
command! -bar -bang -nargs=+ -complete=custom,BrowserCompleteBrowse SBrowse 
      \call BrowserBrowse(<q-args>, <q-bang>)
command! -bar Follow call BrowserFollow()
command! -bar -nargs=? -complete=dir SaveLink call BrowserSaveLink(<f-args>)
command! -bar -bang Reload call BrowserReload(<q-bang>)

" history
command! -bar -range=1 Back call BrowserBack(<count>)
command! -bar -range=1 Pop call BrowserBack(<count>)
command! -bar -range=1 Forward call BrowserForward(<count>)
command! -bar -range=1 Tag call BrowserForward(<count>)
command! -bar History call BrowserHistory()
command! -bar Tags call BrowserHistory()

" bookmarks
command! -bar -nargs=1 -bang Bookmark call BrowserBookmark(<f-args>, <q-bang>)
command! -bar -nargs=1 -bang -complete=custom,BrowserCompleteBkmkFile AddrBook 
      \call BrowserChangeBookmarkFile(<f-args>, <q-bang>)
command! -bar -nargs=? -complete=custom,BrowserCompleteBkmkFile ListBookmarks 
      \call BrowserListBookmarks(<f-args>)

" forms
command! -bar -range=1 NextChoice call BrowserNextChoice(<count>)
command! -bar -range=1 PrevChoice call BrowserPrevChoice(<count>)
command! -bar Click call BrowserClick()
command! -bar -range=1 ScrollUp call BrowserTextScroll(<count>)
command! -bar -range=1 ScrollDown call BrowserTextScroll(-<count>)

" other
command! -bar ShowHeader call BrowserShowHeader()
command! -bar HideHeader call BrowserHideHeader()
command! -bar -bang ViewSource call BrowserViewSource(<q-bang>)
command! -bar -range=1 NextLink call BrowserNextLink(<count>)
command! -bar -range=1 PrevLink call BrowserPrevLink(<count>)
command! -bar -nargs=? -complete=dir ImageSave 
      \call BrowserImage('save', <f-args>)

