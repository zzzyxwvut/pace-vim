""""""""""""""""""""""""""""""|share/mockup.vim|""""""""""""""""""""""""""""""
let s:cpoptions = &cpoptions
set cpoptions-=C					" Join line-breaks.

let s:insertmode = 'i'
let s:mockup = {
	\ 'mode':	'n',
	\ 'parts':	!empty($TEST_SECOND_PARTS)
				\ ? str2nr($TEST_SECOND_PARTS)
				\ : 0,
	\ 'time':	{
		\ 'after':	[0, 1],
		\ 'between':	[0, 1],
		\ 'before':	[0, 0],
		\ 'over':	[-1, -1],
	\ },
\ }
lockvar s:mockup.parts

if s:mockup.parts == 9					" nsec
	let s:mockup.time.after = [0, 1000000]		" 1/1000
	let s:mockup.time.between = [0, 1000000]	" 1/1000
	let s:mockup.time.over = [-1, 999999999]
elseif s:mockup.parts == 6				" usec
	let s:mockup.time.after = [0, 1000]		" 1/1000
	let s:mockup.time.between = [0, 1000]		" 1/1000
	let s:mockup.time.over = [-1, 999999]
endif

function s:Mode() abort							" {{{1
	return s:mockup.mode
endfunction								" }}}1

" Track f_reltime of time.c and profile_* of profiler.c.
"
" Mock the following function signatures:
"	reltime()
"	reltime(start)
"	reltime(start, end)
function s:Reltime(...) abort						" {{{1
	let l:kind = a:0 == 0
		\ ? 0
		\ : a:0 == 1 && type(a:1) == type([]) &&
						\ len(a:1) == 2 &&
						\ type(a:1[0]) == type(0) &&
						\ type(a:1[1]) == type(0)
			\ ? 1
			\ : a:0 == 2 && type(a:1) == type([]) &&
						\ len(a:1) == 2 &&
						\ type(a:1[0]) == type(0) &&
						\ type(a:1[1]) == type(0) &&
						\ type(a:2) == type([]) &&
						\ len(a:2) == 2 &&
						\ type(a:2[0]) == type(0) &&
						\ type(a:2[1]) == type(0)
				\ ? 2
				\ : -1

	if l:kind < 0
		throw 'Illegal argument'
	endif

	" Also handle reltime([0, 0], [0, -1]).
	return l:kind == 2
		\ ? a:2[1] == -1 && a:2[0] == 0 && a:1[1] == 0 && a:1[0] == 0
			\ ? s:mockup.time.over
			\ : s:mockup.time.between
		\ : l:kind == 1
			\ ? s:mockup.time.after
			\ : s:mockup.time.before
endfunction								" }}}1

" Track f_reltimestr of time.c and profile_msg of profiler.c.
"
" Beware that the time format is assumed as if it were timespec or timeval.
function s:ReltimeStr(time) abort					" {{{1
	if type(a:time) != type([]) ||
					\ len(a:time) != 2 ||
					\ type(a:time[0]) != type(0) ||
					\ type(a:time[1]) != type(0)
		throw 'Illegal argument'
	endif

	let l:scale = len(string(a:time[1]))
	let l:micros = a:time[1]

	while l:scale > 6
		let l:micros = l:micros / 1000
		let l:scale -= 3
	endwhile

	" Don't bother with Win32's '%10.6f' for mocked-up time.
	return printf('%3d.%06d', a:time[0], l:micros)
endfunction								" }}}1

let &cpoptions = s:cpoptions
unlet s:cpoptions
"""""""""""""""""""""""""""""""""""""|EOF|""""""""""""""""""""""""""""""""""""
