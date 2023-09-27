vim9script noclear

# Description:	Measure the pace of typing (in Insert mode &c.)
# Author:	Aliaksei Budavei (0x000c70 AT gmail DOT com)
# Repository:	https://github.com/zzzyxwvut/pace-vim.git [vim/9/0/master]
# Bundles:	https://www.vim.org/scripts/script.php?script_id=5472
# Version:	2.0
# Last Change:	2023-Sep-27
# Copyleft ())
#
# Usage:	List all doc/ locations:
#		":echo finddir('doc', &runtimepath, -1)".
#
#		Generate the help tags: ":helptags doc/".
#		Read the documentation: ":help pace.txt".

if exists('g:pace_lock') || !(has('reltime') && has('autocmd') &&
				has('cmdline_info') && has('statusline') &&
				has('user_commands'))
	finish
endif

# Ponder before ridding of s:turn.e ((a sum of) characters) and s:turn.f
# ((a sum of) seconds), and devolving their duties upon s:turn.d (characters)
# and s:turn.b (seconds).
#
# s:turn.e ((a sum of) characters): s:Enter() offers no way of telling event
# calls from command line calls; consider that one may quit typing with
# Ctrl-c, should now s:turn.b (seconds) serve to distinguish between aborted-
# `null' and normal-exit records, now s:pace.dump[0][0][2] == s:turn.d (i.e.
# the total and the recent character counts)?  Should the rejected character
# count be deducted from the s:turn.d figure in s:Enter()?
#
# s:turn.f ((a sum of) seconds): reltime() returns the time elapsed between
# events, whereas the total seconds spent typing is the sum of all such runs;
# therefore, provide another entry that would hold the sum of all Normal-mode
# time and subtract its value from the value of reltime(first_hit, last_hit)
# in s:Leave().
#
# Moreover, s:turn.d (characters) and s:turn.b (seconds) must accommodate any
# run count policy: single (0000), all (1000), or buffer (2000).

# (Shorter key names shorten lookup time.)
# a: tick,
# b: seconds,
# c: micro- or nano-seconds,
# d: characters,
# e: (a sum of) characters,
# f: (a sum of) seconds.
var turn: dict<any> = {a: reltime(), b: -1, c: 0, d: -1, e: 0, f: 0}

