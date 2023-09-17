" Description:	A _sample_ runner for the "Sample*" functions (Vim 7.0)
" Author:	Aliaksei Budavei (0x000c70 AT gmail DOT com)
" Version:	1.0
" Last Change:	2023-Sep-17
" Copyleft ())
"
" Dependencies:	cmdline_info, eval, reltime, and statusline features.
"
" Caveats:	The "winheight" option is set to 1.

let s:cpoptions = &cpoptions
set cpoptions-=C					" Join line-breaks.

if !(has('reltime') && has('cmdline_info') && has('statusline'))
	let &cpoptions = s:cpoptions
	unlet s:cpoptions
	finish
endif

let s:epoch = reltime()
let s:runner = {'handle': expand('<sfile>'), 'reg_z': @z, 'text': []}

" Try to roll over the sub-second unit (see profile_sub() of profile.c).
let s:parts = len(reltime()) == 2
		\ ? map([reltime([0, 0], [0, -1])],
				\ "v:val[0] == -1 && v:val[1] =~ '^9\\+$'
							\ ? strlen(v:val[1])
							\ : 0")[0]
		\ : 0
lockvar s:epoch s:parts

if s:parts != 6 && s:parts != 9 && reltimestr(reltime())[-7 : -7] != '.'
	throw 'My mind is going...'
endif

function! s:Record_Char(go) abort					" {{{1
	let a:go.d += 1
endfunction								" }}}1

if s:parts == 9

function! s:Record_Unit(go, time) abort					" {{{1
	let [a:go.b, a:go.c] =
		\ [(a:go.b + a:time[0] + (a:time[1] + a:go.c) / 1000000000),
		\ ((a:time[1] + a:go.c) % 1000000000)]
endfunction								" }}}1

else

function! s:Record_Unit(go, time) abort					" {{{1
	let [a:go.b, a:go.c] =
		\ [(a:go.b + a:time[0] + (a:time[1] + a:go.c) / 1000000),
		\ ((a:time[1] + a:go.c) % 1000000)]
endfunction								" }}}1

endif

if s:parts == 6 || s:parts == 9

function! s:Time(tick) abort						" {{{1
	return a:tick
endfunction								" }}}1

else

function! s:Time(tick) abort						" {{{1
	let l:unit = reltimestr(a:tick)
	return [str2nr(l:unit), str2nr(l:unit[-6 :])]
endfunction								" }}}1

endif

if s:parts == 6

function! s:Eval2(go) abort						" {{{1
	let l:tick = reltime(a:go.a)
	let [a:go.b, a:go.c, a:go.d] =
		\ [(a:go.b + l:tick[0] + (l:tick[1] + a:go.c) / 1000000),
		\ ((l:tick[1] + a:go.c) % 1000000),
		\ (a:go.d + 1)]
	let a:go.a = reltime()
endfunction								" }}}1

elseif s:parts == 9

function! s:Eval2(go) abort						" {{{1
	let l:tick = reltime(a:go.a)
	let [a:go.b, a:go.c, a:go.d] =
		\ [(a:go.b + l:tick[0] + (l:tick[1] + a:go.c) / 1000000000),
		\ ((l:tick[1] + a:go.c) % 1000000000),
		\ (a:go.d + 1)]
	let a:go.a = reltime()
endfunction								" }}}1

else

" The 1e+06 constants rely on 1e-06 seconds obtainable from reltimestr().

function! s:Eval2(go) abort						" {{{1
	let l:unit = reltimestr(reltime(a:go.a))
	let l:micros = str2nr(l:unit[-6 :]) + a:go.c
	let [a:go.b, a:go.c, a:go.d] =
		\ [(a:go.b + str2nr(l:unit) + l:micros / 1000000),
		\ (l:micros % 1000000),
		\ (a:go.d + 1)]
	let a:go.a = reltime()
endfunction								" }}}1

endif

function! s:Sample1(go) abort						" {{{1
	let g:runner_info = printf('%-9s %2i, %7i, %5i',
				\ '0.00,',
				\ (a:go.d / a:go.b),
				\ a:go.d,
				\ a:go.b)
endfunction

function! s:Sample0(go) abort						" {{{1
	let g:runner_info = printf('%-9s %2i, %7i, %5i',
				\ '0.00,',
				\ a:go.b != 0
					\ ? (a:go.d / a:go.b)
					\ : a:go.d,
				\ a:go.d,
				\ a:go.b)
endfunction

function! s:MSQM_Map_And_Take(value, maximum)				" {{{1
	let l:limit = a:maximum < 1 ? 1 : a:maximum
	let l:seed = str2nr(reltimestr(reltime(s:epoch))[-6 :])
	let l:key = printf('%012i', (l:seed * l:seed))[3 : 8]
	let l:prefix = {}

	while l:limit > 0 && !has_key(l:prefix, l:key)
		let l:prefix[l:key] = a:value
		let l:seed = str2nr(l:key)
		let l:key = printf('%012i', (l:seed * l:seed))[3 : 8]
		let l:limit -= 1
	endwhile

	return values(l:prefix)
endfunction

function! s:runner.print(go, times, delay, sample) abort		" {{{1
	if a:delay !~ 'm$' || a:sample !~ 'm$'
		throw "Invalid arguments: "
					\ .a:delay
					\ .", "
					\ .a:sample
	endif

	noautocmd belowright keepalt keepjumps 16new +setlocal
		\\ bufhidden=hide\ buftype=nofile\ foldcolumn&\ nobuflisted\ noswapfile
		\\ statusline=%<%f\\\ %h%m%r%=[%{g:runner_info}]\\\ %-14.14(%l,%c%V%)\\\ %P
		\\ textwidth=0\ winheight&\ winfixheight\ noequalalways +update_runner+

	if !&l:modifiable
		setlocal modifiable
	endif

	if &l:readonly
		setlocal noreadonly
	endif

	try
		let l:cc = split(join(l:self.text, "\n"), '\zs')
		let l:z = len(l:cc)
		let l:x = (l:z - 32) < 1 ? l:z : (l:z - 32)
		let l:s = str2nr(a:sample)
		lockvar l:s l:x l:z l:cc

		for l:i in range(a:times)
			call setline((line('$') + 1), '')
			normal! G
			let l:n = 0
			let a:go.d = 0
			let a:go.b = 0

			if l:s > 2000
				" Do not interfere with profiling by resetting
				" g:runner_info *and* taking a nap on the turn.
				let a:go.a = reltime()

				while l:n < l:z
					let @z = l:cc[l:n]
					normal! "zp
					call s:Record_Char(a:go)
					execute 'sleep '.a:delay
					redrawstatus
					let l:n += 1
				endwhile

				let l:tick = reltime(a:go.a)
				call s:Record_Unit(a:go, [s:Time(l:tick)[0], 0])
				call s:Sample0(a:go)
			elseif l:s < 50
				let a:go.a = reltime()

				while a:go.b < 1 && l:n < l:z
					let @z = l:cc[l:n]
					normal! "zp
					call s:Eval2(a:go)
					call s:Sample0(a:go)
					execute 'sleep '.a:delay
					redrawstatus
					let l:n += 1
				endwhile

				while l:n < l:z
					let @z = l:cc[l:n]
					normal! "zp
					call s:Eval2(a:go)
					call s:Sample1(a:go)
					execute 'sleep '.a:delay
					redrawstatus
					let l:n += 1
				endwhile
			else
				" Do not interfere with profiling by resetting
				" g:runner_info *and* taking a nap on the turn.
				let l:jj = s:MSQM_Map_And_Take(a:delay, l:x) +
								\ [a:sample]
				let a:go.a = reltime()

				while a:go.b < 1 && l:n < l:z
					let l:p = 1

					for l:j in l:jj
						if a:go.b < 1 && l:n < l:z
							let @z = l:cc[l:n]
							normal! "zp
							call s:Eval2(a:go)
							execute 'sleep '.l:j
							redrawstatus
							let l:n += 1
						else
							let l:p = 0
							break
						endif
					endfor

					if l:p != 0
						call s:Sample0(a:go)
					endif
				endwhile

				while l:n < l:z
					let l:p = 1

					for l:j in l:jj
						if l:n < l:z
							let @z = l:cc[l:n]
							normal! "zp
							call s:Eval2(a:go)
							execute 'sleep '.l:j
							redrawstatus
							let l:n += 1
						else
							let l:p = 0
							break
						endif
					endfor

					if l:p != 0
						call s:Sample1(a:go)
					endif
				endwhile

				call s:Sample0(a:go)
			endif
		endfor
	finally
		setlocal nomodifiable
		redraw!
	endtry
endfunction

function! s:runner.errmsg(entry) abort					" {{{1
	echohl ErrorMsg | echomsg l:self.handle.': '.a:entry | echohl None
endfunction

function! Update_Runner_S_7_0(fname, lines, times, delay) abort		" {{{1
	if !exists('s:runner') || mode() != 'n'
		return 0
	endif

	let l:buffer = bufnr('%')

	try
		if !&g:modifiable || &g:readonly
			throw 1024
		elseif !filereadable(a:fname)
			throw 2048
		endif

		let s:runner.text = readfile(a:fname, '', a:lines)
		lockvar s:runner.text
		setglobal maxfuncdepth& rulerformat& ruler
		setglobal statusline=%<%f\ %h%m%r%=%-14.14(%l,%c%V%)\ %P
		unlet! g:runner_info
		let g:runner_info = printf('%-9s %2i, %7i, %5i', '0.00,', 0, 0, 0)

		if !&laststatus
			set laststatus&
		endif

		if winnr('$') > 1
			only
		endif

		redraw!
		let l:sample = $UPDATE_SAMPLE_RANGE

		" (Shorter key names shorten lookup time.)
		" a: tick,
		" b: seconds,
		" c: micro- or nano-seconds,
		" d: characters.
		call s:runner.print({'a': reltime(), 'b': 0, 'c': 0, 'd': 0},
							\ a:times,
							\ a:delay,
						\ l:sample =~? '\<below\>'
					\ ? (50 - 5).'m'
					\ : l:sample =~? '\<above\>'
				\ ? (2000 + 5).'m'
				\ : (str2nr(a:delay) * 2).'m')	" [100-600]m
	catch	/\<1024\>/
		call s:runner.errmsg("Cannot make changes")
	catch	/\<2048\>/
		call s:runner.errmsg('`'.a:fname."': No such file")
	catch	/^Vim:Interrupt$/	" Silence this error message.
	finally
		let @z = s:runner.reg_z
		let l:switchbuf = &switchbuf

		try
			setglobal switchbuf=useopen
			execute 'sbuffer '.l:buffer
		catch	/.*/
			call s:runner.errmsg(v:exception)
		finally
			let &switchbuf = l:switchbuf
		endtry

		" These functions are still needed for the profiling routine
		" elsewhere.
""""		silent! delfunction s:Eval2
""""		silent! delfunction s:Record_Char
""""		silent! delfunction s:Record_Unit
""""		silent! delfunction s:Sample1
""""		silent! delfunction s:Sample0
		silent! delfunction s:MSQM_Map_And_Take
		silent! delfunction s:Time
		unlet s:runner s:epoch
	endtry

	return 1
endfunction								" }}}1

let &cpoptions = s:cpoptions
unlet s:parts s:cpoptions

" vim:fdm=marker:sw=8:ts=8:noet:nolist:nosta:
