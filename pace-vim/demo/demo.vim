vim9script noclear

# Description:	The demo-imitation of the "pace.vim" script
# Author:	Aliaksei Budavei (0x000c70 AT gmail DOT com)
# Repository:	https://github.com/zzzyxwvut/pace-vim.git [vim/9/0/master]
# Bundles:	https://www.vim.org/scripts/script.php?script_id=5472
# Version:	2.0
# Last Change:	2023-Sep-27
# Copyleft ())
#
# Dependencies:	cmdline_info, eval, reltime, and statusline features.
#
#		The "vimvat.txt" sonnet included.
#
# Usage:	Source the file: ":lcd %:p:h | source %".
#
# Notes:	In order to preview any other file, change the values of
#		"text" and "linage" of the s:demo dictionary.  (Read "linage"
#		elements as follows: seek the leftmost 'line_match' as regexp
#		at the accumulated 'line_offset' and print the line and its
#		current 'line_offset' lines that follow; otherwise print
#		a null line.)
#
#		In order to adjust the typing pace, vary s:demo.delay numbers.
#
# Caveats:	The "winheight" option is set to 1.

if !(has('reltime') && has('cmdline_info') && has('statusline'))
	finish
endif

var demo: dict<any> = {
	handle:		expand('<script>'),
	reg_z:		@z,
	delay:		[],
	linage:		[],
	text:		[],
	state:		{
		buffer:		bufnr('%'),
		laststatus:	&laststatus,
		maxfuncdepth:	&maxfuncdepth,
		ruler:		&ruler,
		rulerformat:	&rulerformat,
		winheight:	&winheight,
		equalalways:	&equalalways,
		statusline:	&g:statusline,
	},
}

# Try to roll over the sub-second unit (see profile_sub() of profile.c).
const parts: number = len(reltime()) == 2
	? reduce([reltime([0, 0], [0, -1])],
		(_: number, v: list<number>): number =>
					v[0] == -1 && string(v[1]) =~ '^9\+$'
			? strlen(v[1])
			: 0,
		0)
	: 0

if parts != 6 && parts != 9 && reltimestr(reltime())[-7 : -7] != '.'
	throw 'My mind is going...'
endif

if parts == 6

def Eval1(go: dict<any>)						# {{{1
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

def Eval0(go: dict<any>)						# {{{1
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

elseif parts == 9

def Eval1(go: dict<any>)						# {{{1
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

def Eval0(go: dict<any>)						# {{{1
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

# The 1e+06 constants rely on 1e-06 seconds obtainable from reltimestr().

def Eval1(go: dict<any>)						# {{{1
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

def Eval0(go: dict<any>)						# {{{1
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

def Print(self: dict<any>, go: dict<any>, i: number, j: number,		# {{{1
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

def Run(self: dict<any>, go: dict<any>)					# {{{1
	const z: number = len(self.text)
	var t: number = len(self.linage) - 1
	var p: number = -1
	var n: number = 0
	var m: number = 0
	go.a = reltime()

	for item in self.linage
		while n < z && self.text[n] !~# item.match
			n += 1
		endwhile

		[m, p] = n < z ? [n, n] : [m, -1]
		Print(self, go, p,
			(item.offset + p), item.name,
			(item.offset + 1), t)
		n = m + item.offset + 1
		t -= 1
	endfor
enddef

def Err_Msg(self: dict<any>, entry: string)				# {{{1
	echohl ErrorMsg | echomsg self.handle .. ': ' .. entry | echohl None
enddef

def Fetch(fname: string, lines: number): list<string>			# {{{1
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
	Err_Msg(demo, "Cannot make changes")
	demo = null_dict
	finish
endif

try
	demo.text = Fetch('vimvat.txt', 20)
	demo.linage = [
		{name: '1st\ quatrain', match: '^Of _vim_', offset: 3},
		{name: '2nd\ quatrain', match: '^Mnem0nic\$', offset: 3},
		{name: '3rd\ quatrain', match: '^No pop-ups', offset: 3},
		{name: 'the\ couplet', match: '^Go to,', offset: 1},
	]	# [buffer_name, line_match, line_offset]
	demo.delay = [70, 90, 80, 60]
	lockvar demo.delay demo.linage demo.text

	if has('autocmd') && &eventignore !~? '\v%(all|vimresized)'
		augroup demo
			autocmd! demo
			autocmd VimResized	* redraw!
		augroup END
	endif

	setglobal maxfuncdepth& rulerformat& ruler
	setglobal statusline=%<%f\ %h%m%r%=%-14.14(%l,%c%V%)\ %P
	unlet! g:demo_info
	g:demo_info = printf('%-9s %2i, %7i, %5i', '0.00,', 0, 0, 0)

	if !&laststatus
		set laststatus&
	endif

	if winnr('$') > 1
		only
	endif

	redraw!
	lockvar 1 demo

	# (Shorter key names shorten lookup time.)
	# a: tick,
	# b: seconds,
	# c: micro- or nano-seconds,
	# d: characters.
	Run(demo, {a: reltime(), b: 0, c: 0, d: 0})
catch	/^Vim:Interrupt$/	# Silence this error message.
finally
#	if demo == null_dict	# See Vim patch 9.0.1501 (issues/12245).
#		finish
#	endif

	@z = demo.reg_z
	&g:statusline = demo.state.statusline
	&equalalways = demo.state.equalalways
#	&winheight = demo.state.winheight
	&rulerformat = demo.state.rulerformat
	&ruler = demo.state.ruler
	&maxfuncdepth = demo.state.maxfuncdepth
	&laststatus = demo.state.laststatus
	var switchbuf: string = &switchbuf

	try
		setglobal switchbuf=useopen
		execute 'sbuffer ' .. demo.state.buffer
		lcd -
	catch	/.*/
		Err_Msg(demo, v:exception)
	finally
		&switchbuf = switchbuf
	endtry

	unlockvar 1 demo
	switchbuf = null_string
	demo = null_dict
	silent! autocmd! demo
	silent! augroup! demo
endtry

# vim:fdm=marker:sw=8:ts=8:noet:nolist:nosta:
