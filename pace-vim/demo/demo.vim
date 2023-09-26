" Description:	The demo-imitation of the "pace.vim" script
" Author:	Aliaksei Budavei (0x000c70 AT gmail DOT com)
" Repository:	https://github.com/zzzyxwvut/pace-vim.git [vim/7/0/master]
" Bundles:	https://www.vim.org/scripts/script.php?script_id=5472
" Version:	1.2
" Last Change:	2023-Sep-19
" Copyleft ())
"
" Dependencies:	cmdline_info, eval, reltime, and statusline features.
"
"		The "vimvat.txt" sonnet included.
"
" Usage:	Source the file: ":lcd %:p:h | source %".
"
" Notes:	In order to preview any other file, change the values of
"		"text" and "linage" of the s:demo dictionary.  (Read "linage"
"		elements as follows: seek the leftmost 'line_match' as regexp
"		at the accumulated 'line_offset' and print the line and its
"		current 'line_offset' lines that follow; otherwise print
"		a null line.)
"
"		In order to adjust the typing pace, vary s:demo.delay numbers.
"
" Caveats:	The "winheight" option is set to 1.

let s:cpoptions	= &cpoptions
set cpoptions-=C					" Join line-breaks.

if !(has('reltime') && has('cmdline_info') && has('statusline'))
	let &cpoptions	= s:cpoptions
	unlet s:cpoptions
	finish
endif

let s:demo	= {
	\ 'handle':	expand('<sfile>'),
	\ 'reg_z':	@z,
	\ 'delay':	[],
	\ 'linage':	[],
	\ 'text':	[],
	\ 'state':	{
		\ 'buffer':		bufnr('%'),
		\ 'laststatus':		&laststatus,
		\ 'maxfuncdepth':	&maxfuncdepth,
		\ 'ruler':		&ruler,
		\ 'rulerformat':	&rulerformat,
		\ 'winheight':		&winheight,
		\ 'equalalways':	&equalalways,
		\ 'statusline':		&g:statusline,
	\ },
\ }

" Try to roll over the sub-second unit (see profile_sub() of profile.c).
let s:parts	= len(reltime()) == 2
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

function! s:demo.eval1(go) abort					" {{{1
	let l:tick	= reltime(a:go.a)
	let [a:go.b, a:go.c, a:go.d]	=
		\ [(a:go.b + l:tick[0] + (l:tick[1] + a:go.c) / 1000000),
		\ ((l:tick[1] + a:go.c) % 1000000),
		\ (a:go.d + 1)]
	let g:demo_info		= printf('%-9s %2i, %7i, %5i',
		\ l:tick[0].(printf('.%06i', l:tick[1]))[: 2].',',
		\ (a:go.d / a:go.b),
		\ a:go.d,
		\ a:go.b)
	let a:go.a	= reltime()
endfunction

function! s:demo.eval0(go) abort					" {{{1
	let l:tick	= reltime(a:go.a)
	let [a:go.b, a:go.c, a:go.d]	=
		\ [(a:go.b + l:tick[0] + (l:tick[1] + a:go.c) / 1000000),
		\ ((l:tick[1] + a:go.c) % 1000000),
		\ (a:go.d + 1)]
	let g:demo_info		= printf('%-9s %2i, %7i, %5i',
		\ l:tick[0].(printf('.%06i', l:tick[1]))[: 2].',',
		\ a:go.b != 0
			\ ? (a:go.d / a:go.b)
			\ : a:go.d,
		\ a:go.d,
		\ a:go.b)
	let a:go.a	= reltime()
endfunction								" }}}1

elseif s:parts == 9

function! s:demo.eval1(go) abort					" {{{1
	let l:tick	= reltime(a:go.a)
	let [a:go.b, a:go.c, a:go.d]	=
		\ [(a:go.b + l:tick[0] + (l:tick[1] + a:go.c) / 1000000000),
		\ ((l:tick[1] + a:go.c) % 1000000000),
		\ (a:go.d + 1)]
	let g:demo_info		= printf('%-9s %2i, %7i, %5i',
		\ l:tick[0].(printf('.%09i', l:tick[1]))[: 2].',',
		\ (a:go.d / a:go.b),
		\ a:go.d,
		\ a:go.b)
	let a:go.a	= reltime()
endfunction

function! s:demo.eval0(go) abort					" {{{1
	let l:tick	= reltime(a:go.a)
	let [a:go.b, a:go.c, a:go.d]	=
		\ [(a:go.b + l:tick[0] + (l:tick[1] + a:go.c) / 1000000000),
		\ ((l:tick[1] + a:go.c) % 1000000000),
		\ (a:go.d + 1)]
	let g:demo_info		= printf('%-9s %2i, %7i, %5i',
		\ l:tick[0].(printf('.%09i', l:tick[1]))[: 2].',',
		\ a:go.b != 0
			\ ? (a:go.d / a:go.b)
			\ : a:go.d,
		\ a:go.d,
		\ a:go.b)
	let a:go.a	= reltime()
endfunction								" }}}1

else

" The 1e+06 constants rely on 1e-06 seconds obtainable from reltimestr().

function! s:demo.eval1(go) abort					" {{{1
	let l:unit	= reltimestr(reltime(a:go.a))
	let l:micros	= str2nr(l:unit[-6 :]) + a:go.c
	let [a:go.b, a:go.c, a:go.d]	=
		\ [(a:go.b + str2nr(l:unit) + l:micros / 1000000),
		\ (l:micros % 1000000),
		\ (a:go.d + 1)]
	let g:demo_info		= printf('%-9s %2i, %7i, %5i',
		\ str2nr(l:unit).l:unit[-7 : -5].',',
		\ (a:go.d / a:go.b),
		\ a:go.d,
		\ a:go.b)
	let a:go.a	= reltime()
endfunction

function! s:demo.eval0(go) abort					" {{{1
	let l:unit	= reltimestr(reltime(a:go.a))
	let l:micros	= str2nr(l:unit[-6 :]) + a:go.c
	let [a:go.b, a:go.c, a:go.d]	=
		\ [(a:go.b + str2nr(l:unit) + l:micros / 1000000),
		\ (l:micros % 1000000),
		\ (a:go.d + 1)]
	let g:demo_info		= printf('%-9s %2i, %7i, %5i',
		\ str2nr(l:unit).l:unit[-7 : -5].',',
		\ a:go.b != 0
			\ ? (a:go.d / a:go.b)
			\ : a:go.d,
		\ a:go.d,
		\ a:go.b)
	let a:go.a	= reltime()
endfunction								" }}}1

endif

function! s:demo.print(go, i, j, name, lines, times) abort		" {{{1
	if a:lines < 1
		return
	endif

	execute 'noautocmd belowright keepalt keepjumps '.a:lines.'new +setlocal
		\\ bufhidden=hide\ buftype=nofile\ foldcolumn&\ nobuflisted\ noswapfile
		\\ statusline=%<%f\\\ %h%m%r%=[%{g:demo_info}]\\\ %-14.14(%l,%c%V%)\\\ %P
		\\ textwidth=0\ winheight&\ winfixheight\ noequalalways +'.a:name.'+'

	if !&l:modifiable
		setlocal modifiable
	endif

	if &l:readonly
		setlocal noreadonly
	endif

	if join(getbufline('%', 1, a:lines), '') != ''
		" Add some empty lines at the buffer end and set cursor there.
		call map(range(a:lines), "setline((line('$') + 1), '')")
		normal! G
	endif

	try
		if a:i < 0 || a:j < 0 || a:i > a:j
			return
		endif

		let l:cc	= split(join(l:self.text[a:i : a:j], "\n"), '\zs')
		let l:z		= len(l:cc)
		let l:g		= len(l:self.delay)
		lockvar l:g l:z l:cc
		let l:k		= localtime() % l:g		" Seed [0-3].
		let l:n		= 0

		while a:go.b < 1 && l:n < l:z
			let @z	= l:cc[l:n]
			normal! "zp
			call l:self.eval0(a:go)
			execute 'sleep '.l:self.delay[l:k % l:g].'m'
			redrawstatus
			let l:k	+= 1
			let l:n	+= 1
		endwhile

		while l:n < l:z
			let @z	= l:cc[l:n]
			normal! "zp
			call l:self.eval1(a:go)
			execute 'sleep '.l:self.delay[l:k % l:g].'m'
			redrawstatus
			let l:k	+= 1
			let l:n	+= 1
		endwhile
	finally
		if a:times > 0
			call setbufvar(bufnr('%'), '&statusline', '')
			normal! gg
		endif

		setlocal nomodifiable
		redraw!
	endtry
endfunction

function! s:demo.run(go) abort						" {{{1
	let l:z	= len(l:self.text)
	let l:t	= len(l:self.linage) - 1
	let l:n	= 0
	let l:m	= 0
	let a:go.a	= reltime()

	for l:item in l:self.linage
		while l:n < l:z && l:self.text[l:n] !~# l:item.match
			let l:n	+= 1
		endwhile

		let [l:m, l:p]	= l:n < l:z ? [l:n, l:n] : [l:m, -1]
		call l:self.print(a:go,
					\ l:p,
					\ (l:item.offset + l:p),
					\ l:item.name,
					\ (l:item.offset + 1),
					\ l:t)
		let l:n	= l:m + l:item.offset + 1
		let l:t	-= 1
	endfor
endfunction

function! s:demo.errmsg(entry) abort					" {{{1
	echohl ErrorMsg | echomsg l:self.handle.': '.a:entry | echohl None
endfunction

function! s:demo.fetch(fname, lines) abort				" {{{1
	if !filereadable(a:fname)
		call l:self.errmsg('`'
				\ .a:fname
				\ ."': No such file")
		return []
	endif

	let l:text	= readfile(a:fname, '', a:lines)

	if len(l:text) < a:lines
		call l:self.errmsg('`'
				\ .a:fname
				\ ."': Invalid line count: "
				\ .len(l:text)
				\ ." < "
				\ .a:lines)
		return []
	endif

	let l:columns	= max(map(l:text[:], 'strlen(v:val)'))

	if winwidth(0) < l:columns
		call l:self.errmsg("Narrow width: "
				\ .winwidth(0)
				\ ." < "
				\ .l:columns)
		return []
	endif

	return l:text
endfunction								" }}}1

if !&g:modifiable || &g:readonly
	call s:demo.errmsg("Cannot make changes")
	let &cpoptions	= s:cpoptions
	unlet s:parts s:demo s:cpoptions
	finish
endif

try
	let s:demo.text		= s:demo.fetch('vimvat.txt', 20)
	let s:demo.linage	= [
		\ {'name': '1st\ quatrain', 'match': '^Of _vim_', 'offset': 3},
		\ {'name': '2nd\ quatrain', 'match': '^Mnem0nic\$', 'offset': 3},
		\ {'name': '3rd\ quatrain', 'match': '^No pop-ups', 'offset': 3},
		\ {'name': 'the\ couplet', 'match': '^Go to,', 'offset': 1},
	\ ]	" [buffer_name, line_match, line_offset]
	let s:demo.delay	= [70, 90, 80, 60]
	lockvar s:demo.delay s:demo.linage s:demo.text

	if has('autocmd') && &eventignore !~? '\v%(all|vimresized)'
		augroup demo
			autocmd! demo
			autocmd VimResized	* redraw!
		augroup END
	endif

	setglobal maxfuncdepth& rulerformat& ruler
	setglobal statusline=%<%f\ %h%m%r%=%-14.14(%l,%c%V%)\ %P
	unlet! g:demo_info
	let g:demo_info	= printf('%-9s %2i, %7i, %5i', '0.00,', 0, 0, 0)

	if !&laststatus
		set laststatus&
	endif

	if winnr('$') > 1
		only
	endif

	redraw!
	lockvar 1 s:demo

	" (Shorter key names shorten lookup time.)
	" a: tick,
	" b: seconds,
	" c: micro- or nano-seconds,
	" d: characters.
	call s:demo.run({'a': reltime(), 'b': 0, 'c': 0, 'd': 0})
catch	/^Vim:Interrupt$/	" Silence this error message.
finally
	let @z			= s:demo.reg_z
	let &g:statusline	= s:demo.state.statusline
	let &equalalways	= s:demo.state.equalalways
"	let &winheight		= s:demo.state.winheight
	let &rulerformat	= s:demo.state.rulerformat
	let &ruler		= s:demo.state.ruler
	let &maxfuncdepth	= s:demo.state.maxfuncdepth
	let &laststatus		= s:demo.state.laststatus
	let &cpoptions		= s:cpoptions
	let s:switchbuf		= &switchbuf

	try
		setglobal switchbuf=useopen
		execute 'sbuffer '.s:demo.state.buffer
		lcd -
	catch	/.*/
		call s:demo.errmsg(v:exception)
	finally
		let &switchbuf	= s:switchbuf
	endtry

	unlet s:switchbuf s:parts s:demo s:cpoptions
	silent! autocmd! demo
	silent! augroup! demo
endtry

" vim:fdm=marker:sw=8:ts=8:noet:nolist:nosta:
