" File Name: browser_menus.vim
" Maintainer: Moshe Kaminsky
" Last Update: November 13, 2004
" Description: browser menus. Part of the browser plugin

" don't run twice or when 'compatible' is set
if exists('g:browser_menus_version') || &compatible
  finish
endif
let g:browser_menus_version = g:browser_plugin_version

" the toolbar
aunmenu ToolBar.FindPrev
aunmenu ToolBar.FindNext
aunmenu ToolBar.Redo

menu icon=Back 1.1 ToolBar.FindPrev :Back<CR>
tmenu ToolBar.FindPrev Back
menu icon=Forward 1.1 ToolBar.FindNext :Forward<CR>
tmenu ToolBar.FindNext Forward
menu icon=Reload 1.1 ToolBar.Redo :Reload<CR>
tmenu ToolBar.Redo Reload
menu 1.1 ToolBar.-sep- :

" the context menu
menu .1 PopUp.Search\ The\ Web :Search<CR>
vmenu .1 PopUp.Search\ The\ Web :Search<CR>

