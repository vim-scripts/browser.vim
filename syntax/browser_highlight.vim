" File Name: browser_highlight.vim
" Maintainer: Moshe Kaminsky
" Last Update: September 17, 2004
" Description: highlight definitions for the browser. Part of browser plugin
" Version: 0.3

highlight browser_bold term=bold cterm=bold gui=bold
highlight browser_italic term=italic cterm=italic gui=italic
HiLink browser_teletype Special
highlight browser_strong term=standout cterm=standout gui=standout
highlight browser_em term=bold,italic cterm=bold,italic gui=bold,italic
HiLink browser_code Identifier
HiLink browser_kbd Operator
highlight browser_samp term=inverse cterm=inverse gui=inverse
HiLink browser_var Repeat

