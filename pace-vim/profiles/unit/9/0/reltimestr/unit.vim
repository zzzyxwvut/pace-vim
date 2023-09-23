vim9script

# Description:	A _reltimestr_ runner for the "Eval*" functions (Vim 9.0)
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

# The 1e+06 constants rely on 1e-06 seconds obtainable from reltimestr().

def Eval1(go: dict<any>)
	const unit: string = reltimestr(reltime(go.a))
	const micros: number = str2nr(unit[-6 :]) + go.c
	[go.b, go.c, go.d] =
			[(go.b + str2nr(unit) + micros / 1000000),
			(micros % 1000000),
			(go.d + 1)]
	g:runner_info = printf('%-9s %2i, %7i, %5i',
			trim(unit)[: -5] .. ',',
			(go.d / go.b),
			go.d,
			go.b)
	go.a = reltime()
enddef

def Eval0(go: dict<any>)
	const unit: string = reltimestr(reltime(go.a))
	const micros: number = str2nr(unit[-6 :]) + go.c
	[go.b, go.c, go.d] =
			[(go.b + str2nr(unit) + micros / 1000000),
			(micros % 1000000),
			(go.d + 1)]
	g:runner_info = printf('%-9s %2i, %7i, %5i',
			trim(unit)[: -5] .. ',',
			go.b != 0
				? (go.d / go.b)
				: go.d,
			go.d,
			go.b)
	go.a = reltime()
enddef

if empty($UNIT_PROFILE_TRACE)

def Trace(self: dict<any>, go: dict<any>)
enddef

def Report(self: dict<any>)
enddef

else

runner.dump = []

def Trace(self: dict<any>, go: dict<any>)
	const tick: list<number> = reltime(go.a)
	const unit: string = reltimestr(tick)
	add(self.dump, [tick, trim(unit)[: -5]])
enddef

def Report(self: dict<any>)
	writefile(map(self.dump[:], 'string(v:val)'), 'unit_reltimestr.vim')
	remove(self.dump, 0, len(self.dump) - 1)
enddef

endif

def Print(self: dict<any>, go: dict<any>, times: number, delay: string)
	noautocmd belowright keepalt keepjumps :16new +setlocal
		\\ bufhidden=hide\ buftype=nofile\ foldcolumn&\ nobuflisted\ noswapfile
		\\ statusline=%<%f\\\ %h%m%r%=[%{g:runner_info}]\\\ %-14.14(%l,%c%V%)\\\ %P
		\\ textwidth=0\ winheight&\ winfixheight\ noequalalways +unit_runner+

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
			go.d = 0
			go.b = 0
			go.a = reltime()

			while go.b < 1 && n < z
				@z = cc[n]
				normal! "zp
				Trace(self, go)
				Eval0(go)
				execute 'sleep ' .. delay
				redrawstatus
				n += 1
			endwhile

			while n < z
				@z = cc[n]
				normal! "zp
				Trace(self, go)
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

def g:Unit_Runner_RTS_9_0(fname: string, lines: number,
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

		# (Shorter key names shorten lookup time.)
		# a: tick,
		# b: seconds,
		# c: micro- or nano-seconds,
		# d: characters.
		Print(runner, {a: reltime(), b: 0, c: 0, d: 0}, times, delay)
		Report(runner)
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
