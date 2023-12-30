"""""""""""""""""""""""""""""|pace/share/turn.vim|""""""""""""""""""""""""""""
function s:Get_Tick() abort						" {{{1
	return s:turn[0]
endfunction

function s:Set_Tick(value) abort					" {{{1
	let s:turn[0] = a:value
endfunction

function s:Get_Secs() abort						" {{{1
	return s:turn[1]
endfunction

function s:Set_Secs(value) abort					" {{{1
	let s:turn[1] = a:value
endfunction

function s:Get_Parts() abort						" {{{1
	return s:turn[2]
endfunction

function s:Set_Parts(value) abort					" {{{1
	let s:turn[2] = a:value
endfunction

function s:Get_Chars() abort						" {{{1
	return s:turn[3]
endfunction

function s:Set_Chars(value) abort					" {{{1
	let s:turn[3] = a:value
endfunction

function s:Get_Chars_Sum() abort					" {{{1
	return s:turn[4]
endfunction

function s:Set_Chars_Sum(value) abort					" {{{1
	let s:turn[4] = a:value
endfunction

function s:Get_Secs_Sum() abort						" {{{1
	return s:turn[5]
endfunction

function s:Set_Secs_Sum(value) abort					" {{{1
	let s:turn[5] = a:value
endfunction								" }}}1
"""""""""""""""""""""""""""""""""""""|EOF|""""""""""""""""""""""""""""""""""""
