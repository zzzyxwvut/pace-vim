##############################|eval-tail-ns.vim|##############################
$TEST_DEMO_CURSOR_OFFSET = '0'
$TEST_SECOND_PARTS = '0'
const eval_time_after: list<number> = mockup.time.after
const eval_mode: string = mockup.mode
var eval_any: list<string>
Assert_Not_Equal(1, 'i', mockup.mode)

# The real reltime(a, b) result can be opaque.
Assert_Equal(501, [-1, 999999999], Reltime([0, 0], [0, -1]))

try
	insertmode = 'i'
	mockup.mode = 'i'
	Assert_Equal(1, 0, Get_Chars())
	Assert_Equal(2, 0, Get_Secs())
	Assert_True(1, exists('g:demo_info'))
	eval_any = matchlist(g:demo_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(3, '0.00', eval_any[1])	# tick
	Assert_Equal(4, '0', eval_any[2])	# pace
	Assert_Equal(5, '0', eval_any[3])	# chars
	Assert_Equal(6, '0', eval_any[4])	# secs

	Eval0(turn)
	Assert_Equal(7, mockup.time.before, Get_Tick())
	Assert_Equal(8, 1, Get_Chars())
	Assert_True(2, exists('g:demo_info'))
	eval_any = matchlist(g:demo_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(9, '0.00', eval_any[1])
	Assert_Equal(10, '1', eval_any[2])
	Assert_Equal(11, '1', eval_any[3])
	Assert_Equal(12, '0', eval_any[4])

	Eval0(turn)
	Assert_Equal(13, 2, Get_Chars())
	Assert_True(3, exists('g:demo_info'))
	eval_any = matchlist(g:demo_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(14, '0.00', eval_any[1])
	Assert_Equal(15, '2', eval_any[2])
	Assert_Equal(16, '2', eval_any[3])
	Assert_Equal(17, '0', eval_any[4])

	Eval0(turn)
	Assert_Equal(18, 3, Get_Chars())
	Assert_True(4, exists('g:demo_info'))
	eval_any = matchlist(g:demo_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(19, '0.00', eval_any[1])
	Assert_Equal(20, '3', eval_any[2])
	Assert_Equal(21, '3', eval_any[3])
	Assert_Equal(22, '0', eval_any[4])

	Eval0(turn)
	Assert_Equal(23, mockup.time.before, Get_Tick())
	Assert_Equal(24, 4, Get_Chars())
	Assert_Equal(25, 0, Get_Secs())
	Assert_True(5, exists('g:demo_info'))
	eval_any = matchlist(g:demo_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(26, '0.00', eval_any[1])
	Assert_Equal(27, '4', eval_any[2])
	Assert_Equal(28, '4', eval_any[3])
	Assert_Equal(29, '0', eval_any[4])

	mockup.time.after = [0, 166666667]	# ≈1/6
	Set_Secs(0)
	Assert_Equal(30, (4 * 1000000), Get_Parts())

	Eval0(turn)
	Assert_Equal(31, 0, Get_Secs())
	Assert_Equal(32, (166666667 + 4000000), Get_Parts())
	Eval0(turn)
	Assert_Equal(33, 0, Get_Secs())
	Assert_Equal(34, (333333334 + 4000000), Get_Parts())
	Eval0(turn)
	Assert_Equal(35, 0, Get_Secs())
	Assert_Equal(36, (500000001 + 4000000), Get_Parts())
	Eval0(turn)
	Assert_Equal(37, 0, Get_Secs())
	Assert_Equal(38, (666666668 + 4000000), Get_Parts())
	Eval0(turn)
	Assert_Equal(39, 0, Get_Secs())
	Assert_Equal(40, (833333335 + 4000000), Get_Parts())
	Eval0(turn)
	Assert_Equal(41, 1, Get_Secs())		# (1004000002 / 1000000000)
	Assert_Equal(42, 4000002, Get_Parts())	# (1004000002 % 1000000000)
	Assert_Equal(43, mockup.time.before, Get_Tick())
	Assert_Equal(44, (4 + 6), Get_Chars())
	Eval1(turn)
	Assert_Equal(45, mockup.time.before, Get_Tick())
	Assert_Equal(46, 11, Get_Chars())
	Assert_Equal(47, 1, Get_Secs())
	Assert_True(6, exists('g:demo_info'))
	eval_any = matchlist(g:demo_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(48, '0.16', eval_any[1])
	Assert_Equal(49, '11', eval_any[2])
	Assert_Equal(50, '11', eval_any[3])
	Assert_Equal(51, '1', eval_any[4])
finally
	mockup.mode = eval_mode
	mockup.time.after = eval_time_after
endtry

quit
#####################################|EOF|####################################
