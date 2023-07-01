" Description:	A left-right runner for the "eval*" functions (Vim 7.0)
" Author:	Aliaksei Budavei (0x000c70 AT gmail DOT com)
" Version:	1.0
" Last Change:	2023-Jul-01
" Copyleft ())
"
" Dependencies:	cmdline_info, eval, reltime, and statusline features.
"
" Usage:	This script is run by "../profiler.vim".
"
" Caveats:	The "winheight" option is set to 1.

let s:cpoptions = &cpoptions						" {{{1
set cpoptions-=C					" Join line-breaks.

if !(has('reltime') && has('cmdline_info') && has('statusline') &&
							\ len(reltime()) == 2)
	let &cpoptions = s:cpoptions
	unlet s:cpoptions
	finish
endif

let s:runner = {
	\ 'char':	0,
	\ 'sec':	0,
	\ 'microf':	printf('%%0%ii', len(reltime([0, 0], [0, -1])[1])),
	\ 'reg_z':	@z,
	\ 'handle':	expand('<sfile>'),
	\ 'begin':	reltime(),
	\ 'break':	reltime(),
	\ 'file':	[],
\ }

function! s:Eval1(self) abort						" {{{1
	let l:tick = reltime(a:self.break) + reltime(a:self.begin)
	let [a:self.char, a:self.sec] = [(a:self.char + 1), l:tick[2]]
	let g:runner_info = printf('%-9s %2i, %7i, %5i',
		\ l:tick[0].('.'.printf(a:self.microf, l:tick[1]))[:2].',',
		\ (a:self.char / a:self.sec),
		\ a:self.char,
		\ a:self.sec)
	let a:self.break = reltime()
endfunction

function! s:Eval0(self) abort						" {{{1
	let l:tick = reltime(a:self.break) + reltime(a:self.begin)
	let [a:self.char, a:self.sec] = [(a:self.char + 1), l:tick[2]]
	let g:runner_info = printf('%-9s %2i, %7i, %5i',
		\ l:tick[0].('.'.printf(a:self.microf, l:tick[1]))[:2].',',
		\ (a:self.sec != 0
			\ ? a:self.char / a:self.sec
			\ : a:self.char),
		\ a:self.char,
		\ a:self.sec)
	let a:self.break = reltime()
endfunction

function! s:runner.print(times) abort					" {{{1
	noautocmd belowright keepalt keepjumps 16new +setlocal
		\\ bufhidden=hide\ buftype=nofile\ foldcolumn&\ nobuflisted\ noswapfile
		\\ statusline=%<%f\\\ %h%m%r%=[%{g:runner_info}]\\\ %-14.14(%l,%c%V%)\\\ %P
		\\ textwidth=0\ winheight&\ winfixheight\ noequalalways +eval_runner+

	if !&l:modifiable
		setlocal modifiable
	endif

	if &l:readonly
		setlocal noreadonly
	endif

	try
		let l:a = split(join(l:self.file, "\n"), '\zs')
		let l:z = len(l:a)
		lockvar l:a l:z

		for l:x in range(a:times)
			call setline(line('$') + 1, '')
			normal! G
			let l:n = 0
			let l:self.char = 0
			let l:self.sec = 0
			let l:self.break = reltime()
			let l:self.begin = reltime()

			while l:self.sec < 1 && l:n < l:z
				let @z = l:a[l:n]
				normal! "zp
				call s:Eval0(l:self)
				sleep 160m
				redrawstatus
				let l:n += 1
			endwhile

			while l:n < l:z
				let @z = l:a[l:n]
				normal! "zp
				call s:Eval1(l:self)
				sleep 160m
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
	echohl ErrorMsg| echomsg l:self.handle.': '.a:entry| echohl None
endfunction

function! Eval_Runner_LR_7_0(times, fname, ...) abort			" {{{1
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

		let s:runner.file = readfile(a:fname,
					\ '',
					\ a:0 > 0 && type(a:1) == type(0) &&
							\ a:1 > 0 &&
							\ a:1 < 4096
								\ ? a:1
								\ : 1024)
		lockvar s:runner.file
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
		call s:runner.print(a:times < 1 || a:times > 1024 ? 1 : a:times)
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
unlet s:cpoptions

" vim:fdm=marker:sw=8:ts=8:noet:nolist:nosta:
