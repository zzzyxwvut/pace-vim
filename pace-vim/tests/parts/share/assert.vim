##############################|share/assert.vim|##############################
var assert_errors: list<list<string>> = []

const script_name: string = !empty($TEST_SCRIPT_NAME)
	? $TEST_SCRIPT_NAME
	: expand('<script>:t')

def Go_To_Match(pattern: string): number
	return search(pattern, 'eW')
enddef

def Peek_Call_Stack(): string
	return expand('<stack>:t')
enddef

def Write_Errors()
	if !empty(assert_errors)
		# Allow for repeatable sources.
		writefile(map(assert_errors[:], 'string(v:val)'), 'errors', 'a')
	endif
enddef

if Peek_Call_Stack() =~ '\[\d\+\]'

if exists('assert_quiet')

def Assert_True(id: number, predicate: bool)
	if !predicate
		if bufname('%') != script_name && bufwinnr(script_name) > -1
			execute ':' .. bufwinnr(script_name) .. 'wincmd w'
		endif

		const stack: string = expand('<stack>:t')
		const top: number = stridx(stack, ']')
		add(assert_errors,
			[top < 3
				? printf('@%s: %s[%d]',
					string(id),
					script_name,
					Go_To_Match('\<Assert_True('
							.. id
							.. ','))
				: stack[: top],
			'false'])
		quitall
	endif
enddef

def Assert_Equal(id: number, left: any, right: any)
	if !(type(left) == type(right) && left == right)
		if bufname('%') != script_name && bufwinnr(script_name) > -1
			execute ':' .. bufwinnr(script_name) .. 'wincmd w'
		endif

		const stack: string = expand('<stack>:t')
		const top: number = stridx(stack, ']')
		add(assert_errors,
			[top < 3
				? printf('@%s: %s[%d]',
					string(id),
					script_name,
					Go_To_Match('\<Assert_Equal('
							.. id
							.. ','))
				: stack[: top],
			printf('%s != %s', string(left), string(right))])
		quitall
	endif
enddef

def Assert_Not_Equal(id: number, left: any, right: any)
	if !(type(left) != type(right) || left != right)
		if bufname('%') != script_name && bufwinnr(script_name) > -1
			execute ':' .. bufwinnr(script_name) .. 'wincmd w'
		endif

		const stack: string = expand('<stack>:t')
		const top: number = stridx(stack, ']')
		add(assert_errors,
			[top < 3
				? printf('@%s: %s[%d]',
					string(id),
					script_name,
					Go_To_Match('\<Assert_Not_Equal('
							.. id
							.. ','))
				: stack[: top],
			printf('%s == %s', string(left), string(right))])
		quitall
	endif
enddef

else

def Assert_True(id: number, predicate: bool)
	if !predicate
		if bufname('%') != script_name && bufwinnr(script_name) > -1
			execute ':' .. bufwinnr(script_name) .. 'wincmd w'
		endif

		const top: list<string> = matchlist(expand('<stack>:t'),
						'^.\{-1,}\[\(\d\+\)\]')
		const error: list<string> = [empty(top)
				? printf('@%s: %s[%d]',
					string(id),
					script_name,
					Go_To_Match('\<Assert_True('
							.. id
							.. ','))
				: top[0],
			'false']
		add(assert_errors, error)

		if len(top) > 1 && top[1] != ''
			cursor(str2nr(top[1]), 1)
		endif

		throw printf('TEST: %s: %s', error[0], error[1])
	endif
enddef

def Assert_Equal(id: number, left: any, right: any)
	if !(type(left) == type(right) && left == right)
		if bufname('%') != script_name && bufwinnr(script_name) > -1
			execute ':' .. bufwinnr(script_name) .. 'wincmd w'
		endif

		const top: list<string> = matchlist(expand('<stack>:t'),
						'^.\{-1,}\[\(\d\+\)\]')
		const error: list<string> = [empty(top)
				? printf('@%s: %s[%d]',
					string(id),
					script_name,
					Go_To_Match('\<Assert_Equal('
							.. id
							.. ','))
				: top[0],
			printf('%s != %s', string(left), string(right))]
		add(assert_errors, error)

		if len(top) > 1 && top[1] != ''
			cursor(str2nr(top[1]), 1)
		endif

		throw printf('TEST: %s: "%s"', error[0], error[1])
	endif
enddef

def Assert_Not_Equal(id: number, left: any, right: any)
	if !(type(left) != type(right) || left != right)
		if bufname('%') != script_name && bufwinnr(script_name) > -1
			execute ':' .. bufwinnr(script_name) .. 'wincmd w'
		endif

		const top: list<string> = matchlist(expand('<stack>:t'),
						'^.\{-1,}\[\(\d\+\)\]')
		const error: list<string> = [empty(top)
				? printf('@%s: %s[%d]',
					string(id),
					script_name,
					Go_To_Match('\<Assert_Not_Equal('
							.. id
							.. ','))
				: top[0],
			printf('%s == %s', string(left), string(right))]
		add(assert_errors, error)

		if len(top) > 1 && top[1] != ''
			cursor(str2nr(top[1]), 1)
		endif

		throw printf('TEST: %s: "%s"', error[0], error[1])
	endif
enddef

endif

else

if exists('assert_quiet')

def Assert_True(id: number, predicate: bool)
	if !predicate
		if bufname('%') != script_name && bufwinnr(script_name) > -1
			execute ':' .. bufwinnr(script_name) .. 'wincmd w'
		endif

		add(assert_errors,
			[printf('@%s: %s[%d]',
					string(id),
					script_name,
					Go_To_Match('\<Assert_True('
							.. id
							.. ',')),
				'false'])
		quitall
	endif
enddef

def Assert_Equal(id: number, left: any, right: any)
	if !(type(left) == type(right) && left == right)
		if bufname('%') != script_name && bufwinnr(script_name) > -1
			execute ':' .. bufwinnr(script_name) .. 'wincmd w'
		endif

		add(assert_errors,
			[printf('@%s: %s[%d]',
					string(id),
					script_name,
					Go_To_Match('\<Assert_Equal('
							.. id
							.. ',')),
				printf('%s != %s',
						string(left),
						string(right))])
		quitall
	endif
enddef

def Assert_Not_Equal(id: number, left: any, right: any)
	if !(type(left) != type(right) || left != right)
		if bufname('%') != script_name && bufwinnr(script_name) > -1
			execute ':' .. bufwinnr(script_name) .. 'wincmd w'
		endif

		add(assert_errors,
			[printf('@%s: %s[%d]',
					string(id),
					script_name,
					Go_To_Match('\<Assert_Not_Equal('
							.. id
							.. ',')),
				printf('%s == %s',
						string(left),
						string(right))])
		quitall
	endif
enddef

else

def Assert_True(id: number, predicate: bool)
	if !predicate
		if bufname('%') != script_name && bufwinnr(script_name) > -1
			execute ':' .. bufwinnr(script_name) .. 'wincmd w'
		endif

		const error: list<string> = [printf('@%s: %s[%d]',
					string(id),
					script_name,
					Go_To_Match('\<Assert_True('
							.. id
							.. ',')),
				'false']
		add(assert_errors, error)
		throw printf('TEST: %s: %s', error[0], error[1])
	endif
enddef

def Assert_Equal(id: number, left: any, right: any)
	if !(type(left) == type(right) && left == right)
		if bufname('%') != script_name && bufwinnr(script_name) > -1
			execute ':' .. bufwinnr(script_name) .. 'wincmd w'
		endif

		const error: list<string> = [printf('@%s: %s[%d]',
					string(id),
					script_name,
					Go_To_Match('\<Assert_Equal('
							.. id
							.. ',')),
				printf('%s != %s',
						string(left),
						string(right))]
		add(assert_errors, error)
		throw printf('TEST: %s: "%s"', error[0], error[1])
	endif
enddef

def Assert_Not_Equal(id: number, left: any, right: any)
	if !(type(left) != type(right) || left != right)
		if bufname('%') != script_name && bufwinnr(script_name) > -1
			execute ':' .. bufwinnr(script_name) .. 'wincmd w'
		endif

		const error: list<string> = [printf('@%s: %s[%d]',
					string(id),
					script_name,
					Go_To_Match('\<Assert_Not_Equal('
							.. id
							.. ',')),
				printf('%s == %s',
						string(left),
						string(right))]
		add(assert_errors, error)
		throw printf('TEST: %s: "%s"', error[0], error[1])
	endif
enddef

endif

endif

augroup test
	autocmd! test
	autocmd test VimLeave		* Write_Errors()
augroup END

defcompile
#####################################|EOF|####################################
