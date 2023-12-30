vim9script noclear

# Description:	Measure the pace of typing (in Insert mode &c.)
# Author:	Aliaksei Budavei (0x000c70 AT gmail DOT com)
# Repository:	https://github.com/zzzyxwvut/pace-vim.git [vim/9/1/master]
# Bundles:	https://www.vim.org/scripts/script.php?script_id=5472
# Version:	3.0
# Last Change:	2023-Dec-30
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

# Ponder before ridding of Turn.e ((a sum of) characters) and Turn.f ((a sum
# of) seconds), and devolving their duties upon Turn.d (characters) and Turn.b
# (seconds).
#
# Turn.e ((a sum of) characters): s:Enter() offers no way of telling event
# calls from command line calls; consider that one may quit typing with
# Ctrl-c, should now Turn.b (seconds) serve to distinguish between aborted-
# `null' and normal-exit records, now s:pace.dump[0][0][2] == Turn.d (i.e.
# the total and the recent character counts)?  Should the rejected character
# count be deducted from the Turn.d figure in s:Enter()?
#
# Turn.f ((a sum of) seconds): reltime() returns the time elapsed between
# events, whereas the total seconds spent typing is the sum of all such runs;
# therefore, provide another entry that would hold the sum of all Normal-mode
# time and subtract its value from the value of reltime(first_hit, last_hit)
# in s:Leave().
#
# Moreover, Turn.d (characters) and Turn.b (seconds) must accommodate any run
# count policy: single (0000), all (1000), or buffer (2000).

# Fancy at-source-time function despatch and classes with anaemic behaviour.

# (Shorter field names shorten lookup time.)
class Turn
	public var a: list<number> = reltime()	# tick
	public var b: number = -1		# seconds
	public var c: number = 0		# micro- or nano-seconds
	public var d: number = -1		# characters
	public var e: number = 0		# (a sum of) characters
	public var f: number = 0		# (a sum of) seconds

	def new()
	enddef
endclass

class State
	const laststatus: number = &laststatus
	const maxfuncdepth: number = &maxfuncdepth
	const ruler: bool = &ruler
	const rulerformat: string = &rulerformat
	const statusline: string = &g:statusline
	const updatetime: number = &updatetime

	def new()
	enddef

	def Restore()
		&laststatus = this.laststatus
		&maxfuncdepth = this.maxfuncdepth
		&ruler = this.ruler
		&rulerformat = this.rulerformat
		&g:statusline = this.statusline
		&updatetime = this.updatetime
	enddef
endclass

class Pace
	static const sample_above: number = 2000
	static const sample_below: number = 50

	public var sample_in: number = sample_below - 5
	public var buffer: number = bufnr('%')
	public var policy: number = 0x10007
	public var carry: number = 0
	public var load: bool = false
	public var mark: bool = false
	public var epoch: list<number> = reltime()
	final dump: dict<list<list<number>>> = exists('g:pace_dump') &&
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
		: {'0': [[0, 0, 0, 0]]}
	public var pool: dict<string> = {}
	final status: dict<string> = {}
	public var state: State = State.new()

	def new()
	enddef
endclass

var turn: Turn = Turn.new()
var pace: Pace = Pace.new()

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

def Record_Unit(go: Turn, time: list<number>)
	[go.b, go.c] = [(go.b + time[0] + (time[1] + go.c) / 1000000000),
			((time[1] + go.c) % 1000000000)]
enddef

else

def Record_Unit(go: Turn, time: list<number>)
	[go.b, go.c] = [(go.b + time[0] + (time[1] + go.c) / 1000000),
			((time[1] + go.c) % 1000000)]
enddef

endif

if parts == 6 || parts == 9

def Time(tick: list<number>): list<number>
	return tick
enddef

if parts == 6

def Eval2(go: Turn)
	const tick: list<number> = reltime(go.a)
	[go.b, go.c, go.d] =
			[(go.b + tick[0] + (tick[1] + go.c) / 1000000),
			((tick[1] + go.c) % 1000000),
			(go.d + 1)]
	go.a = reltime()
enddef

def Eval1(go: Turn)
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

def Eval0(go: Turn)
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
enddef

elseif parts == 9

def Eval2(go: Turn)
	const tick: list<number> = reltime(go.a)
	[go.b, go.c, go.d] =
			[(go.b + tick[0] + (tick[1] + go.c) / 1000000000),
			((tick[1] + go.c) % 1000000000),
			(go.d + 1)]
	go.a = reltime()
enddef

def Eval1(go: Turn)
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

def Eval0(go: Turn)
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
enddef

else
	throw 'My mind is going...'
endif

else

# The 1e+06 constants rely on 1e-06 seconds obtainable from reltimestr().

def Time(tick: list<number>): list<number>
	const unit: string = reltimestr(tick)
	return [str2nr(unit), str2nr(unit[-6 :])]
enddef

def Eval2(go: Turn)
	const unit: string = reltimestr(reltime(go.a))
	const micros: number = str2nr(unit[-6 :]) + go.c
	[go.b, go.c, go.d] =
			[(go.b + str2nr(unit) + micros / 1000000),
			(micros % 1000000),
			(go.d + 1)]
	go.a = reltime()
enddef

def Eval1(go: Turn)
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

def Eval0(go: Turn)
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
enddef

endif

def Trampoline_Moved(value: number): number
	autocmd! pace CursorMovedI
	autocmd pace CursorMovedI	* Eval1(turn)
	return value
enddef

def Trampoline_Hold(value: number): number
	autocmd! pace CursorHoldI
	autocmd pace CursorHoldI	* Sample1(turn)
	return value
enddef

def Div(dividend: number, divisor: number): number
	return divisor != 0 ? (dividend / divisor) : dividend
enddef

def Sample2(go: Turn)
	const [char: number, sec: number] = [(go.d + go.e), (go.b + go.f)]
	g:pace_info = printf('%-9s %2i, %7i, %5i',
			'0.00,',
			Div(char, sec),
			char,
			sec)
enddef

def Sample1(go: Turn)
	const [char: number, sec: number] = [(go.d + go.e), (go.b + go.f)]
	g:pace_info = printf('%-9s %2i, %7i, %5i',
			'0.00,',
			(char / sec),
			char,
			sec)
enddef

def Sample0(go: Turn)
	const [char: number, sec: number] = [(go.d + go.e), (go.b + go.f)]
	g:pace_info = printf('%-9s %2i, %7i, %5i',
			'0.00,',
			sec != 0
				? Trampoline_Hold(char / sec)
				: char,
			char,
			sec)
enddef

def Msg(stack: string, entry: string)
	echomsg printf('%s: @%i: %s',
				split(stack, '\v%(\.\.|\s+)')[-1],
				localtime(),
				entry)
enddef

def Test(self: Pace, pass: bool): number
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
		if g:pace_sample != self.sample_in
			const [within: bool, candidate: number] =
					g:pace_sample > Pace.sample_above
				? [false, (Pace.sample_above + 5)]
				: g:pace_sample < Pace.sample_below
					? [false, (Pace.sample_below - 5)]
					: [true, g:pace_sample]

			if candidate != self.sample_in
				if within
					&updatetime = candidate
				elseif !(self.sample_in > Pace.sample_above ||
						self.sample_in <
							Pace.sample_below)
					&updatetime = self.state.updatetime
				endif

				Msg(expand('<stack>'),
					printf('g:pace_sample: %i->%i',
							self.sample_in,
							candidate))
				self.sample_in = candidate
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

def Leave(self: Pace): number
	const record_char_tick: list<number> = reltime(self.epoch)

	if &maxfuncdepth < 16		# An arbitrary bound.
		set maxfuncdepth&
	endif				# What if :doautocmd pace InsertLeave?

	if !(self.sample_in < Pace.sample_below)
		if self.sample_in > Pace.sample_above
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

def Buffer_Matcher(): func(number): func(number, number): bool
	return (buffer) => (_, value) => winbufnr(value) == buffer
enddef

def Status_Setter(): func(func(number, number): bool, string):
						\ func(number, number): bool
	return (Matcher, status) => (_, value) => {
		if Matcher(v:none, value)
			setwinvar(value, '&statusline', status)
		endif

		return true
	}
enddef

def Swap(self: Pace, buffer: number)
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

def Enter(self: Pace): number
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

	if self.sample_in > Pace.sample_above
		if !exists('#pace#CursorMovedI#*')
			autocmd pace CursorMovedI	* turn.d += 1
		endif
	elseif self.sample_in < Pace.sample_below
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

def g:Pace_Load(entropy: number): number
	if entropy == 0
		if !pace.load || mode() != 'n'
			return 1
		endif

		Swap(pace, bufnr('%'))
		pace.state.Restore()

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

	pace.state = State.new()
	setglobal ruler statusline=%<%f\ %h%m%r%=%-14.14(%l,%c%V%)\ %P
	pace.buffer = bufnr('%')
	pace.load = true
	pace.status[pace.buffer] = &l:statusline

	if exists('g:pace_sample') && type(g:pace_sample) == type(0)
		if exists('g:pace_collect_garbage_early') &&
				!(g:pace_sample > Pace.sample_above ||
						g:pace_sample <
							Pace.sample_below)
			unlet g:pace_collect_garbage_early

			# Libate Wine-bottled GUI builds before their first
			# sampling.  (The availability of the variable is left
			# undocumented.)
			garbagecollect()
		endif
	elseif !(pace.sample_in > Pace.sample_above ||
				pace.sample_in < Pace.sample_below)
		&updatetime = pace.sample_in
	endif

	augroup pace
		autocmd! pace
		autocmd InsertEnter	* Enter(pace)
	augroup END

	return 0
enddef

def g:Pace_Dump(entropy: number): dict<any>
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

def g:Pace_Free(): number
	if pace == null_object || mode() != 'n'
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
		pace = null_object
		turn = null_object
	endtry

	return 1
enddef

command -bar PaceOn	:echo g:Pace_Load(1)
command -bar PaceOff	:echo g:Pace_Load(0)
command -bar PaceSum	:echo join(sort(items(g:Pace_Dump(1))), "\n")
command -bar -nargs=*
	\ PaceDump	{
		const dump_args: list<string> = [<f-args>]
		const dump_length: number = len(dump_args)
		echo dump_length == 3
			? g:Pace_Dump(0)[dump_args[0]][str2nr(dump_args[1])][str2nr(dump_args[2])]
			: dump_length == 2
				? g:Pace_Dump(0)[dump_args[0]][str2nr(dump_args[1])]
				: dump_length == 1
					? g:Pace_Dump(0)[dump_args[0]]
					: g:Pace_Dump(0)
	}
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

# vim:fdm=syntax:sw=8:ts=8:noet:nolist:nosta:
