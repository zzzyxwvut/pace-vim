" Description:	The demo-imitation of the "pace.vim" script
" Author:	Aliaksei Budavei (0x000c70 AT gmail DOT com)
" Repository:	https://github.com/zzzyxwvut/pace-vim.git [vim/9/0/master]
" Bundles:	https://www.vim.org/scripts/script.php?script_id=5472
" Version:	2.0
" Last Change:	2023-Sep-27
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
	\ 'handle':	expand('<script>'),
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

def s:Eval1(go: dict<any>)						# {{{1
	const tick: list<number> = reltime(go.a)
	[go.b, go.c, go.d] =
			[(go.b + tick[0] + (tick[1] + go.c) / 1000000),
			((tick[1] + go.c) % 1000000),
			(go.d + 1)]
	g:demo_info = printf('%-9s %2i, %7i, %5i',
			tick[0] .. (printf('.%06i', tick[1]))[: 2] .. ',',
			(go.d / go.b),
			go.d,
			go.b)
	go.a = reltime()
enddef

def s:Eval0(go: dict<any>)						# {{{1
	const tick: list<number> = reltime(go.a)
	[go.b, go.c, go.d] =
			[(go.b + tick[0] + (tick[1] + go.c) / 1000000),
			((tick[1] + go.c) % 1000000),
			(go.d + 1)]
	g:demo_info = printf('%-9s %2i, %7i, %5i',
			tick[0] .. (printf('.%06i', tick[1]))[: 2] .. ',',
			go.b != 0
				? (go.d / go.b)
				: go.d,
			go.d,
			go.b)
	go.a = reltime()
enddef									# }}}1

elseif s:parts == 9

def s:Eval1(go: dict<any>)						# {{{1
	const tick: list<number> = reltime(go.a)
	[go.b, go.c, go.d] =
			[(go.b + tick[0] + (tick[1] + go.c) / 1000000000),
			((tick[1] + go.c) % 1000000000),
			(go.d + 1)]
	g:demo_info = printf('%-9s %2i, %7i, %5i',
			tick[0] .. (printf('.%09i', tick[1]))[: 2] .. ',',
			(go.d / go.b),
			go.d,
			go.b)
	go.a = reltime()
enddef

def s:Eval0(go: dict<any>)						# {{{1
	const tick: list<number> = reltime(go.a)
	[go.b, go.c, go.d] =
			[(go.b + tick[0] + (tick[1] + go.c) / 1000000000),
			((tick[1] + go.c) % 1000000000),
			(go.d + 1)]
	g:demo_info = printf('%-9s %2i, %7i, %5i',
			tick[0] .. (printf('.%09i', tick[1]))[: 2] .. ',',
			go.b != 0
				? (go.d / go.b)
				: go.d,
			go.d,
			go.b)
	go.a = reltime()
enddef									# }}}1

else

" The 1e+06 constants rely on 1e-06 seconds obtainable from reltimestr().

def s:Eval1(go: dict<any>)						# {{{1
	const unit: string = reltimestr(reltime(go.a))
	const micros: number = str2nr(unit[-6 :]) + go.c
	[go.b, go.c, go.d] =
			[(go.b + str2nr(unit) + micros / 1000000),
			(micros % 1000000),
			(go.d + 1)]
	g:demo_info = printf('%-9s %2i, %7i, %5i',
			trim(unit)[: -5] .. ',',
			(go.d / go.b),
			go.d,
			go.b)
	go.a = reltime()
enddef

def s:Eval0(go: dict<any>)						# {{{1
	const unit: string = reltimestr(reltime(go.a))
	const micros: number = str2nr(unit[-6 :]) + go.c
	[go.b, go.c, go.d] =
			[(go.b + str2nr(unit) + micros / 1000000),
			(micros % 1000000),
			(go.d + 1)]
	g:demo_info = printf('%-9s %2i, %7i, %5i',
			trim(unit)[: -5] .. ',',
			go.b != 0
				? (go.d / go.b)
				: go.d,
			go.d,
			go.b)
	go.a = reltime()
enddef									# }}}1

endif

def s:Print(self: dict<any>, go: dict<any>, i: number, j: number,	# {{{1
				name: string, lines: number, times: number)
	if lines < 1
		return
	endif

	execute 'noautocmd belowright keepalt keepjumps :' .. lines .. 'new +setlocal
		\\ bufhidden=hide\ buftype=nofile\ foldcolumn&\ nobuflisted\ noswapfile
		\\ statusline=%<%f\\\ %h%m%r%=[%{g:demo_info}]\\\ %-14.14(%l,%c%V%)\\\ %P
		\\ textwidth=0\ winheight&\ winfixheight\ noequalalways +' .. name .. '+'

	if !&l:modifiable
		setlocal modifiable
	endif

	if &l:readonly
		setlocal noreadonly
	endif

	if join(getbufline('%', 1, lines), '') != ''
		# Add some empty lines at the buffer end and set cursor there.
		map(range(lines), "setline((line('$') + 1), '')")
		normal! G
	endif

	try
		if i < 0 || j < 0 || i > j
			return
		endif

		const cc: list<string> = split(join(self.text[i : j], "\n"), '\zs')
		const z: number = len(cc)
		const g: number = len(self.delay)
		var k: number = localtime() % g			# Seed [0-3].
		var n: number = 0

		while go.b < 1 && n < z
			@z = cc[n]
			normal! "zp
			Eval0(go)
			execute 'sleep ' .. self.delay[k % g] .. 'm'
			redrawstatus
			k += 1
			n += 1
		endwhile

		while n < z
			@z = cc[n]
			normal! "zp
			Eval1(go)
			execute 'sleep ' .. self.delay[k % g] .. 'm'
			redrawstatus
			k += 1
			n += 1
		endwhile
	finally
		if times > 0
			setbufvar(bufnr('%'), '&statusline', '')
			normal! gg
		endif

		setlocal nomodifiable
		redraw!
	endtry
enddef

function s:demo.run(go) abort						" {{{1
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
		call s:Print(l:self,
				\ a:go,
				\ l:p,
				\ (l:item.offset + l:p),
				\ l:item.name,
				\ (l:item.offset + 1),
				\ l:t)
		let l:n	= l:m + l:item.offset + 1
		let l:t	-= 1
	endfor
endfunction

def s:Err_Msg(self: dict<any>, entry: string)				# {{{1
	echohl ErrorMsg | echomsg self.handle .. ': ' .. entry | echohl None
enddef

def s:Fetch(fname: string, lines: number): list<string>			# {{{1
	if !filereadable(fname)
		Err_Msg(demo, '`'
				.. fname
				.. "': No such file")
		return []
	endif

	const text: list<string> = readfile(fname, '', lines)

	if len(text) < lines
		Err_Msg(demo, '`'
				.. fname
				.. "': Invalid line count: "
				.. len(text)
				.. " < "
				.. lines)
		return []
	endif

	const columns: number = max(map(text[:], 'strlen(v:val)'))

	if winwidth(0) < columns
		Err_Msg(demo, "Narrow width: "
				.. winwidth(0)
				.. " < "
				.. columns)
		return []
	endif

	return text
enddef									# }}}1

defcompile

if !&g:modifiable || &g:readonly
	call s:Err_Msg(s:demo, "Cannot make changes")
	let &cpoptions	= s:cpoptions
	unlet s:parts s:demo s:cpoptions
	finish
endif

try
	let s:demo.text		= s:Fetch('vimvat.txt', 20)
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
		execute 'sbuffer ' .. s:demo.state.buffer
		lcd -
	catch	/.*/
		call s:Err_Msg(s:demo, v:exception)
	finally
		let &switchbuf	= s:switchbuf
	endtry

	unlet s:switchbuf s:parts s:demo s:cpoptions
	silent! autocmd! demo
	silent! augroup! demo
endtry

" vim:fdm=marker:sw=8:ts=8:noet:nolist:nosta:
