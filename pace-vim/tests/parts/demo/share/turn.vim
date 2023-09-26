"""""""""""""""""""""""""""""|demo/share/turn.vim|""""""""""""""""""""""""""""
function! s:Get_Tick() abort						" {{{1
	return s:turn.a
endfunction

function! s:Set_Tick(value) abort					" {{{1
	let s:turn.a = a:value
endfunction

function! s:Get_Secs() abort						" {{{1
	return s:turn.b
endfunction

function! s:Set_Secs(value) abort					" {{{1
	let s:turn.b = a:value
endfunction

function! s:Get_Parts() abort						" {{{1
	return s:turn.c
endfunction

function! s:Set_Parts(value) abort					" {{{1
	let s:turn.c = a:value
endfunction

function! s:Get_Chars() abort						" {{{1
	return s:turn.d
endfunction

function! s:Set_Chars(value) abort					" {{{1
	let s:turn.d = a:value
endfunction								" }}}1
"""""""""""""""""""""""""""""""""""""|EOF|""""""""""""""""""""""""""""""""""""
