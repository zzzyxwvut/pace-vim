" Description:	A _list_ runner for the "Eval*" functions (Vim 7.0)
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

let s:runner = {'handle': expand('<sfile>'), 'reg_z': @z, 'text': []}

" Try to roll over the sub-second unit (see profile_sub() of profile.c).
let s:parts = len(reltime()) == 2
		\ ? map([reltime([0, 0], [0, -1])],
				\ "v:val[0] == -1 && v:val[1] =~ '^9\\+$'
							\ ? strlen(v:val[1])
							\ : 0")[0]
		\ : 0
lockvar s:parts

if s:parts != 6 && s:parts != 9 && reltimestr(reltime())[-7 : -7] != '.'
	throw 'My mind is going...'
endif

if s:parts == 6

function! s:Eval1(go) abort						" {{{1
	let l:tick = reltime(a:go[0])
	let [a:go[1], a:go[2], a:go[3]] =
		\ [(a:go[1] + l:tick[0] + (l:tick[1] + a:go[2]) / 1000000),
		\ ((l:tick[1] + a:go[2]) % 1000000),
		\ (a:go[3] + 1)]
	let g:runner_info = printf('%-9s %2i, %7i, %5i',
		\ l:tick[0].(printf('.%06i', l:tick[1]))[: 2].',',
		\ (a:go[3] / a:go[1]),
		\ a:go[3],
		\ a:go[1])
	let a:go[0] = reltime()
endfunction

function! s:Eval0(go) abort						" {{{1
	let l:tick = reltime(a:go[0])
	let [a:go[1], a:go[2], a:go[3]] =
		\ [(a:go[1] + l:tick[0] + (l:tick[1] + a:go[2]) / 1000000),
		\ ((l:tick[1] + a:go[2]) % 1000000),
		\ (a:go[3] + 1)]
	let g:runner_info = printf('%-9s %2i, %7i, %5i',
		\ l:tick[0].(printf('.%06i', l:tick[1]))[: 2].',',
		\ a:go[1] != 0
			\ ? (a:go[3] / a:go[1])
			\ : a:go[3],
		\ a:go[3],
		\ a:go[1])
	let a:go[0] = reltime()
endfunction								" }}}1

elseif s:parts == 9

function! s:Eval1(go) abort						" {{{1
	let l:tick = reltime(a:go[0])
	let [a:go[1], a:go[2], a:go[3]] =
		\ [(a:go[1] + l:tick[0] + (l:tick[1] + a:go[2]) / 1000000000),
		\ ((l:tick[1] + a:go[2]) % 1000000000),
		\ (a:go[3] + 1)]
	let g:runner_info = printf('%-9s %2i, %7i, %5i',
		\ l:tick[0].(printf('.%09i', l:tick[1]))[: 2].',',
		\ (a:go[3] / a:go[1]),
		\ a:go[3],
		\ a:go[1])
	let a:go[0] = reltime()
endfunction

function! s:Eval0(go) abort						" {{{1
	let l:tick = reltime(a:go[0])
	let [a:go[1], a:go[2], a:go[3]] =
		\ [(a:go[1] + l:tick[0] + (l:tick[1] + a:go[2]) / 1000000000),
		\ ((l:tick[1] + a:go[2]) % 1000000000),
		\ (a:go[3] + 1)]
	let g:runner_info = printf('%-9s %2i, %7i, %5i',
		\ l:tick[0].(printf('.%09i', l:tick[1]))[: 2].',',
		\ a:go[1] != 0
			\ ? (a:go[3] / a:go[1])
			\ : a:go[3],
		\ a:go[3],
		\ a:go[1])
	let a:go[0] = reltime()
endfunction								" }}}1

else

" The 1e+06 constants rely on 1e-06 seconds obtainable from reltimestr().

function! s:Eval1(go) abort						" {{{1
	let l:unit = reltimestr(reltime(a:go[0]))
	let l:micros = str2nr(l:unit[-6 :]) + a:go[2]
	let [a:go[1], a:go[2], a:go[3]] =
		\ [(a:go[1] + str2nr(l:unit) + l:micros / 1000000),
		\ (l:micros % 1000000),
		\ (a:go[3] + 1)]
	let g:runner_info = printf('%-9s %2i, %7i, %5i',
		\ str2nr(l:unit).l:unit[-7 : -5].',',
		\ (a:go[3] / a:go[1]),
		\ a:go[3],
		\ a:go[1])
	let a:go[0] = reltime()
endfunction

function! s:Eval0(go) abort						" {{{1
	let l:unit = reltimestr(reltime(a:go[0]))
	let l:micros = str2nr(l:unit[-6 :]) + a:go[2]
	let [a:go[1], a:go[2], a:go[3]] =
		\ [(a:go[1] + str2nr(l:unit) + l:micros / 1000000),
		\ (l:micros % 1000000),
		\ (a:go[3] + 1)]
	let g:runner_info = printf('%-9s %2i, %7i, %5i',
		\ str2nr(l:unit).l:unit[-7 : -5].',',
		\ a:go[1] != 0
			\ ? (a:go[3] / a:go[1])
			\ : a:go[3],
		\ a:go[3],
		\ a:go[1])
	let a:go[0] = reltime()
endfunction								" }}}1

endif

function! s:runner.print(go, times, delay) abort			" {{{1
	noautocmd belowright keepalt keepjumps 16new +setlocal
		\\ bufhidden=hide\ buftype=nofile\ foldcolumn&\ nobuflisted\ noswapfile
		\\ statusline=%<%f\\\ %h%m%r%=[%{g:runner_info}]\\\ %-14.14(%l,%c%V%)\\\ %P
		\\ textwidth=0\ winheight&\ winfixheight\ noequalalways +access_runner+

	if !&l:modifiable
		setlocal modifiable
	endif

	if &l:readonly
		setlocal noreadonly
	endif

	try
		let l:cc = split(join(l:self.text, "\n"), '\zs')
		let l:z = len(l:cc)
		lockvar l:cc l:z

		for l:i in range(a:times)
			call setline((line('$') + 1), '')
			normal! G
			let l:n = 0
			let a:go[3] = 0
			let a:go[1] = 0
			let a:go[0] = reltime()

			while a:go[1] < 1 && l:n < l:z
				let @z = l:cc[l:n]
				normal! "zp
				call s:Eval0(a:go)
				execute 'sleep '.a:delay
				redrawstatus
				let l:n += 1
			endwhile

			while l:n < l:z
				let @z = l:cc[l:n]
				normal! "zp
				call s:Eval1(a:go)
				execute 'sleep '.a:delay
				redrawstatus
				let l:n += 1
			endwhile
		endfor
	finally
		setlocal nomodifiable
		redraw!
	endtry
endfunction

function! s:runner.errmsg(entry) abort					" {{{1
	echohl ErrorMsg | echomsg l:self.handle.': '.a:entry | echohl None
endfunction

function! Access_Runner_LIST_7_0(fname, lines, times, delay) abort	" {{{1
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

		" (This is a _linked_ list.)
		" 0: tick,
		" 1: seconds,
		" 2: micro- or nano-seconds,
		" 3: characters.
		call s:runner.print([reltime(), 0, 0, 0], a:times, a:delay)
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
""""		silent! delfunction s:Eval0
""""		silent! delfunction s:Eval1
		unlet s:runner
	endtry

	return 1
endfunction								" }}}1

let &cpoptions = s:cpoptions
unlet s:parts s:cpoptions

" vim:fdm=marker:sw=8:ts=8:noet:nolist:nosta:
