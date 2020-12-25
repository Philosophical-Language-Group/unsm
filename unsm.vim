if exists("b:current_syntax")
  finish
endif

set textwidth=60 comments=:\| formatoptions=croq
set autoindent smartindent cinwords=":"
set expandtab tabstop=2 shiftwidth=2

syn match unsmOperator   '[|:]'
syn match unsmDelimiter  '[;,()]'
syn match unsmVariable   '\'[a-zα-ω-]\+'
syn match unsmIdentifier '[a-zα-ω-]\+'
syn match unsmMacro      '[a-zα-ω-]\+!'
syn match unsmDirective  '[a-zα-ω-]\+!'
syn match unsmComment    '%.\{-}$'

let b:current_syntax = "unsm"

hi def link unsmDelimiter  Delimiter
hi def link unsmMacro      Keyword
hi def link unsmIdentifier Function
hi def link unsmArity      Constant
hi def link unsmVariable   Identifier
hi def link unsmDirective  PreProc
hi def link unsmComment    Comment
hi def link unsmOperator   Operator
