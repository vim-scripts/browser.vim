" File Name: browser.vim
" Maintainer: Moshe Kaminsky
" Last Update: September 26, 2004
" Description: syntax for a browser buffer. part of the browser plugin
" Version: 0.4
"

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif


if has('conceal')
  syntax region browserLink matchgroup=browserIgnore start=/<</ end=/>>/ 
        \display oneline concealends contains=TOP
  syntax region browserPre matchgroup=browserIgnore start=/\~>$/ end=/^<\~\s*$/ 
        \concealends contains=TOP keepend
else
  syntax region browserLink matchgroup=browserIgnore start=/<</ end=/>>/ 
        \display oneline contains=TOP
  syntax region browserPre matchgroup=browserIgnore start=/\~>$/ end=/^<\~\s*$/ 
        \contains=TOP keepend
endif
syntax match browserHeader1 /^.*\_$\(\n\s*====*\s*\_$\)\@=/ display 
      \contains=TOP
syntax match browserHeader2 /^.*\_$\(\n\s*----*\s*\_$\)\@=/ display 
      \contains=TOP
syntax match browserHeader3 /^.*\_$\(\n\s*^^^^*\s*\_$\)\@=/ display 
      \contains=TOP
syntax match browserHeader4 /^.*\_$\(\n\s*++++*\s*\_$\)\@=/ display 
      \contains=TOP
syntax match browserHeader5 /^.*\_$\(\n\s*""""*\s*\_$\)\@=/ display 
      \contains=TOP
syntax match browserHeader6 /^.*\_$\(\n\s*\.\.\.\.*\s*\_$\)\@=/ display 
      \contains=TOP
syntax match browserHeaderUL /^\s*====*\s*$/ display
syntax match browserHeaderUL /^\s*----*\s*$/ display
syntax match browserHeaderUL /^\s*^^^^*\s*$/ display
syntax match browserHeaderUL /^\s*++++*\s*$/ display
syntax match browserHeaderUL /^\s*""""*\s*$/ display
syntax match browserHeaderUL /^\s*\.\.\.\.*\s*$/ display
syntax region browserCite start=/`/ end=/'/ display contains=TOP
syntax match browserImage /{[^}]\+}/ display

" The head
syntax region browserHead matchgroup=browserHeadTitle 
      \start=/^.*{{{\%1l$/ end=/^}}}$/ contains=browserHeadField keepend
syntax region browserHeadField matchgroup=browserHeadKey 
      \start=/^  [^:]*:/ end=/$/ oneline display contained

" Forms
syntax region browserTextField matchgroup=browserTFstart 
      \start=+\]>+ end=+$+ oneline display
syntax region browserOption matchgroup=browserInputBoundary 
      \start=+\[+ end=+\]+ oneline display keepend
syntax match browserRadioSelected /(\*)/hs=s+1,he=e-1 display
syntax region browserTextArea matchgroup=browserTABorder 
      \start=/^ *--- Click to edit the text area ----* {{{$/ 
      \end=/^ *}}} --*$/ keepend

syntax sync fromstart

if version >= 508 || !exists("did_c_syn_inits")
  if version < 508
    let did_c_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  " generation of syntax definition dynamically, based on g:browser_{attr}_* 
  " variables
  if has('conceal')
    let s:conceal=' concealends'
  else
    let s:conceal=''
  endif
  
  function BrowserDefSyntax(Tag)
    let Tag=a:Tag
    if exists('g:browser_' . Tag . '_start') && g:browser_{Tag}_start != ''
      let start = escape(g:browser_{Tag}_start, '.*%')
      let end = escape(g:browser_{Tag}_end, '.*%')
      execute 
        \'syn region browser_' . Tag . ' matchgroup=browserIgnore start=%' . 
        \start . '% end=%' . end . '% contains=TOP keepend' s:conceal
      if exists('g:browser_' . Tag . '_highlight')
        execute 'hi! link browser_' . Tag . ' ' . g:browser_{Tag}_highlight
      endif
    endif
  endfunction
  
  HiLink browserHeader1 DiffChange
  HiLink browserHeader2 DiffAdd
  HiLink browserHeader3 DiffDelete
  HiLink browserHeader4 DiffText
  HiLink browserHeader5 Exception
  HiLink browserHeader6 StorageClass
  HiLink browserHeaderUL PreProc
  HiLink browserIgnore Ignore
  HiLink browserLink Underlined
  HiLink browserCite Constant
  HiLink browserPre Identifier
  HiLink browserHeadTitle Title
  HiLink browserHeadKey Type
  HiLink browserHeadField Constant
  HiLink browserTextField DiffAdd
  HiLink browserTFstart Folded
  HiLink browserTAborder Folded
  HiLink browserTextArea Repeat
  HiLink browserOption Label
  HiLink browserInputBoundary Delimiter
  HiLink browserRadioSelected Label
  HiLink browserImage Special

  runtime syntax/browser_highlight.vim

  call BrowserDefSyntax('bold')
  call BrowserDefSyntax('italic')
  call BrowserDefSyntax('underline')
  call BrowserDefSyntax('teletype')
  call BrowserDefSyntax('strong')
  call BrowserDefSyntax('em')
  call BrowserDefSyntax('code')
  call BrowserDefSyntax('kbd')
  call BrowserDefSyntax('samp')
  call BrowserDefSyntax('var')
  call BrowserDefSyntax('definition')

  delfunction BrowserDefSyntax
  
  delcommand HiLink
endif


let b:current_syntax = 'browser'

