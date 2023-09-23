vim9script

# Description:	A _list_ runner for the "Eval*" functions (Vim 9.0)
# Author:	Aliaksei Budavei (0x000c70 AT gmail DOT com)
# Version:	2.0
# Last Change:	2023-Sep-23
# Copyleft ())
#
# Dependencies:	cmdline_info, eval, reltime, and statusline features.
#
# Caveats:	The "winheight" option is set to 1.

if !(has('reltime') && has('cmdline_info') && has('statusline'))
	finish
endif

var runner: dict<any> = {handle: expand('<script>'), reg_z: @z, text: []}

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

def Eval1(go: list<any>)
	const tick: list<number> = reltime(go[0])
	[go[1], go[2], go[3]] =
			[(go[1] + tick[0] + (tick[1] + go[2]) / 1000000),
			((tick[1] + go[2]) % 1000000),
			(go[3] + 1)]
	g:runner_info = printf('%-9s %2i, %7i, %5i',
			tick[0] .. (printf('.%06i', tick[1]))[: 2] .. ',',
			(go[3] / go[1]),
			go[3],
			go[1])
	go[0] = reltime()
enddef

def Eval0(go: list<any>)
	const tick: list<number> = reltime(go[0])
	[go[1], go[2], go[3]] =
			[(go[1] + tick[0] + (tick[1] + go[2]) / 1000000),
			((tick[1] + go[2]) % 1000000),
			(go[3] + 1)]
	g:runner_info = printf('%-9s %2i, %7i, %5i',
			tick[0] .. (printf('.%06i', tick[1]))[: 2] .. ',',
			go[1] != 0
				? (go[3] / go[1])
				: go[3],
			go[3],
			go[1])
	go[0] = reltime()
enddef

elseif parts == 9

def Eval1(go: list<any>)
	const tick: list<number> = reltime(go[0])
	[go[1], go[2], go[3]] =
			[(go[1] + tick[0] + (tick[1] + go[2]) / 1000000000),
			((tick[1] + go[2]) % 1000000000),
			(go[3] + 1)]
	g:runner_info = printf('%-9s %2i, %7i, %5i',
			tick[0] .. (printf('.%09i', tick[1]))[: 2] .. ',',
			(go[3] / go[1]),
			go[3],
			go[1])
	go[0] = reltime()
enddef

def Eval0(go: list<any>)
	const tick: list<number> = reltime(go[0])
	[go[1], go[2], go[3]] =
			[(go[1] + tick[0] + (tick[1] + go[2]) / 1000000000),
			((tick[1] + go[2]) % 1000000000),
			(go[3] + 1)]
	g:runner_info = printf('%-9s %2i, %7i, %5i',
			tick[0] .. (printf('.%09i', tick[1]))[: 2] .. ',',
			go[1] != 0
				? (go[3] / go[1])
				: go[3],
			go[3],
			go[1])
	go[0] = reltime()
enddef

else

# The 1e+06 constants rely on 1e-06 seconds obtainable from reltimestr().

def Eval1(go: list<any>)
	const unit: string = reltimestr(reltime(go[0]))
	const micros: number = str2nr(unit[-6 :]) + go[2]
	[go[1], go[2], go[3]] =
			[(go[1] + str2nr(unit) + micros / 1000000),
			(micros % 1000000),
			(go[3] + 1)]
	g:runner_info = printf('%-9s %2i, %7i, %5i',
			trim(unit)[: -5] .. ',',
			(go[3] / go[1]),
			go[3],
			go[1])
	go[0] = reltime()
enddef

def Eval0(go: list<any>)
	const unit: string = reltimestr(reltime(go[0]))
	const micros: number = str2nr(unit[-6 :]) + go[2]
	[go[1], go[2], go[3]] =
			[(go[1] + str2nr(unit) + micros / 1000000),
			(micros % 1000000),
			(go[3] + 1)]
	g:runner_info = printf('%-9s %2i, %7i, %5i',
			trim(unit)[: -5] .. ',',
			go[1] != 0
				? (go[3] / go[1])
				: go[3],
			go[3],
			go[1])
	go[0] = reltime()
enddef

endif

def Print(self: dict<any>, go: list<any>, times: number, delay: string)
	noautocmd belowright keepalt keepjumps :16new +setlocal
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
		const cc: list<string> = split(join(self.text, "\n"), '\zs')
		const z: number = len(cc)

		for i in range(times)
			setline((line('$') + 1), '')
			normal! G
			var n: number = 0
			go[3] = 0
			go[1] = 0
			go[0] = reltime()

			while go[1] < 1 && n < z
				@z = cc[n]
				normal! "zp
				Eval0(go)
				execute 'sleep ' .. delay
				redrawstatus
				n += 1
			endwhile

			while n < z
				@z = cc[n]
				normal! "zp
				Eval1(go)
				execute 'sleep ' .. delay
				redrawstatus
				n += 1
			endwhile
		endfor
	finally
		setlocal nomodifiable
		redraw!
	endtry
enddef

def Err_Msg(self: dict<any>, entry: string)
	echohl ErrorMsg | echomsg self.handle .. ': ' .. entry | echohl None
enddef

def g:Access_Runner_LIST_9_0(fname: string, lines: number,
					times: number, delay: string): number
	if runner == null_dict || mode() != 'n'
		return 0
	endif

	const buffer: number = bufnr('%')

	try
		if !&g:modifiable || &g:readonly
			throw 1024
		elseif !filereadable(fname)
			throw 2048
		endif

		runner.text = readfile(fname, '', lines)
		lockvar runner.text
		setglobal maxfuncdepth& rulerformat& ruler
		setglobal statusline=%<%f\ %h%m%r%=%-14.14(%l,%c%V%)\ %P
		unlet! g:runner_info
		g:runner_info = printf('%-9s %2i, %7i, %5i', '0.00,', 0, 0, 0)

		if !&laststatus
			set laststatus&
		endif

		if winnr('$') > 1
			only
		endif

		redraw!

		# (This is a _linked_ list.)
		# 0: tick,
		# 1: seconds,
		# 2: micro- or nano-seconds,
		# 3: characters.
		Print(runner, [reltime(), 0, 0, 0], times, delay)
	catch	/\<1024\>/
		Err_Msg(runner, "Cannot make changes")
	catch	/\<2048\>/
		Err_Msg(runner, '`' .. fname
					.. "': No such file")
	catch	/^Vim:Interrupt$/	# Silence this error message.
	finally
		if runner == null_dict	# See Vim patch 9.0.1501 (issues/12245).
			return 1
		endif

		@z = runner.reg_z
		const switchbuf: string = &switchbuf

		try
			setglobal switchbuf=useopen
			execute 'sbuffer ' .. buffer
		catch	/.*/
			Err_Msg(runner, v:exception)
		finally
			&switchbuf = switchbuf
		endtry

		runner = null_dict
	endtry

	return 1
enddef

defcompile

# vim:fdm=syntax:sw=8:ts=8:noet:nolist:nosta:
