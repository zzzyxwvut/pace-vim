""""""""""""""""""""""""""""""|share/assert.vim|""""""""""""""""""""""""""""""
let s:cpoptions = &cpoptions
set cpoptions-=C					" Join line-breaks.

let s:assert_errors = []
let s:script_name = !empty($TEST_SCRIPT_NAME)
	\ ? $TEST_SCRIPT_NAME
	\ : expand('<script>:t')

function s:Go_To_Match(pattern) abort					" {{{1
	return search(a:pattern, 'eW')
endfunction

function s:Peek_Call_Stack() abort					" {{{1
	return expand('<stack>:t')
endfunction

function s:Write_Errors() abort						" {{{1
	if !empty(s:assert_errors)
		" Allow for repeatable sources.
		call writefile(map(s:assert_errors[:], 'string(v:val)'),
								\ 'errors',
								\ 'a')
	endif
endfunction								" }}}1

if s:Peek_Call_Stack() =~ '\[\d\+\]'

if exists('s:assert_quiet')

function s:Assert_True(id, predicate) abort				" {{{1
	if !((type(a:predicate) == type(0) ||
				\ type(a:predicate) == type(v:false)) &&
							\ !!a:predicate)
		if bufname('%') != s:script_name && bufwinnr(s:script_name) > -1
			execute bufwinnr(s:script_name) .. 'wincmd w'
		endif

		let l:stack = expand('<stack>:t')
		let l:top = stridx(l:stack, ']')
		call add(s:assert_errors,
			\ [l:top < 3
				\ ? printf('@%s: %s[%d]',
					\ string(a:id),
					\ s:script_name,
					\ s:Go_To_Match('\<s:Assert_True('
							\ .. string(a:id)
							\ .. ','))
				\ : l:stack[: l:top],
			\ 'false'])
		quitall
	endif
endfunction

function s:Assert_Equal(id, left, right) abort				" {{{1
	if !(type(a:left) == type(a:right) && a:left == a:right)
		if bufname('%') != s:script_name && bufwinnr(s:script_name) > -1
			execute bufwinnr(s:script_name) .. 'wincmd w'
		endif

		let l:stack = expand('<stack>:t')
		let l:top = stridx(l:stack, ']')
		call add(s:assert_errors,
			\ [l:top < 3
				\ ? printf('@%s: %s[%d]',
					\ string(a:id),
					\ s:script_name,
					\ s:Go_To_Match('\<s:Assert_Equal('
							\ .. string(a:id)
							\ .. ','))
				\ : l:stack[: l:top],
			\ printf('%s != %s', string(a:left), string(a:right))])
		quitall
	endif
endfunction

function s:Assert_Not_Equal(id, left, right) abort			" {{{1
	if !(type(a:left) != type(a:right) || a:left != a:right)
		if bufname('%') != s:script_name && bufwinnr(s:script_name) > -1
			execute bufwinnr(s:script_name) .. 'wincmd w'
		endif

		let l:stack = expand('<stack>:t')
		let l:top = stridx(l:stack, ']')
		call add(s:assert_errors,
			\ [l:top < 3
				\ ? printf('@%s: %s[%d]',
					\ string(a:id),
					\ s:script_name,
					\ s:Go_To_Match('\<s:Assert_Not_Equal('
							\ .. string(a:id)
							\ .. ','))
				\ : l:stack[: l:top],
			\ printf('%s == %s', string(a:left), string(a:right))])
		quitall
	endif
endfunction								" }}}1

else

function s:Assert_True(id, predicate) abort				" {{{1
	if !((type(a:predicate) == type(0) ||
				\ type(a:predicate) == type(v:false)) &&
							\ !!a:predicate)
		if bufname('%') != s:script_name && bufwinnr(s:script_name) > -1
			execute bufwinnr(s:script_name) .. 'wincmd w'
		endif

		let l:top = matchlist(expand('<stack>:t'),
						\ '^.\{-1,}\[\(\d\+\)\]')
		let l:error = [empty(l:top)
				\ ? printf('@%s: %s[%d]',
					\ string(a:id),
					\ s:script_name,
					\ s:Go_To_Match('\<s:Assert_True('
							\ .. string(a:id)
							\ .. ','))
				\ : l:top[0],
			\ 'false']
		call add(s:assert_errors, l:error)

		if len(l:top) > 1 && l:top[1] != ''
			call cursor(str2nr(l:top[1]), 1)
		endif

		throw printf('TEST: %s: %s', l:error[0], l:error[1])
	endif
endfunction

function s:Assert_Equal(id, left, right) abort				" {{{1
	if !(type(a:left) == type(a:right) && a:left == a:right)
		if bufname('%') != s:script_name && bufwinnr(s:script_name) > -1
			execute bufwinnr(s:script_name) .. 'wincmd w'
		endif

		let l:top = matchlist(expand('<stack>:t'),
						\ '^.\{-1,}\[\(\d\+\)\]')
		let l:error = [empty(l:top)
				\ ? printf('@%s: %s[%d]',
					\ string(a:id),
					\ s:script_name,
					\ s:Go_To_Match('\<s:Assert_Equal('
							\ .. string(a:id)
							\ .. ','))
				\ : l:top[0],
			\ printf('%s != %s', string(a:left), string(a:right))]
		call add(s:assert_errors, l:error)

		if len(l:top) > 1 && l:top[1] != ''
			call cursor(str2nr(l:top[1]), 1)
		endif

		throw printf('TEST: %s: "%s"', l:error[0], l:error[1])
	endif
endfunction

function s:Assert_Not_Equal(id, left, right) abort			" {{{1
	if !(type(a:left) != type(a:right) || a:left != a:right)
		if bufname('%') != s:script_name && bufwinnr(s:script_name) > -1
			execute bufwinnr(s:script_name) .. 'wincmd w'
		endif

		let l:top = matchlist(expand('<stack>:t'),
						\ '^.\{-1,}\[\(\d\+\)\]')
		let l:error = [empty(l:top)
				\ ? printf('@%s: %s[%d]',
					\ string(a:id),
					\ s:script_name,
					\ s:Go_To_Match('\<s:Assert_Not_Equal('
							\ .. string(a:id)
							\ .. ','))
				\ : l:top[0],
			\ printf('%s == %s', string(a:left), string(a:right))]
		call add(s:assert_errors, l:error)

		if len(l:top) > 1 && l:top[1] != ''
			call cursor(str2nr(l:top[1]), 1)
		endif

		throw printf('TEST: %s: "%s"', l:error[0], l:error[1])
	endif
endfunction								" }}}1

endif

else

if exists('s:assert_quiet')

function s:Assert_True(id, predicate) abort				" {{{1
	if !((type(a:predicate) == type(0) ||
				\ type(a:predicate) == type(v:false)) &&
							\ !!a:predicate)
		if bufname('%') != s:script_name && bufwinnr(s:script_name) > -1
			execute bufwinnr(s:script_name) .. 'wincmd w'
		endif

		call add(s:assert_errors,
			\ [printf('@%s: %s[%d]',
					\ string(a:id),
					\ s:script_name,
					\ s:Go_To_Match('\<s:Assert_True('
							\ .. string(a:id)
							\ .. ',')),
				\ 'false'])
		quitall
	endif
endfunction

function s:Assert_Equal(id, left, right) abort				" {{{1
	if !(type(a:left) == type(a:right) && a:left == a:right)
		if bufname('%') != s:script_name && bufwinnr(s:script_name) > -1
			execute bufwinnr(s:script_name) .. 'wincmd w'
		endif

		call add(s:assert_errors,
			\ [printf('@%s: %s[%d]',
					\ string(a:id),
					\ s:script_name,
					\ s:Go_To_Match('\<s:Assert_Equal('
							\ .. string(a:id)
							\ .. ',')),
				\ printf('%s != %s',
						\ string(a:left),
						\ string(a:right))])
		quitall
	endif
endfunction

function s:Assert_Not_Equal(id, left, right) abort			" {{{1
	if !(type(a:left) != type(a:right) || a:left != a:right)
		if bufname('%') != s:script_name && bufwinnr(s:script_name) > -1
			execute bufwinnr(s:script_name) .. 'wincmd w'
		endif

		call add(s:assert_errors,
			\ [printf('@%s: %s[%d]',
					\ string(a:id),
					\ s:script_name,
					\ s:Go_To_Match('\<s:Assert_Not_Equal('
							\ .. string(a:id)
							\ .. ',')),
				\ printf('%s == %s',
						\ string(a:left),
						\ string(a:right))])
		quitall
	endif
endfunction								" }}}1

else

function s:Assert_True(id, predicate) abort				" {{{1
	if !((type(a:predicate) == type(0) ||
				\ type(a:predicate) == type(v:false)) &&
							\ !!a:predicate)
		if bufname('%') != s:script_name && bufwinnr(s:script_name) > -1
			execute bufwinnr(s:script_name) .. 'wincmd w'
		endif

		let l:error = [printf('@%s: %s[%d]',
					\ string(a:id),
					\ s:script_name,
					\ s:Go_To_Match('\<s:Assert_True('
							\ .. string(a:id)
							\ .. ',')),
				\ 'false']
		call add(s:assert_errors, l:error)
		throw printf('TEST: %s: %s', l:error[0], l:error[1])
	endif
endfunction

function s:Assert_Equal(id, left, right) abort				" {{{1
	if !(type(a:left) == type(a:right) && a:left == a:right)
		if bufname('%') != s:script_name && bufwinnr(s:script_name) > -1
			execute bufwinnr(s:script_name) .. 'wincmd w'
		endif

		let l:error = [printf('@%s: %s[%d]',
					\ string(a:id),
					\ s:script_name,
					\ s:Go_To_Match('\<s:Assert_Equal('
							\ .. string(a:id)
							\ .. ',')),
				\ printf('%s != %s',
						\ string(a:left),
						\ string(a:right))]
		call add(s:assert_errors, l:error)
		throw printf('TEST: %s: "%s"', l:error[0], l:error[1])
	endif
endfunction

function s:Assert_Not_Equal(id, left, right) abort			" {{{1
	if !(type(a:left) != type(a:right) || a:left != a:right)
		if bufname('%') != s:script_name && bufwinnr(s:script_name) > -1
			execute bufwinnr(s:script_name) .. 'wincmd w'
		endif

		let l:error = [printf('@%s: %s[%d]',
					\ string(a:id),
					\ s:script_name,
					\ s:Go_To_Match('\<s:Assert_Not_Equal('
							\ .. string(a:id)
							\ .. ',')),
				\ printf('%s == %s',
						\ string(a:left),
						\ string(a:right))]
		call add(s:assert_errors, l:error)
		throw printf('TEST: %s: "%s"', l:error[0], l:error[1])
	endif
endfunction								" }}}1

endif

endif

augroup test
	autocmd! test
	autocmd test VimLeave		* call s:Write_Errors()
augroup END

delfunction s:Peek_Call_Stack
let &cpoptions = s:cpoptions
unlet s:cpoptions
"""""""""""""""""""""""""""""""""""""|EOF|""""""""""""""""""""""""""""""""""""
