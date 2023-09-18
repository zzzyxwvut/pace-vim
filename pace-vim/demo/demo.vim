" Description:	The demo-imitation of the "pace.vim" script
" Author:	Aliaksei Budavei (0x000c70 AT gmail DOT com)
" Repository:	https://github.com/zzzyxwvut/pace-vim.git [vim/7/0/master]
" Bundles:	https://www.vim.org/scripts/script.php?script_id=5472
" Version:	1.2
" Last Change:	2023-Sep-18
" Copyleft ())
"
" Dependencies:	cmdline_info, eval, reltime, and statusline features.
"
"		The "vimvat.txt" sonnet included.
"
" Usage:	Source the file: ":lcd %:p:h | so %".
"
" Notes:	In order to preview any other file, change s:demo.data
"		keys' values.
"
"		In order to adjust the typing pace, change s:demo.delay
"		values.
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
	\ 'gear':	4,
	\ 'file':	[],
	\ 'delay':	[70, 90, 80, 60],
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
	\ 'data':	{
		\ 'fname':	'vimvat.txt',
		\ 'cols':	50,
		\ 'lines':	20,
		\ 'turn':	3,
		\ 'part':	[
			\ ['1st\ quatrain',	"'^Of _vim_'",		3],
			\ ['2nd\ quatrain',	"'^Mnem0nic\\$'",	3],
			\ ['3rd\ quatrain',	"'^No pop-ups'",	3],
			\ ['the\ couplet',	"'^Go to,'",		1],
		\ ],
	\ },
\ }			" [ buffer_name, line_match, line_offset ]

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

function! s:demo.eval(go) abort						" {{{1
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

function! s:demo.eval(go) abort						" {{{1
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

function! s:demo.eval(go) abort						" {{{1
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

function! s:demo.print(go, i, j, bname, lines) abort			" {{{1
	execute 'noautocmd belowright keepalt keepjumps '.a:lines.'new +setlocal
		\\ bufhidden=hide\ buftype=nofile\ foldcolumn&\ nobuflisted\ noswapfile
		\\ statusline=%<%f\\\ %h%m%r%=[%{g:demo_info}]\\\ %-14.14(%l,%c%V%)\\\ %P
		\\ textwidth=0\ winheight&\ winfixheight\ noequalalways +'.a:bname.'+'

	if !&l:modifiable
		setlocal modifiable
	endif

	if &l:readonly
		setlocal noreadonly
	endif

	if join(getbufline('%', 1, a:lines), '') != ''
		" Add some empty lines at the buffer end and set cursor there.
		call map(range(a:lines), "setline(line('$') + 1, '')")
		normal! G
	endif

	try
		let l:k		= localtime() % l:self.gear	" Seed [0-3].

		for l:c in split(join(l:self.file[a:i : a:j], "\n"), '\zs')
			let @z	= l:c
			normal! "zp
			call l:self.eval(a:go)
			execute "sleep ".l:self.delay[l:k % l:self.gear]."m"
			redrawstatus
			let l:k	+= 1
		endfor
	finally
		if l:self.data.turn
			call setbufvar(bufnr('%'), '&statusline', '')
			normal! gg
		endif

		setlocal nomodifiable
		redraw!
	endtry
endfunction

function! s:demo.run(go) abort						" {{{1
	let a:go.a	= reltime()

	for [l:bname, l:match, l:off] in l:self.data.part
		let l:at	= index(map(l:self.file[:], "v:val =~# ".l:match), 1)
		call l:self.print(a:go, l:at, (l:off + l:at), l:bname, (l:off + 1))
		let l:self.data.turn	-= 1
	endfor
endfunction

function! s:demo.errmsg(entry) abort					" {{{1
	echohl ErrorMsg| echomsg l:self.handle.': '.a:entry| echohl None
endfunction								" }}}1

try
	if !&g:modifiable || &g:readonly
		throw 1024
	elseif !filereadable(s:demo.data.fname)
		throw 2048
	endif

	let s:demo.file		= readfile(s:demo.data.fname, '', s:demo.data.lines)
	lockvar s:demo.file
	let s:demo.data.cols	= max(map(s:demo.file[:], 'len(v:val)'))

	if len(s:demo.file) < s:demo.data.lines
		throw 4096
	elseif winwidth(0) < s:demo.data.cols
		throw 8192
	endif

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
	let s:demo.gear		= len(s:demo.delay)
	let s:demo.data.turn	= len(s:demo.data.part) - 1

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
catch	/\<1024\>/
	call s:demo.errmsg("Cannot make changes")
catch	/\<2048\>/
	call s:demo.errmsg('`'.s:demo.data.fname."': No such file")
catch	/\<4096\>/
	call s:demo.errmsg('`'.s:demo.data.fname
		\ ."': Invalid line count: ".len(s:demo.file)." < "
					\ .s:demo.data.lines)
catch	/\<8192\>/
	call s:demo.errmsg("Narrow width: ".winwidth(0)." < "
					\ .s:demo.data.cols)
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

	try
		execute 'sbuffer '.s:demo.state.buffer
		lcd -
	catch	/.*/
		call s:demo.errmsg(v:exception)
	endtry

	unlet s:parts s:demo s:cpoptions
	silent! autocmd! demo
	silent! augroup! demo
endtry

" vim:fdm=marker:sw=8:ts=8:noet:nolist:nosta:
