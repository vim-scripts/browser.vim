" File Name: browserBkmkPage.vim
" Maintainer: Moshe Kaminsky
" Last Modified: Sat 20 Nov 2004 09:59:22 PM IST
" Description: syntax for a browser buffer containing bookmarks. part of the 
" browser plugin
" Version: 1.0
"

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syntax region browserBkmkLink matchgroup=browserBkmkBullet start=/^\* / end=/$/ 
      \display oneline
syntax region browserHistGrp matchgroup=browserBkmkBullet start=/^+ / end=/$/ 
      \display oneline
syntax region browserBkmkBook matchgroup=browserBkmkBrackets 
      \start=/^\[/ end=/\]$/ oneline display
syntax match browserBkmkSep /^\s*----*\s*$/ display
syntax match browserBkmkHeader /\%1l.*/ display
syntax match browserBkmkUL /\%2l.*/ display
syntax region browserBkmkFold start=/^+/ end=/^$/ transparent fold
syntax match browserBkmkTree /^  [|`]->/ display

setlocal foldmethod=syntax

syntax sync fromstart

if version >= 508 || !exists("did_c_syn_inits")
  if version < 508
    let did_c_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink browserBkmkSep PreProc
  HiLink browserBkmkLink UnderLined
  HiLink browserHistGrp Identifier
  HiLink browserBkmkBullet Type
  HiLink browserBkmkBook Statement
  HiLink browserBkmkBrackets Special
  HiLink browserBkmkHeader DiffChange
  HiLink browserBkmkUL Constant
  HiLink browserBkmkTree Special
  
  delcommand HiLink
endif

let b:current_syntax = 'browserBkmkPage'

