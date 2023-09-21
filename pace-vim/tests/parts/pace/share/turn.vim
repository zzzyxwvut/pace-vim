"""""""""""""""""""""""""""""|pace/share/turn.vim|""""""""""""""""""""""""""""
function s:Get_Tick() abort						" {{{1
	return s:turn.a
endfunction

function s:Set_Tick(value) abort					" {{{1
	let s:turn.a = a:value
endfunction

function s:Get_Secs() abort						" {{{1
	return s:turn.b
endfunction

function s:Set_Secs(value) abort					" {{{1
	let s:turn.b = a:value
endfunction

function s:Get_Parts() abort						" {{{1
	return s:turn.c
endfunction

function s:Set_Parts(value) abort					" {{{1
	let s:turn.c = a:value
endfunction

function s:Get_Chars() abort						" {{{1
	return s:turn.d
endfunction

function s:Set_Chars(value) abort					" {{{1
	let s:turn.d = a:value
endfunction

function s:Get_Chars_Sum() abort					" {{{1
	return s:turn.e
endfunction

function s:Set_Chars_Sum(value) abort					" {{{1
	let s:turn.e = a:value
endfunction

function s:Get_Secs_Sum() abort						" {{{1
	return s:turn.f
endfunction

function s:Set_Secs_Sum(value) abort					" {{{1
	let s:turn.f = a:value
endfunction								" }}}1
"""""""""""""""""""""""""""""""""""""|EOF|""""""""""""""""""""""""""""""""""""