var pace: dict<any> = {
	buffer:		bufnr('%'),
	policy:		0x10007,
	carry:		0,
	load:		false,
	mark:		false,
	epoch:		reltime(),
	dump:			exists('g:pace_dump') &&
				type(g:pace_dump) == type({}) &&
				has_key(g:pace_dump, '0') &&
					0 == max(map(map(values(g:pace_dump),
			'(type(get((type(v:val) == type([]) ? v:val : []), 0))
								\ == type([]) &&
				\ len(v:val[0]) == 4 ? v:val[0] : [""])'),
			'(type(get(v:val, 0)) != type(0) ? 1 : 0) +
				\ (type(get(v:val, 1)) != type(0) ? 1 : 0) +
				\ (type(get(v:val, 2)) != type(0) ? 1 : 0) +
				\ (type(get(v:val, 3)) != type(0) ? 1 : 0)'))

			# Call either g:Pace_Dump() or g:Pace_Free() to obtain
			# g:pace_dump.
			? deepcopy(<dict<list<list<number>>>>g:pace_dump, 1)

			# The 0th key value follows a uniform depth: [[]].
			: {'0': [[0, 0, 0, 0]]},
	pool:		{},
	sample:		{
		above:		2000,
		below:		50,
		in:		(50 - 5),
	},
	state:		{
		laststatus:	&laststatus,
		maxfuncdepth:	&maxfuncdepth,
		ruler:		&ruler,
		rulerformat:	&rulerformat,
		statusline:	&g:statusline,
		updatetime:	&updatetime,
	},
	status:		{},
}
lockvar pace.sample.above pace.sample.below

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

if parts == 9

def Record_Unit(go: dict<any>, time: list<number>)			# {{{1
	[go.b, go.c] = [(go.b + time[0] + (time[1] + go.c) / 1000000000),
			((time[1] + go.c) % 1000000000)]
enddef									# }}}1

else

def Record_Unit(go: dict<any>, time: list<number>)			# {{{1
	[go.b, go.c] = [(go.b + time[0] + (time[1] + go.c) / 1000000),
			((time[1] + go.c) % 1000000)]
enddef									# }}}1

endif

if parts == 6 || parts == 9

def Time(tick: list<number>): list<number>				# {{{1
	return tick
enddef									# }}}1

if parts == 6

def Eval2(go: dict<any>)						# {{{1
	const tick: list<number> = reltime(go.a)
	[go.b, go.c, go.d] =
			[(go.b + tick[0] + (tick[1] + go.c) / 1000000),
			((tick[1] + go.c) % 1000000),
			(go.d + 1)]
	go.a = reltime()
enddef

def Eval1(go: dict<any>)						# {{{1
	const tick: list<number> = reltime(go.a)
	[go.b, go.c, go.d] =
			[(go.b + tick[0] + (tick[1] + go.c) / 1000000),
			((tick[1] + go.c) % 1000000),
			(go.d + 1)]
	const [char: number, sec: number] = [(go.d + go.e), (go.b + go.f)]
	g:pace_info = printf('%-9s %2i, %7i, %5i',
			tick[0] .. (printf('.%06i', tick[1]))[: 2] .. ',',
			(char / sec),
			char,
			sec)
	go.a = reltime()
enddef

def Eval0(go: dict<any>)						# {{{1
	const tick: list<number> = reltime(go.a)
	[go.b, go.c, go.d] =
			[(go.b + tick[0] + (tick[1] + go.c) / 1000000),
			((tick[1] + go.c) % 1000000),
			(go.d + 1)]
	const [char: number, sec: number] = [(go.d + go.e), (go.b + go.f)]
	g:pace_info = printf('%-9s %2i, %7i, %5i',
			tick[0] .. (printf('.%06i', tick[1]))[: 2] .. ',',
			sec != 0
				? Trampoline_Moved(char / sec)
				: char,
			char,
			sec)
	go.a = reltime()
enddef									# }}}1

elseif parts == 9

def Eval2(go: dict<any>)						# {{{1
	const tick: list<number> = reltime(go.a)
	[go.b, go.c, go.d] =
			[(go.b + tick[0] + (tick[1] + go.c) / 1000000000),
			((tick[1] + go.c) % 1000000000),
			(go.d + 1)]
	go.a = reltime()
enddef

def Eval1(go: dict<any>)						# {{{1
	const tick: list<number> = reltime(go.a)
	[go.b, go.c, go.d] =
			[(go.b + tick[0] + (tick[1] + go.c) / 1000000000),
			((tick[1] + go.c) % 1000000000),
			(go.d + 1)]
	const [char: number, sec: number] = [(go.d + go.e), (go.b + go.f)]
	g:pace_info = printf('%-9s %2i, %7i, %5i',
			tick[0] .. (printf('.%09i', tick[1]))[: 2] .. ',',
			(char / sec),
			char,
			sec)
	go.a = reltime()
enddef

def Eval0(go: dict<any>)						# {{{1
	const tick: list<number> = reltime(go.a)
	[go.b, go.c, go.d] =
			[(go.b + tick[0] + (tick[1] + go.c) / 1000000000),
			((tick[1] + go.c) % 1000000000),
			(go.d + 1)]
	const [char: number, sec: number] = [(go.d + go.e), (go.b + go.f)]
	g:pace_info = printf('%-9s %2i, %7i, %5i',
			tick[0] .. (printf('.%09i', tick[1]))[: 2] .. ',',
			sec != 0
				? Trampoline_Moved(char / sec)
				: char,
			char,
			sec)
	go.a = reltime()
enddef									# }}}1

else
	throw 'My mind is going...'
endif

else

# The 1e+06 constants rely on 1e-06 seconds obtainable from reltimestr().

def Time(tick: list<number>): list<number>				# {{{1
	const unit: string = reltimestr(tick)
	return [str2nr(unit), str2nr(unit[-6 :])]
enddef

def Eval2(go: dict<any>)						# {{{1
	const unit: string = reltimestr(reltime(go.a))
	const micros: number = str2nr(unit[-6 :]) + go.c
	[go.b, go.c, go.d] =
			[(go.b + str2nr(unit) + micros / 1000000),
			(micros % 1000000),
			(go.d + 1)]
	go.a = reltime()
enddef

def Eval1(go: dict<any>)						# {{{1
	const unit: string = reltimestr(reltime(go.a))
	const micros: number = str2nr(unit[-6 :]) + go.c
	[go.b, go.c, go.d] =
			[(go.b + str2nr(unit) + micros / 1000000),
			(micros % 1000000),
			(go.d + 1)]
	const [char: number, sec: number] = [(go.d + go.e), (go.b + go.f)]
	g:pace_info = printf('%-9s %2i, %7i, %5i',
			trim(unit)[: -5] .. ',',
			(char / sec),
			char,
			sec)
	go.a = reltime()
enddef

def Eval0(go: dict<any>)						# {{{1
	const unit: string = reltimestr(reltime(go.a))
	const micros: number = str2nr(unit[-6 :]) + go.c
	[go.b, go.c, go.d] =
			[(go.b + str2nr(unit) + micros / 1000000),
			(micros % 1000000),
			(go.d + 1)]
	const [char: number, sec: number] = [(go.d + go.e), (go.b + go.f)]
	g:pace_info = printf('%-9s %2i, %7i, %5i',
			trim(unit)[: -5] .. ',',
			sec != 0
				? Trampoline_Moved(char / sec)
				: char,
			char,
			sec)
	go.a = reltime()
enddef									# }}}1

endif

def Trampoline_Moved(value: number): number				# {{{1
	autocmd! pace CursorMovedI
	autocmd pace CursorMovedI	* Eval1(turn)
	return value
enddef

def Trampoline_Hold(value: number): number				# {{{1
	autocmd! pace CursorHoldI
	autocmd pace CursorHoldI	* Sample1(turn)
	return value
enddef

def Div(dividend: number, divisor: number): number			# {{{1
	return divisor != 0 ? (dividend / divisor) : dividend
enddef

def Sample2(go: dict<any>)						# {{{1
	const [char: number, sec: number] = [(go.d + go.e), (go.b + go.f)]
	g:pace_info = printf('%-9s %2i, %7i, %5i',
			'0.00,',
			Div(char, sec),
			char,
			sec)
enddef

def Sample1(go: dict<any>)						# {{{1
	const [char: number, sec: number] = [(go.d + go.e), (go.b + go.f)]
	g:pace_info = printf('%-9s %2i, %7i, %5i',
			'0.00,',
			(char / sec),
			char,
			sec)
enddef

def Sample0(go: dict<any>)						# {{{1
	const [char: number, sec: number] = [(go.d + go.e), (go.b + go.f)]
	g:pace_info = printf('%-9s %2i, %7i, %5i',
			'0.00,',
			sec != 0
				? Trampoline_Hold(char / sec)
				: char,
			char,
			sec)
enddef

def Msg(stack: string, entry: string)					# {{{1
	echomsg printf('%s: @%i: %s',
				split(stack, '\v%(\.\.|\s+)')[-1],
				localtime(),
				entry)
enddef

def Test(self: dict<any>, pass: bool): number				# {{{1
	if !exists('#pace')
		# Redefine the _pace_ group, but do not touch its commands!
		augroup pace
		augroup END
	endif

	if exists('#pace#CursorHoldI')
		autocmd! pace CursorHoldI
	endif

	if exists('#pace#CursorMovedI')
		autocmd! pace CursorMovedI
	endif

	if exists('#pace#InsertLeave')
		autocmd! pace InsertLeave
	endif

	if exists('g:pace_policy') && type(g:pace_policy) == type(0)
		const policy_base_16: string = string(g:pace_policy)
		const policy_base_10: number = eval('0x' .. policy_base_16)

		if policy_base_10 != self.policy &&
				policy_base_16 =~ '\<1[012][01][012][0-7]\>'
			Msg(expand('<stack>'),
					printf('g:pace_policy: %x->%s',
							self.policy,
							policy_base_16))
			self.policy = policy_base_10
		endif

		unlet g:pace_policy
	endif

	if exists('g:pace_sample') && type(g:pace_sample) == type(0)
		if g:pace_sample != self.sample.in
			const [within: bool, candidate: number] =
					g:pace_sample > self.sample.above
				? [false, (self.sample.above + 5)]
				: g:pace_sample < self.sample.below
					? [false, (self.sample.below - 5)]
					: [true, g:pace_sample]

			if candidate != self.sample.in
				if within
					&updatetime = candidate
				elseif !(self.sample.in > self.sample.above ||
						self.sample.in <
							self.sample.below)
					&updatetime = self.state.updatetime
				endif

				Msg(expand('<stack>'),
					printf('g:pace_sample: %i->%i',
							self.sample.in,
							candidate))
				self.sample.in = candidate
			endif
		endif

		unlet g:pace_sample
	endif

	if turn.d < 0
		return -1
	elseif turn.d == 0 && and(self.policy, 0x10100) == 0x10000
		turn.c = self.carry
		return 4				# Discard null.
	elseif !pass
		return 0				# s:Leave() exit.
	elseif and(self.policy, 0x10030) == 0x10000
		turn.c = self.carry
		return 2				# Discard rejects.
	endif

	try
		self.mark = and(self.policy, 0x10020) == 0x10020
		return Leave(self)			# Collect rejects.
	finally
		self.mark = false
	endtry

	return 0
enddef

def Leave(self: dict<any>): number					# {{{1
	const record_char_tick: list<number> = reltime(self.epoch)

	if &maxfuncdepth < 16		# An arbitrary bound.
		set maxfuncdepth&
	endif				# What if :doautocmd pace InsertLeave?

	if !(self.sample.in < self.sample.below)
		if self.sample.in > self.sample.above
			# Counter the overhead of transition from CursorMovedI
			# to InsertLeave by not rounding up.
			Record_Unit(turn, [Time(record_char_tick)[0], 0])
		endif

		if exists('g:pace_info')
			unlockvar g:pace_info
		endif

		Sample2(turn)
	endif

	if Test(self, false) != 0
		return 1
	elseif !has_key(self.dump, self.buffer)
		self.dump[self.buffer] = [[0, 0, 0, 0]]
	endif

	# Update the logged hits and the whole count.
	var whole: list<number> = self.dump[0][0]
	[whole[0], whole[2], whole[3]] += [1, turn.d, turn.b]
	unlet! g:pace_amin
	g:pace_amin = Div((whole[2] * 60), whole[3])
	lockvar g:pace_amin

	if exists('g:pace_info')
		lockvar g:pace_info
	endif

	# Append a new hit instance and fetch the buffer total entry.
	var total: list<number> = add(self.dump[self.buffer],
					[(self.mark ? -whole[0] : whole[0]),
					Time(self.epoch)[0],
					turn.d,
					turn.b])[0]
	[total[0], total[1]] = [(total[0] + 1), whole[0]]
	[total[2], total[3]] += [turn.d, turn.b]
	[turn.b, turn.d] = [-1, -1]			# Invalidate the count.
	self.pool = {}					# Invalidate the pool.
	self.carry = turn.c				# Copy for rejects &c.
	return 0
enddef

def Buffer_Matcher(): func(number): func(number, number): bool		# {{{1
	return (buffer) => (_, value) => winbufnr(value) == buffer
enddef

def Status_Setter(): func(func(number, number): bool, string):
					\ func(number, number): bool	# {{{1
	return (Matcher, status) => (_, value) => {
		if Matcher(v:none, value)
			setwinvar(value, '&statusline', status)
		endif

		return true
	}
enddef

def Swap(self: dict<any>, buffer: number)				# {{{1
	const status: string = get(self.status, self.buffer, &g:statusline)

	if bufwinnr(self.buffer) > 0		# Protect from local change.
		# Ferret out any doppel-gänger windows.
		filter(range(1, winnr('$')),
			Status_Setter()(Buffer_Matcher()(self.buffer),
								status))
	elseif bufexists(self.buffer)
		execute 'sbuffer ' .. string(self.buffer)
		setbufvar(self.buffer, '&statusline', status)
		silent! close!
	endif

	if self.buffer != buffer
		[self.status[buffer], self.buffer] = [&l:statusline, buffer]
	endif
enddef

def Enter(self: dict<any>): number					# {{{1
	if &maxfuncdepth < 16		# An arbitrary bound.
		set maxfuncdepth&
	endif				# Graduate a sounding-rod before s:Test().

	Test(self, true)		# Make allowance for any leftovers.

	# Leave and enter gracefully at the switch.  (Although the current
	# mode may be masked, what its InsertChange complement is can be
	# undecidable without recourse to mode book-keeping: [r->]i->r or
	# [v->]i->v.)
	autocmd! pace InsertChange
	autocmd pace InsertChange	* Leave(pace)
	autocmd pace InsertChange	* Enter(pace)

	if &eventignore =~? '\v%(all|insert%(enter|change|leave)|cursor%(hold|moved)i)'
		Msg(expand('<stack>'), '&eventignore mask')
		return -128
	elseif and(self.policy, 0x10007) == 0x10000 ||
		(v:insertmode == 'i' && and(self.policy, 0x10001) != 0x10001) ||
		(v:insertmode == 'r' && and(self.policy, 0x10002) != 0x10002) ||
		(v:insertmode == 'v' && and(self.policy, 0x10004) != 0x10004)
		return -1
	endif

	if !&laststatus
		set laststatus&
	endif

	if !&ruler
		set ruler
	endif

	# Pre-empt the statusline value and substitute it for the one assembled.
	if bufnr('%') != self.buffer || len(filter(range(1, winnr('$')),
					Buffer_Matcher()(self.buffer))) > 1
		Swap(self, bufnr('%'))
	endif

	# Select the base count values for reporting.
	[turn.e, turn.f] = and(self.policy, 0x11000) == 0x11000
		? [self.dump[0][0][2], self.dump[0][0][3]]
		: and(self.policy, 0x12000) == 0x12000 &&
					has_key(self.dump, self.buffer)
			? [self.dump[self.buffer][0][2],
					self.dump[self.buffer][0][3]]
			: [0, 0]
	self.dump[0][0][1] += 1			# All InsertEnter hits.
	[turn.b, turn.d] = [0, 0]		# Initialise the count.
	unlet! g:pace_info	# Fits: 27:46:39 wait|type @ 99 char/sec pace.
	g:pace_info = printf('%-9s %2i, %7i, %5i',
						'0.00,',
						Div(turn.e, turn.f),
						turn.e,
						turn.f)

	if &laststatus != 2 && winnr('$') == 1
		set rulerformat=%-48([%{g:pace_info}]%)\ %<%l,%c%V\ %=%P
	else
		setlocal statusline=%<%f\ %h%m%r%=[%{g:pace_info}]
					\\ %-14.14(%l,%c%V%)\ %P rulerformat&
	endif

	if self.sample.in > self.sample.above
		if !exists('#pace#CursorMovedI#*')
			autocmd pace CursorMovedI	* turn.d += 1
		endif
	elseif self.sample.in < self.sample.below
		if !exists('#pace#CursorMovedI#*')
			autocmd pace CursorMovedI	* Eval0(turn)
		endif
	else
		if !exists('#pace#CursorHoldI#*')
			autocmd pace CursorHoldI	* Sample0(turn)
		endif

		if !exists('#pace#CursorMovedI#*')
			autocmd pace CursorMovedI	* Eval2(turn)
		endif
	endif

	if !exists('#pace#InsertLeave#*')
		autocmd pace InsertLeave	* Leave(pace)
	endif

	[turn.a, self.epoch] = [reltime(), reltime()]
	return 0
enddef

def g:Pace_Load(entropy: number): number				# {{{1
	if entropy == 0
		if !pace.load || mode() != 'n'
			return 1
		endif

		Swap(pace, bufnr('%'))
		&g:statusline = pace.state.statusline
		&rulerformat = pace.state.rulerformat
		&ruler = pace.state.ruler
		&maxfuncdepth = pace.state.maxfuncdepth
		&laststatus = pace.state.laststatus
		&updatetime = pace.state.updatetime

		# Counter the overhead of reltime() by not rounding up.
		turn.b = -1
		turn.c = 0
		pace.carry = 0
		pace.load = false
		silent! autocmd! pace
		return 2
	elseif &eventignore =~? '\v%(all|insert%(enter|change|leave)|cursor%(hold|moved)i)'
		Msg(expand('<stack>'), '&eventignore mask')
		return -128
	elseif pace.load
		return -1
	endif

	pace.state.updatetime = &updatetime
	pace.state.laststatus = &laststatus
	pace.state.maxfuncdepth = &maxfuncdepth
	pace.state.ruler = &ruler
	pace.state.rulerformat = &rulerformat
	pace.state.statusline = &g:statusline
	setglobal ruler statusline=%<%f\ %h%m%r%=%-14.14(%l,%c%V%)\ %P
	pace.buffer = bufnr('%')
	pace.load = true
	pace.status[pace.buffer] = &l:statusline

	if exists('g:pace_sample') && type(g:pace_sample) == type(0)
		if exists('g:pace_collect_garbage_early') &&
				!(g:pace_sample > pace.sample.above ||
						g:pace_sample <
							pace.sample.below)
			unlet g:pace_collect_garbage_early

			# Libate Wine-bottled GUI builds before their first
			# sampling.  (The availability of the variable is left
			# undocumented.)
			garbagecollect()
		endif
	elseif !(pace.sample.in > pace.sample.above ||
				pace.sample.in < pace.sample.below)
		&updatetime = pace.sample.in
	endif

	augroup pace
		autocmd! pace
		autocmd InsertEnter	* Enter(pace)
	augroup END

	return 0
enddef

def g:Pace_Dump(entropy: number): dict<any>				# {{{1
	if entropy == 0
		return deepcopy(pace.dump, 1)
	elseif !empty(pace.pool)			# See s:Leave().
		pace.pool['_rejects'] = printf('%+31i',
			(pace.dump[0][0][1] - pace.dump[0][0][0]))
		return copy(pace.pool)
	endif

	pace.pool = {
		'_buffers':	'pace    chars     secs     hits',
		'_rejects':	printf('%+31i',
			(pace.dump[0][0][1] - pace.dump[0][0][0])),
	}

	for i in keys(pace.dump)
		const [hits: number, _, char: number, sec: number] =
							pace.dump[i][0][0 : 3]
		pace.pool[printf('%08i', eval(i))] = printf('%4i %8i %8i %8i',
							Div(char, sec),
							char,
							sec,
							hits)
	endfor

	return copy(pace.pool)
enddef

def g:Pace_Free(): number						# {{{1
	if pace == null_dict || mode() != 'n'
		return 0
	endif

	try
		pace.load = true
		g:Pace_Dump(1)
		g:Pace_Load(0)
	catch	/^Vim\%((\a\+)\)\=:E117/		# An unknown function.
		Swap(pace, bufnr('%'))
		silent! autocmd! pace
	finally
		if pace == null_dict	# See Vim patch 9.0.1501 (issues/12245).
			return 1
		endif

		silent! delcommand PaceOn
		silent! delcommand PaceOff
		silent! delcommand PaceSum
		silent! delcommand PaceDump
		silent! delcommand PaceSaveTo
		silent! delfunction g:Pace_Load
		silent! delfunction g:Pace_Dump
		unlet! g:pace_dump g:pace_pool
		g:pace_dump = pace.dump
		g:pace_pool = pace.pool
		silent! augroup! pace
		unlockvar 1 pace turn
		pace = null_dict
		turn = null_dict
	endtry

	return 1
enddef									# }}}1

command -bar PaceOn	:echo g:Pace_Load(1)
command -bar PaceOff	:echo g:Pace_Load(0)
command -bar PaceSum	:echo join(sort(items(g:Pace_Dump(1))), "\n")
command -bar -nargs=*
	\ PaceDump	:echo len([<f-args>]) == 3
		\ ? g:Pace_Dump(0)[[<f-args>][0]][eval([<f-args>][1])][eval([<f-args>][2])]
		\ : len([<f-args>]) == 2
			\ ? g:Pace_Dump(0)[[<f-args>][0]][eval([<f-args>][1])]
			\ : len([<f-args>]) == 1
				\ ? g:Pace_Dump(0)[[<f-args>][0]]
				\ : g:Pace_Dump(0)
command -bar PaceFree	:echo g:Pace_Free()

if has('modify_fname')			# Maintain interoperability for Vim 7.

command -bar -nargs=1 -complete=dir
	\ PaceSaveTo	:echo writefile(['let g:pace_dump = '
						\ .. string(g:Pace_Dump(0))],
				\ fnamemodify(expand(<q-args>), ':p')
						\ .. '/pace_'
						\ .. localtime())
command -bar -nargs=1 -complete=file
	\ PaceDemo	:execute 'lcd '
				\ .. fnamemodify(expand(<q-args>), ':p:h')
				\ .. ' | source '
				\ .. fnamemodify(expand(<q-args>), ':p')

endif

defcompile
lockvar 1 pace turn
g:pace_lock = 1

# vim:fdm=marker:sw=8:ts=8:noet:nolist:nosta:
