" Description:	Measure the pace of typing (in Insert mode &c.)
" Author:	Aliaksei Budavei (0x000c70 AT gmail DOT com)
" Repository:	https://github.com/zzzyxwvut/pace-vim.git [vim/9/0/master]
" Bundles:	https://www.vim.org/scripts/script.php?script_id=5472
" Version:	2.0
" Last Change:	2023-Sep-21
" Copyleft ())
"
" Usage:	List all doc/ locations:
"		":echo finddir('doc', &runtimepath, -1)".
"
"		Generate the help tags: ":helptags doc/".
"		Read the documentation: ":help pace.txt".

let s:cpoptions	= &cpoptions
set cpoptions-=C					" Join line-breaks.

if exists('g:pace_lock') || !(has('reltime') && has('autocmd') &&
				\ has('cmdline_info') && has('statusline') &&
				\ has('user_commands'))
	let &cpoptions	= s:cpoptions
	unlet s:cpoptions
	finish
endif

" Ponder before ridding of s:turn.e ((a sum of) characters) and s:turn.f
" ((a sum of) seconds), and devolving their duties upon s:turn.d (characters)
" and s:turn.b (seconds).
"
" s:turn.e ((a sum of) characters): s:pace.enter() offers no way of telling
" event calls from command line calls; consider that one may quit typing with
" Ctrl-c, should now s:turn.b (seconds) serve to distinguish between aborted-
" `null' and normal-exit records, now s:pace.dump[0][0][2] == s:turn.d (i.e.
" the total and the recent character counts)?  Should the rejected character
" count be deducted from the s:turn.d figure in s:pace.enter()?
"
" s:turn.f ((a sum of) seconds): reltime() returns the time elapsed between
" events, whereas the total seconds spent typing is the sum of all such runs;
" therefore, provide another entry that would hold the sum of all Normal-mode
" time and subtract its value from the value of reltime(first_hit, last_hit)
" in s:pace.leave().
"
" Moreover, s:turn.d (characters) and s:turn.b (seconds) must accommodate any
" run count policy: single (0000), all (1000), or buffer (2000).

" (Shorter key names shorten lookup time.)
" a: tick,
" b: seconds,
" c: micro- or nano-seconds,
" d: characters,
" e: (a sum of) characters,
" f: (a sum of) seconds.
let s:turn	= {'a': reltime(), 'b': -1, 'c': 0, 'd': -1, 'e': 0, 'f': 0}

let s:pace	= {
	\ 'buffer':	bufnr('%'),
	\ 'policy':	10007,
	\ 'carry':	0,
	\ 'load':	0,
	\ 'mark':	0,
	\ 'epoch':	reltime(),
	\ 'pool':	{},
	\ 'sample':	{
		\ 'above':	2000,
		\ 'below':	50,
		\ 'in':		(50 - 5),
	\ },
	\ 'state':	{
		\ 'laststatus':		&laststatus,
		\ 'maxfuncdepth':	&maxfuncdepth,
		\ 'ruler':		&ruler,
		\ 'rulerformat':	&rulerformat,
		\ 'statusline':		&g:statusline,
		\ 'updatetime':		&updatetime,
	\ },
	\ 'status':	{},
\ }

if exists('g:pace_dump') && type(g:pace_dump) == type({}) &&
					\ has_key(g:pace_dump, '0') &&
					\ 0 == max(map(map(values(g:pace_dump),
	\ '(type(get((type(v:val) == type([]) ? v:val : []), 0)) == type([]) &&
				\ len(v:val[0]) == 4 ? v:val[0] : [""])'),
	\ '(type(get(v:val, 0)) != type(0) ? 1 : 0) +
				\ (type(get(v:val, 1)) != type(0) ? 1 : 0) +
				\ (type(get(v:val, 2)) != type(0) ? 1 : 0) +
				\ (type(get(v:val, 3)) != type(0) ? 1 : 0)'))
	let s:pace.dump	= deepcopy(g:pace_dump, 1)
else	" Call either Pace_Dump() or Pace_Free() to obtain g:pace_dump.
	let s:pace.dump	= {'0': [[0, 0, 0, 0]]}
endif	" The 0th key value follows a uniform depth: [[]].

" Try to roll over the sub-second unit (see profile_sub() of profile.c).
let s:parts	= len(reltime()) == 2
			\ ? map([reltime([0, 0], [0, -1])],
				\ "v:val[0] == -1 && v:val[1] =~ '^9\\+$'
							\ ? strlen(v:val[1])
							\ : 0")[0]
			\ : 0
lockvar s:parts s:pace.sample.above s:pace.sample.below

if s:parts != 6 && s:parts != 9 && reltimestr(reltime())[-7 : -7] != '.'
	throw 'My mind is going...'
endif

if s:parts == 9

function! s:pace.recordunit(go, time) abort				" {{{1
	let [a:go.b, a:go.c]	=
		\ [(a:go.b + a:time[0] + (a:time[1] + a:go.c) / 1000000000),
		\ ((a:time[1] + a:go.c) % 1000000000)]
endfunction								" }}}1

else

function! s:pace.recordunit(go, time) abort				" {{{1
	let [a:go.b, a:go.c]	=
		\ [(a:go.b + a:time[0] + (a:time[1] + a:go.c) / 1000000),
		\ ((a:time[1] + a:go.c) % 1000000)]
endfunction								" }}}1

endif

if s:parts == 6 || s:parts == 9

function! s:pace.time(tick) abort					" {{{1
	return a:tick
endfunction								" }}}1

if s:parts == 6

function! s:pace.eval2(go) abort					" {{{1
	let l:tick	= reltime(a:go.a)
	let [a:go.b, a:go.c, a:go.d]	=
		\ [(a:go.b + l:tick[0] + (l:tick[1] + a:go.c) / 1000000),
		\ ((l:tick[1] + a:go.c) % 1000000),
		\ (a:go.d + 1)]
	let a:go.a	= reltime()
endfunction

function! s:pace.eval1(go) abort					" {{{1
	let l:tick	= reltime(a:go.a)
	let [a:go.b, a:go.c, a:go.d]	=
		\ [(a:go.b + l:tick[0] + (l:tick[1] + a:go.c) / 1000000),
		\ ((l:tick[1] + a:go.c) % 1000000),
		\ (a:go.d + 1)]
	let [l:char, l:sec]	= [(a:go.d + a:go.e), (a:go.b + a:go.f)]
	let g:pace_info		= printf('%-9s %2i, %7i, %5i',
			\ l:tick[0].(printf('.%06i', l:tick[1]))[: 2].',',
			\ (l:char / l:sec),
			\ l:char,
			\ l:sec)
	let a:go.a	= reltime()
endfunction

function! s:pace.eval0(go) abort					" {{{1
	let l:tick	= reltime(a:go.a)
	let [a:go.b, a:go.c, a:go.d]	=
		\ [(a:go.b + l:tick[0] + (l:tick[1] + a:go.c) / 1000000),
		\ ((l:tick[1] + a:go.c) % 1000000),
		\ (a:go.d + 1)]
	let [l:char, l:sec]	= [(a:go.d + a:go.e), (a:go.b + a:go.f)]
	let g:pace_info		= printf('%-9s %2i, %7i, %5i',
			\ l:tick[0].(printf('.%06i', l:tick[1]))[: 2].',',
			\ l:sec != 0
				\ ? l:self.trampolinemoved(l:char / l:sec)
				\ : l:char,
			\ l:char,
			\ l:sec)
	let a:go.a	= reltime()
endfunction								" }}}1

elseif s:parts == 9

function! s:pace.eval2(go) abort					" {{{1
	let l:tick	= reltime(a:go.a)
	let [a:go.b, a:go.c, a:go.d]	=
		\ [(a:go.b + l:tick[0] + (l:tick[1] + a:go.c) / 1000000000),
		\ ((l:tick[1] + a:go.c) % 1000000000),
		\ (a:go.d + 1)]
	let a:go.a	= reltime()
endfunction

function! s:pace.eval1(go) abort					" {{{1
	let l:tick	= reltime(a:go.a)
	let [a:go.b, a:go.c, a:go.d]	=
		\ [(a:go.b + l:tick[0] + (l:tick[1] + a:go.c) / 1000000000),
		\ ((l:tick[1] + a:go.c) % 1000000000),
		\ (a:go.d + 1)]
	let [l:char, l:sec]	= [(a:go.d + a:go.e), (a:go.b + a:go.f)]
	let g:pace_info		= printf('%-9s %2i, %7i, %5i',
			\ l:tick[0].(printf('.%09i', l:tick[1]))[: 2].',',
			\ (l:char / l:sec),
			\ l:char,
			\ l:sec)
	let a:go.a	= reltime()
endfunction

function! s:pace.eval0(go) abort					" {{{1
	let l:tick	= reltime(a:go.a)
	let [a:go.b, a:go.c, a:go.d]	=
		\ [(a:go.b + l:tick[0] + (l:tick[1] + a:go.c) / 1000000000),
		\ ((l:tick[1] + a:go.c) % 1000000000),
		\ (a:go.d + 1)]
	let [l:char, l:sec]	= [(a:go.d + a:go.e), (a:go.b + a:go.f)]
	let g:pace_info		= printf('%-9s %2i, %7i, %5i',
			\ l:tick[0].(printf('.%09i', l:tick[1]))[: 2].',',
			\ l:sec != 0
				\ ? l:self.trampolinemoved(l:char / l:sec)
				\ : l:char,
			\ l:char,
			\ l:sec)
	let a:go.a	= reltime()
endfunction								" }}}1

else
	throw 'My mind is going...'
endif

else

" The 1e+06 constants rely on 1e-06 seconds obtainable from reltimestr().

function! s:pace.time(tick) abort					" {{{1
	let l:unit	= reltimestr(a:tick)
	return [str2nr(l:unit), str2nr(l:unit[-6 :])]
endfunction

function! s:pace.eval2(go) abort					" {{{1
	let l:unit	= reltimestr(reltime(a:go.a))
	let l:micros	= str2nr(l:unit[-6 :]) + a:go.c
	let [a:go.b, a:go.c, a:go.d]	=
		\ [(a:go.b + str2nr(l:unit) + l:micros / 1000000),
		\ (l:micros % 1000000),
		\ (a:go.d + 1)]
	let a:go.a	= reltime()
endfunction

function! s:pace.eval1(go) abort					" {{{1
	let l:unit	= reltimestr(reltime(a:go.a))
	let l:micros	= str2nr(l:unit[-6 :]) + a:go.c
	let [a:go.b, a:go.c, a:go.d]	=
		\ [(a:go.b + str2nr(l:unit) + l:micros / 1000000),
		\ (l:micros % 1000000),
		\ (a:go.d + 1)]
	let [l:char, l:sec]	= [(a:go.d + a:go.e), (a:go.b + a:go.f)]
	let g:pace_info		= printf('%-9s %2i, %7i, %5i',
			\ str2nr(l:unit).l:unit[-7 : -5].',',
			\ (l:char / l:sec),
			\ l:char,
			\ l:sec)
	let a:go.a	= reltime()
endfunction

function! s:pace.eval0(go) abort					" {{{1
	let l:unit	= reltimestr(reltime(a:go.a))
	let l:micros	= str2nr(l:unit[-6 :]) + a:go.c
	let [a:go.b, a:go.c, a:go.d]	=
		\ [(a:go.b + str2nr(l:unit) + l:micros / 1000000),
		\ (l:micros % 1000000),
		\ (a:go.d + 1)]
	let [l:char, l:sec]	= [(a:go.d + a:go.e), (a:go.b + a:go.f)]
	let g:pace_info		= printf('%-9s %2i, %7i, %5i',
			\ str2nr(l:unit).l:unit[-7 : -5].',',
			\ l:sec != 0
				\ ? l:self.trampolinemoved(l:char / l:sec)
				\ : l:char,
			\ l:char,
			\ l:sec)
	let a:go.a	= reltime()
endfunction								" }}}1

endif

function! s:pace.trampolinemoved(value) abort				" {{{1
	autocmd! pace CursorMovedI
	autocmd pace CursorMovedI	* call s:pace.eval1(s:turn)
	return a:value
endfunction

function! s:pace.trampolinehold(value) abort				" {{{1
	autocmd! pace CursorHoldI
	autocmd pace CursorHoldI	* call s:pace.sample1(s:turn)
	return a:value
endfunction

function! s:pace.div(dividend, divisor) abort				" {{{1
	return a:divisor ? (a:dividend / a:divisor) : a:dividend
endfunction

function! s:pace.sample2(go) abort					" {{{1
	let [l:char, l:sec]	= [(a:go.d + a:go.e), (a:go.b + a:go.f)]
	let g:pace_info		= printf('%-9s %2i, %7i, %5i',
						\ '0.00,',
						\ l:self.div(l:char, l:sec),
						\ l:char,
						\ l:sec)
endfunction

function! s:pace.sample1(go) abort					" {{{1
	let [l:char, l:sec]	= [(a:go.d + a:go.e), (a:go.b + a:go.f)]
	let g:pace_info		= printf('%-9s %2i, %7i, %5i',
						\ '0.00,',
						\ (l:char / l:sec),
						\ l:char,
						\ l:sec)
endfunction

function! s:pace.sample0(go) abort					" {{{1
	let [l:char, l:sec]	= [(a:go.d + a:go.e), (a:go.b + a:go.f)]
	let g:pace_info		= printf('%-9s %2i, %7i, %5i',
			\ '0.00,',
			\ l:sec != 0
				\ ? l:self.trampolinehold(l:char / l:sec)
				\ : l:char,
			\ l:char,
			\ l:sec)
endfunction

function! s:pace.msg(fname, entry) abort				" {{{1
	echomsg printf('%s: @%i: %s',
				\ split(a:fname, '\v%(\.\.|\s+)')[-1],
				\ localtime(),
				\ a:entry)
endfunction

function! s:pace.test(pass) abort					" {{{1
	if !exists('#pace')
		" Redefine the _pace_ group, but do not touch its commands!
		augroup pace
		augroup END
	endif

	if exists('#pace#CursorHoldI')
		autocmd! pace CursorHoldI
	endif

	if exists('#pace#CursorMovedI')
		autocmd! pace CursorMovedI
	endif

	if exists('#pace#InsertLeave')
		autocmd! pace InsertLeave
	endif

	if exists('g:pace_policy') && type(g:pace_policy) == type(0)
		if g:pace_policy != l:self.policy &&
				\ g:pace_policy =~ '\<1[012][01][012][0-7]\>'
			call l:self.msg(expand('<sfile>'),
					\ printf('g:pace_policy: %i->%i',
							\ l:self.policy,
							\ g:pace_policy))
			let l:self.policy	= g:pace_policy
		endif

		unlet g:pace_policy
	endif

	if exists('g:pace_sample') && type(g:pace_sample) == type(0)
		if g:pace_sample != l:self.sample.in
			let [l:within, l:candidate]	=
					\ g:pace_sample > l:self.sample.above
				\ ? [0, (l:self.sample.above + 5)]
				\ : g:pace_sample < l:self.sample.below
					\ ? [0, (l:self.sample.below - 5)]
					\ : [1, g:pace_sample]

			if l:candidate != l:self.sample.in
				if l:within != 0
					let &updatetime	= l:candidate
				elseif !(l:self.sample.in > l:self.sample.above ||
						\ l:self.sample.in <
							\ l:self.sample.below)
					let &updatetime	= l:self.state.updatetime
				endif

				call l:self.msg(expand('<sfile>'),
					\ printf('g:pace_sample: %i->%i',
							\ l:self.sample.in,
							\ l:candidate))
				let l:self.sample.in	= l:candidate
			endif
		endif

		unlet g:pace_sample
	endif

	if s:turn.d < 0
		return -1
	elseif !s:turn.d && !l:self.policy[2]
		let s:turn.c	= l:self.carry
		return 4				" Discard null.
	elseif !a:pass
		return 0				" pace.leave() exit.
	elseif !l:self.policy[3]
		let s:turn.c	= l:self.carry
		return 2				" Discard rejects.
	endif

	try
		let l:self.mark	= l:self.policy[3] == 2	" Add (-) to hit.
		return l:self.leave()			" Collect rejects.
	finally
		let l:self.mark	= 0
	endtry
endfunction

function! s:pace.leave() abort						" {{{1
	let l:recordchar_tick	= reltime(l:self.epoch)

	if &maxfuncdepth < 16		" An arbitrary bound.
		set maxfuncdepth&
	endif				" What if :doautocmd pace InsertLeave?

	if !(l:self.sample.in < l:self.sample.below)
		if l:self.sample.in > l:self.sample.above
			" Counter the overhead of transition from CursorMovedI
			" to InsertLeave by not rounding up.
			call l:self.recordunit(s:turn,
				\ [l:self.time(l:recordchar_tick)[0], 0])
		endif

		if exists('g:pace_info')
			unlockvar g:pace_info
		endif

		call l:self.sample2(s:turn)
	endif

	if l:self.test(0)
		return 1
	elseif !has_key(l:self.dump, l:self.buffer)
		let l:self.dump[l:self.buffer]	= [[0, 0, 0, 0]]
	endif

	" Update the logged hits and the whole count.
	let l:whole		= l:self.dump[0][0]
	let l:whole[0 : 3]	+= [1, 0, s:turn.d, s:turn.b]
	unlet! g:pace_amin
	let g:pace_amin		= l:self.div((l:whole[2] * 60), l:whole[3])
	lockvar g:pace_amin

	if exists('g:pace_info')
		lockvar g:pace_info
	endif

	" Append a new hit instance and fetch the buffer total entry.
	let l:total	= add(l:self.dump[l:self.buffer],
				\ [(l:self.mark ? -l:whole[0] : l:whole[0]),
				\ l:self.time(l:self.epoch)[0],
				\ s:turn.d,
				\ s:turn.b])[0]
	let [l:total[0], l:total[1]]	= [(l:total[0] + 1), l:whole[0]]
	let [l:total[2], l:total[3]]	+= [s:turn.d, s:turn.b]
	let [s:turn.b, s:turn.d]	= [-1, -1]	" Invalidate the count.
	let l:self.pool		= {}			" Invalidate the pool.
	let l:self.carry	= s:turn.c		" Copy for rejects &c.
endfunction

function! s:pace.swap(buffer) abort					" {{{1
	let l:status	= get(l:self.status, l:self.buffer, &g:statusline)

	if bufwinnr(l:self.buffer) > 0		" Protect from local change.
		" Ferret out any doppel-gänger windows.
		call filter(range(1, winnr('$')),
					\ printf('winbufnr(v:val) == %d
				\ ? setwinvar(v:val, "&statusline", %s)
				\ : 0',
			\ l:self.buffer,
			\ string(l:status)))
	elseif bufexists(l:self.buffer)
		execute 'sbuffer '.l:self.buffer
		call setbufvar(l:self.buffer, '&statusline', l:status)
		silent! close!
	endif

	if l:self.buffer == a:buffer
		return 1
	endif

	let [l:self.status[a:buffer], l:self.buffer]	= [&l:statusline, a:buffer]
endfunction

function! s:pace.enter() abort						" {{{1
	if &maxfuncdepth < 16		" An arbitrary bound.
		set maxfuncdepth&
	endif				" Graduate a sounding-rod before _test_.

	call l:self.test(1)		" Make allowance for any leftovers.

	" Leave and enter gracefully at the switch.  (Although the current
	" mode may be masked, what its InsertChange complement is can be
	" undecidable without recourse to mode book-keeping: [r->]i->r or
	" [v->]i->v.)
	autocmd! pace InsertChange
	autocmd pace InsertChange	* call s:pace.leave()
	autocmd pace InsertChange	* call s:pace.enter()

	if &eventignore =~? '\v%(all|insert%(enter|change|leave)|cursor%(hold|moved)i)'
		call l:self.msg(expand('<sfile>'), '&eventignore mask')
		return -128
	elseif !l:self.policy[4] ||
		\ (v:insertmode == 'i' && l:self.policy[4] !~ '[1357]') ||
		\ (v:insertmode == 'r' && l:self.policy[4] !~ '[2367]') ||
		\ (v:insertmode == 'v' && l:self.policy[4] !~ '[4567]')
		return -1		" Imitate and(l:self.policy[4], 1) &c.
	endif

	if !&laststatus
		set laststatus&
	endif

	if !&ruler
		set ruler
	endif

	" Pre-empt the statusline value and substitute it for the one assembled.
	if bufnr('%') != l:self.buffer || len(filter(range(1, winnr('$')),
			\ printf('winbufnr(v:val) == %d', l:self.buffer))) > 1
		call l:self.swap(bufnr('%'))
	endif

	" Select the base count values for reporting.
	let [s:turn.e, s:turn.f]	= l:self.policy[1] == 1
		\ ? [l:self.dump[0][0][2], l:self.dump[0][0][3]]
		\ : l:self.policy[1] == 2 &&
					\ has_key(l:self.dump, l:self.buffer)
			\ ? [l:self.dump[l:self.buffer][0][2],
					\ l:self.dump[l:self.buffer][0][3]]
			\ : [0, 0]
	let l:self.dump[0][0][1]	+= 1		" All InsertEnter hits.
	let [s:turn.b, s:turn.d]	= [0, 0]	" Initialise the count.
	unlet! g:pace_info	" Fits: 27:46:39 wait|type @ 99 char/sec pace.
	let g:pace_info	= printf('%-9s %2i, %7i, %5i',
				\ '0.00,',
				\ l:self.div(s:turn.e, s:turn.f),
				\ s:turn.e,
				\ s:turn.f)

	if &laststatus != 2 && winnr('$') == 1
		set rulerformat=%-48([%{g:pace_info}]%)\ %<%l,%c%V\ %=%P
	else
		setlocal statusline=%<%f\ %h%m%r%=[%{g:pace_info}]
					\\ %-14.14(%l,%c%V%)\ %P rulerformat&
	endif

	if l:self.sample.in > l:self.sample.above
		if !exists('#pace#CursorMovedI#*')
			autocmd pace CursorMovedI	* let s:turn.d	+= 1
		endif
	elseif l:self.sample.in < l:self.sample.below
		if !exists('#pace#CursorMovedI#*')
			autocmd pace CursorMovedI	* call s:pace.eval0(s:turn)
		endif
	else
		if !exists('#pace#CursorHoldI#*')
			autocmd pace CursorHoldI	* call s:pace.sample0(s:turn)
		endif

		if !exists('#pace#CursorMovedI#*')
			autocmd pace CursorMovedI	* call s:pace.eval2(s:turn)
		endif
	endif

	if !exists('#pace#InsertLeave#*')
		autocmd pace InsertLeave	* call s:pace.leave()
	endif

	let [s:turn.a, l:self.epoch]	= [reltime(), reltime()]
endfunction

function! Pace_Load(entropy) abort					" {{{1
	if type(a:entropy) == type(0) && !a:entropy
		if !s:pace.load || mode() != 'n'
			return 1
		endif

		call s:pace.swap(bufnr('%'))
		let &g:statusline	= s:pace.state.statusline
		let &rulerformat	= s:pace.state.rulerformat
		let &ruler		= s:pace.state.ruler
		let &maxfuncdepth	= s:pace.state.maxfuncdepth
		let &laststatus		= s:pace.state.laststatus
		let &updatetime		= s:pace.state.updatetime

		" Counter the overhead of reltime() by not rounding up.
		let s:turn.b		= -1
		let s:turn.c		= 0
		let s:pace.carry	= 0
		let s:pace.load		= 0
		silent! autocmd! pace
		return 2
	elseif &eventignore =~? '\v%(all|insert%(enter|change|leave)|cursor%(hold|moved)i)'
		call s:pace.msg(expand('<sfile>'), '&eventignore mask')
		return -128
	elseif s:pace.load
		return -1
	endif

	let s:pace.state.updatetime	= &updatetime
	let s:pace.state.laststatus	= &laststatus
	let s:pace.state.maxfuncdepth	= &maxfuncdepth
	let s:pace.state.ruler		= &ruler
	let s:pace.state.rulerformat	= &rulerformat
	let s:pace.state.statusline	= &g:statusline
	setglobal ruler statusline=%<%f\ %h%m%r%=%-14.14(%l,%c%V%)\ %P
	let s:pace.buffer	= bufnr('%')
	let s:pace.load		= 1
	let s:pace.status[s:pace.buffer]	= &l:statusline

	if exists('g:pace_sample') && type(g:pace_sample) == type(0)
		if exists('g:pace_collect_garbage_early') &&
				\ !(g:pace_sample > s:pace.sample.above ||
						\ g:pace_sample <
							\ s:pace.sample.below)
			unlet g:pace_collect_garbage_early

			" Libate Wine-bottled GUI builds before their first
			" sampling.  (The availability of the variable is left
			" undocumented.)
			call garbagecollect()
		endif
	elseif !(s:pace.sample.in > s:pace.sample.above ||
				\ s:pace.sample.in < s:pace.sample.below)
		let &updatetime	= s:pace.sample.in
	endif

	augroup pace
		autocmd! pace
		autocmd InsertEnter	* call s:pace.enter()
	augroup END
endfunction

function! Pace_Dump(entropy) abort					" {{{1
	if type(a:entropy) == type(0) && !a:entropy
		return deepcopy(s:pace.dump, 1)
	elseif !empty(s:pace.pool)			" pace.leave() empties.
		let s:pace.pool['_rejects']	= printf('%+31i',
			\ (s:pace.dump[0][0][1] - s:pace.dump[0][0][0]))
		return copy(s:pace.pool)
	endif

	let s:pace.pool	= {
		\ '_buffers':	'pace    chars     secs     hits',
		\ '_rejects':	printf('%+31i',
			\ (s:pace.dump[0][0][1] - s:pace.dump[0][0][0])),
	\ }

	for l:i in keys(s:pace.dump)
		let [l:hits, l:last, l:char, l:sec]	=
						\ s:pace.dump[l:i][0][0 : 3]
		let s:pace.pool[printf('%08i', l:i)]	= printf('%4i %8i %8i %8i',
						\ s:pace.div(l:char, l:sec),
						\ l:char,
						\ l:sec,
						\ l:hits)
	endfor

	return copy(s:pace.pool)
endfunction

function! Pace_Free() abort						" {{{1
	if !exists('s:pace') || mode() != 'n'
		return 0
	endif

	try
		let s:pace.load	= 1
		call Pace_Dump(1)
		call Pace_Load(0)
	catch	/^Vim\%((\a\+)\)\=:E117/		" An unknown function.
		call s:pace.swap(bufnr('%'))
		silent! autocmd! pace
	finally
		silent! delcommand PaceOn
		silent! delcommand PaceOff
		silent! delcommand PaceSum
		silent! delcommand PaceDump
		silent! delcommand PaceSaveTo
		silent! delfunction Pace_Load
		silent! delfunction Pace_Dump
		unlet! g:pace_dump g:pace_pool
		let g:pace_dump	= s:pace.dump
		let g:pace_pool	= s:pace.pool
		silent! augroup! pace
		unlet s:pace s:turn
	endtry

	return 1
endfunction								" }}}1

command! -bar PaceOn	:echo Pace_Load(1)
command! -bar PaceOff	:echo Pace_Load(0)
command! -bar PaceSum	:echo join(sort(items(Pace_Dump(1))), "\n")
command! -bar -nargs=*
	\ PaceDump	:echo len([<f-args>]) == 3
	\ ? Pace_Dump(0)[[<f-args>][0]][[<f-args>][1]][[<f-args>][2]]
	\ : len([<f-args>]) == 2
		\ ? Pace_Dump(0)[[<f-args>][0]][[<f-args>][1]]
		\ : len([<f-args>]) == 1
			\ ? Pace_Dump(0)[[<f-args>][0]]
			\ : Pace_Dump(0)
command! -bar PaceFree	:echo Pace_Free()

if has('modify_fname')
command! -bar -nargs=1 -complete=dir
	\ PaceSaveTo	:echo writefile(['let g:pace_dump = '
						\ .string(Pace_Dump(0))],
				\ fnamemodify(expand(<q-args>), ':p')
						\ .'/pace_'
						\ .localtime())
command! -bar -nargs=1 -complete=file
	\ PaceDemo	:execute 'lcd '
				\ .fnamemodify(expand(<q-args>), ':p:h')
				\ .' | source '
				\ .fnamemodify(expand(<q-args>), ':p')
endif

lockvar 1 s:pace s:turn
let g:pace_lock	= 1
let &cpoptions	= s:cpoptions
unlet s:parts s:cpoptions

" vim:fdm=marker:sw=8:ts=8:noet:nolist:nosta:
