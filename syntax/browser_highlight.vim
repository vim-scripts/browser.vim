" File Name: browser_highlight.vim
" Maintainer: Moshe Kaminsky
" Last Update: September 26, 2004
" Description: highlight definitions for the browser. Part of browser plugin
" Version: 0.4

highlight browser_bold term=bold cterm=bold gui=bold
highlight browser_italic term=italic cterm=italic gui=italic
highlight browser_underline term=underline cterm=underline gui=underline
HiLink browser_teletype Special
highlight browser_strong term=standout cterm=standout gui=standout
highlight browser_em term=bold,italic cterm=bold,italic gui=bold,italic
HiLink browser_code Identifier
HiLink browser_kbd Operator
highlight browser_samp term=inverse cterm=inverse gui=inverse
HiLink browser_var Repeat
HiLink browser_definition Define

