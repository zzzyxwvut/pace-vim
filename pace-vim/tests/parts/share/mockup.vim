##############################|share/mockup.vim|##############################
class ElapsedTime
	public var after: list<number> = [0, 1]
	public var between: list<number> = [0, 1]
	public var before: list<number> = [0, 0]
	public var over: list<number> = [-1, -1]

	def new()
	enddef
endclass

class Mockup
	public var mode: string = 'n'

	const parts: number = !empty($TEST_SECOND_PARTS)
		? str2nr($TEST_SECOND_PARTS)
		: 0
	const time: ElapsedTime = ElapsedTime.new()

	def new()
	enddef
endclass

var insertmode: string = 'i'
var mockup: Mockup = Mockup.new()

if mockup.parts == 9				# nsec
	mockup.time.after = [0, 1000000]	# 1/1000
	mockup.time.between = [0, 1000000]	# 1/1000
	mockup.time.over = [-1, 999999999]
elseif mockup.parts == 6			# usec
	mockup.time.after = [0, 1000]		# 1/1000
	mockup.time.between = [0, 1000]		# 1/1000
	mockup.time.over = [-1, 999999]
endif

def Mode(): string
	return mockup.mode
enddef

# Track f_reltime of time.c and profile_* of profiler.c.
#
# Mock the following function signatures:
#	reltime()
#	reltime(start)
#	reltime(start, end)
def Reltime(...items: list<list<number>>): list<number>
	const kind: number = empty(items)
		? 0
		: len(items) == 1 && len(items[0]) == 2
			? 1
			: len(items) == 2 &&
					len(items[0]) == 2 &&
					len(items[1]) == 2
				? 2
				: -1

	if kind < 0
		throw 'Illegal argument'
	endif

	# Also handle reltime([0, 0], [0, -1]).
	return kind == 2
		? items[1][1] == -1 &&
					items[1][0] == 0 &&
					items[0][1] == 0 &&
					items[0][0] == 0
			? mockup.time.over
			: mockup.time.between
		: kind == 1
			? mockup.time.after
			: mockup.time.before
enddef

# Track f_reltimestr of time.c and profile_msg of profiler.c.
#
# Beware that the time format is assumed as if it were timespec or timeval.
def ReltimeStr(time: list<number>): string
	if len(time) != 2
		throw 'Illegal argument'
	endif

	var scale: number = len(string(time[1]))
	var micros: number = time[1]

	while scale > 6
		micros /= 1000
		scale -= 3
	endwhile

	# Don't bother with Win32's '%10.6f' for mocked-up time.
	return printf('%3d.%06d', time[0], micros)
enddef

defcompile
#####################################|EOF|####################################
