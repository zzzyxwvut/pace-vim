vim9script noclear

# Description:	The demo-imitation of the "pace.vim" script
# Author:	Aliaksei Budavei (0x000c70 AT gmail DOT com)
# Repository:	https://github.com/zzzyxwvut/pace-vim.git [vim/9/1/master]
# Bundles:	https://www.vim.org/scripts/script.php?script_id=5472
# Version:	3.0
# Last Change:	2023-Dec-30
# Copyleft ())
#
# Dependencies:	cmdline_info, eval, reltime, and statusline features.
#
#		The "vimvat.txt" sonnet included.
#
# Usage:	Source the file: ":lcd %:p:h | source %".
#
# Notes:	In order to preview any other file, change the passed lists
#		for "text" and "linage" of a Demo constructor.  (Read Linage
#		elements as follows: seek the leftmost 'line_match' as regexp
#		at the accumulated 'line_offset' and print the line and its
#		current 'line_offset' lines that follow; otherwise print
#		a null line.)
#
#		In order to adjust the typing pace, vary the passed numbers
#		for "delay" of a Demo constructor.
#
# Caveats:	The "winheight" option is set to 1.

if !(has('reltime') && has('cmdline_info') && has('statusline'))
	finish
endif

# Fancy at-source-time function despatch and classes with anaemic behaviour.

# (Shorter field names shorten lookup time.)
class Turn
	public var a: list<number> = reltime()	# tick
	public var b: number = 0		# seconds
	public var c: number = 0		# micro- or nano-seconds
	public var d: number = 0		# characters

	def new()
	enddef
endclass

class Linage
	const name: string
	const match: string
	const offset: number

	def new(this.name, this.match, this.offset)
	enddef
endclass

class State
	const buffer: number = bufnr('%')
	const equalalways: bool = &equalalways
	const laststatus: number = &laststatus
	const maxfuncdepth: number = &maxfuncdepth
	const ruler: bool = &ruler
	const rulerformat: string = &rulerformat
	const statusline: string = &g:statusline
	const winheight: number = &winheight

	def new()
	enddef

	def Restore()
		&equalalways = this.equalalways
		&laststatus = this.laststatus
		&maxfuncdepth = this.maxfuncdepth
		&ruler = this.ruler
		&rulerformat = this.rulerformat
		&g:statusline = this.statusline
####		&winheight = this.winheight
	enddef
endclass

class Demo
	static const handle: string = expand('<script>')

	const reg_z: string = @z
	const delay: list<number> = []
	const linage: list<Linage> = []
	const text: list<string> = []
	const state: State = State.new()

	def new(this.text, this.linage)
		this.delay = [70, 90, 80, 60]
	enddef

	def newWithDelay(this.text, this.linage, this.delay)
	enddef
endclass

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

def Eval1(go: Turn)
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

def Eval0(go: Turn)
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
enddef

elseif parts == 9

def Eval1(go: Turn)
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

def Eval0(go: Turn)
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
enddef

else

# The 1e+06 constants rely on 1e-06 seconds obtainable from reltimestr().

def Eval1(go: Turn)
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

def Eval0(go: Turn)
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
enddef

endif

def Print(self: Demo, go: Turn, i: number, j: number, name: string,
						lines: number, times: number)
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

def Run(self: Demo, go: Turn)
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

def Err_Msg(entry: string)
	echohl ErrorMsg | echomsg Demo.handle .. ': ' .. entry | echohl None
enddef

def Fetch(fname: string, lines: number): list<string>
	if !filereadable(fname)
		Err_Msg('`' .. fname
				.. "': No such file")
		return []
	endif

	const text: list<string> = readfile(fname, '', lines)

	if len(text) < lines
		Err_Msg('`' .. fname
				.. "': Invalid line count: "
				.. len(text)
				.. " < "
				.. lines)
		return []
	endif

	const columns: number = max(map(text[:],
				(_: number, value: string): number =>
							strlen(value)))

	if winwidth(0) < columns
		Err_Msg("Narrow width: "
				.. winwidth(0)
				.. " < "
				.. columns)
		return []
	endif

	return text
enddef

defcompile
var turn: Turn = null_object
var demo: Demo = null_object

if !&g:modifiable || &g:readonly
	Err_Msg("Cannot make changes")
	finish
endif

try
	demo = Demo.newWithDelay(
		Fetch('vimvat.txt', 20),
		[
			Linage.new('1st\ quatrain', '^Of _vim_', 3),
			Linage.new('2nd\ quatrain', '^Mnem0nic\$', 3),
			Linage.new('3rd\ quatrain', '^No pop-ups', 3),
			Linage.new('the\ couplet', '^Go to,', 1),
		],	# (buffer_name, line_match, line_offset)
		[70, 90, 80, 60])
	turn = Turn.new()

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
	Run(demo, turn)
catch	/^Vim:Interrupt$/	# Silence this error message.
finally
	@z = demo.reg_z
	demo.state.Restore()
	var switchbuf: string = &switchbuf

	try
		setglobal switchbuf=useopen
		execute 'sbuffer ' .. demo.state.buffer
		lcd -
	catch	/.*/
		Err_Msg(v:exception)
	finally
		&switchbuf = switchbuf
	endtry

	unlockvar 1 demo
	switchbuf = null_string
	demo = null_object
	turn = null_object
	silent! autocmd! demo
	silent! augroup! demo
endtry

# vim:fdm=syntax:sw=8:ts=8:noet:nolist:nosta:
