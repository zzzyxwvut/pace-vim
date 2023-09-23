vim9script

# Description:	A _sample_ runner for the "Sample*" functions (Vim 9.0)
# Author:	Aliaksei Budavei (0x000c70 AT gmail DOT com)
# Version:	2.0
# Last Change:	2023-Sep-23
# Copyleft ())
#
# Dependencies:	cmdline_info, eval, reltime, and statusline features.
#
# Usage:	This script is run by "../profiler.vim".
#
# Caveats:	The "winheight" option is set to 1.

if !(has('reltime') && has('cmdline_info') && has('statusline'))
	finish
endif

var epoch: list<number> = reltime()
lockvar epoch
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

def Record_Char(go: dict<any>)
	go.d += 1
enddef

if parts == 9

def Record_Unit(go: dict<any>, time: list<number>)
	[go.b, go.c] = [(go.b + time[0] + (time[1] + go.c) / 1000000000),
			((time[1] + go.c) % 1000000000)]
enddef

else

def Record_Unit(go: dict<any>, time: list<number>)
	[go.b, go.c] = [(go.b + time[0] + (time[1] + go.c) / 1000000),
			((time[1] + go.c) % 1000000)]
enddef

endif

if parts == 6 || parts == 9

def Time(tick: list<number>): list<number>
	return tick
enddef

else

def Time(tick: list<number>): list<number>
	const unit: string = reltimestr(tick)
	return [str2nr(unit), str2nr(unit[-6 :])]
enddef

endif

if parts == 6

def Eval2(go: dict<any>)
	const tick: list<number> = reltime(go.a)
	[go.b, go.c, go.d] =
			[(go.b + tick[0] + (tick[1] + go.c) / 1000000),
			((tick[1] + go.c) % 1000000),
			(go.d + 1)]
	go.a = reltime()
enddef

elseif parts == 9

def Eval2(go: dict<any>)
	const tick: list<number> = reltime(go.a)
	[go.b, go.c, go.d] =
			[(go.b + tick[0] + (tick[1] + go.c) / 1000000000),
			((tick[1] + go.c) % 1000000000),
			(go.d + 1)]
	go.a = reltime()
enddef

else

# The 1e+06 constants rely on 1e-06 seconds obtainable from reltimestr().

def Eval2(go: dict<any>)
	const unit: string = reltimestr(reltime(go.a))
	const micros: number = str2nr(unit[-6 :]) + go.c
	[go.b, go.c, go.d] =
			[(go.b + str2nr(unit) + micros / 1000000),
			(micros % 1000000),
			(go.d + 1)]
	go.a = reltime()
enddef

endif

def Sample1(go: dict<any>)
	g:runner_info = printf('%-9s %2i, %7i, %5i',
						'0.00,',
						(go.d / go.b),
						go.d,
						go.b)
enddef

def Sample0(go: dict<any>)
	g:runner_info = printf('%-9s %2i, %7i, %5i',
						'0.00,',
						go.b != 0
							? (go.d / go.b)
							: go.d,
						go.d,
						go.b)
enddef

def MSQM_Map_And_Take(value: any, maximum: number): list<any>
	var limit: number = maximum < 1 ? 1 : maximum
	var seed: number = str2nr(reltimestr(reltime(epoch))[-6 :])
	var key: string = printf('%012i', (seed * seed))[3 : 8]
	var prefix: dict<any> = {}

	while limit > 0 && !has_key(prefix, key)
		prefix[key] = value
		seed = str2nr(key)
		key = printf('%012i', (seed * seed))[3 : 8]
		limit -= 1
	endwhile

	return values(prefix)
enddef

def Print(self: dict<any>, go: dict<any>, times: number, delay: string,
							sample: string)
	if delay !~ 'm$' || sample !~ 'm$'
		throw "Invalid arguments: "
					.. delay
					.. ", "
					.. sample
	endif

	noautocmd belowright keepalt keepjumps :16new +setlocal
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
		const cc: list<string> = split(join(self.text, "\n"), '\zs')
		const z: number = len(cc)
		const x: number = (z - 32) < 1 ? z : (z - 32)
		const s: number = str2nr(sample)

		for i in range(times)
			setline((line('$') + 1), '')
			normal! G
			var n: number = 0
			go.d = 0
			go.b = 0

			if s > 2000
				# Do not interfere with profiling by resetting
				# g:runner_info *and* taking a nap on the turn.
				go.a = reltime()

				while n < z
					@z = cc[n]
					normal! "zp
					Record_Char(go)
					execute 'sleep ' .. delay
					redrawstatus
					n += 1
				endwhile

				const tick: list<number> = reltime(go.a)
				Record_Unit(go, [Time(tick)[0], 0])
				Sample0(go)
			elseif s < 50
				go.a = reltime()

				while go.b < 1 && n < z
					@z = cc[n]
					normal! "zp
					Eval2(go)
					Sample0(go)
					execute 'sleep ' .. delay
					redrawstatus
					n += 1
				endwhile

				while n < z
					@z = cc[n]
					normal! "zp
					Eval2(go)
					Sample1(go)
					execute 'sleep ' .. delay
					redrawstatus
					n += 1
				endwhile
			else
				# Do not interfere with profiling by resetting
				# g:runner_info *and* taking a nap on the turn.
				const jj: list<any> = MSQM_Map_And_Take(delay,
									x) +
								[sample]
				go.a = reltime()

				while go.b < 1 && n < z
					var p: bool = true

					for j in jj
						if go.b < 1 && n < z
							@z = cc[n]
							normal! "zp
							Eval2(go)
							execute 'sleep ' .. j
							redrawstatus
							n += 1
						else
							p = false
							break
						endif
					endfor

					if p
						Sample0(go)
					endif
				endwhile

				while n < z
					var p: bool = true

					for j in jj
						if n < z
							@z = cc[n]
							normal! "zp
							Eval2(go)
							execute 'sleep ' .. j
							redrawstatus
							n += 1
						else
							p = false
							break
						endif
					endfor

					if p
						Sample1(go)
					endif
				endwhile

				Sample0(go)
			endif
		endfor
	finally
		setlocal nomodifiable
		redraw!
	endtry
enddef

def Err_Msg(self: dict<any>, entry: string)
	echohl ErrorMsg | echomsg self.handle .. ': ' .. entry | echohl None
enddef

def g:Update_Runner_S_9_0(fname: string, lines: number,
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
		const sample: string = $UPDATE_SAMPLE_RANGE

		# (Shorter key names shorten lookup time.)
		# a: tick,
		# b: seconds,
		# c: micro- or nano-seconds,
		# d: characters.
		Print(runner, {a: reltime(), b: 0, c: 0, d: 0},
							times,
							delay,
						sample =~? '\<below\>'
					? (50 - 5) .. 'm'
					: sample =~? '\<above\>'
				? (2000 + 5) .. 'm'
				: (str2nr(delay) * 2) .. 'm')	# [100-600]m
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

		unlockvar epoch
		runner = null_dict
		epoch = null_list
	endtry

	return 1
enddef

defcompile

# vim:fdm=syntax:sw=8:ts=8:noet:nolist:nosta:
