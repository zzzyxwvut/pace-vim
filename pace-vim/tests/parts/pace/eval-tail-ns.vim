##############################|eval-tail-ns.vim|##############################
$TEST_PACE_CURSOR_OFFSET = '0'
$TEST_SECOND_PARTS = '0'
pace.dump = {'0': [[0, 0, 0, 0]]}
const eval_mode: string = mockup.mode
const eval_time_after: list<number> = mockup.time.after
Assert_Not_Equal(1, 'i', mockup.mode)

# The real reltime(a, b) result can be opaque.
Assert_Equal(501, [-1, 999999999], Reltime([0, 0], [0, -1]))

try
	const eval_1: number = Pace_Load(1)
	insertmode = 'i'
	mockup.mode = 'i'

	unlet! g:pace_info g:pace_policy
	g:pace_policy = 10007
	Assert_Equal(1, -1, Get_Chars())
	Assert_Equal(2, -1, Get_Secs())

	Assert_True(1, exists('#pace'))
	Assert_True(2, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	Assert_Equal(3, 0, Get_Chars_Sum())
	Assert_Equal(4, 0, Get_Secs_Sum())
	Assert_True(3, exists('g:pace_info'))
	var eval_any: list<string>
	eval_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(5, '0.00', eval_any[1])	# tick
	Assert_Equal(6, '0', eval_any[2])	# pace
	Assert_Equal(7, '0', eval_any[3])	# chars
	Assert_Equal(8, '0', eval_any[4])	# secs
	Assert_Equal(9, 0, Get_Chars())

	Assert_True(4, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	Assert_Equal(10, mockup.time.before, Get_Tick())
	Assert_Equal(11, 1, Get_Chars())
	Assert_True(5, exists('g:pace_info'))
	eval_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(12, '0.00', eval_any[1])
	Assert_Equal(13, '1', eval_any[2])
	Assert_Equal(14, '1', eval_any[3])
	Assert_Equal(15, '0', eval_any[4])

	doautocmd pace CursorMovedI
	Assert_Equal(16, 2, Get_Chars())
	Assert_True(6, exists('g:pace_info'))
	eval_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(17, '0.00', eval_any[1])
	Assert_Equal(18, '2', eval_any[2])
	Assert_Equal(19, '2', eval_any[3])
	Assert_Equal(20, '0', eval_any[4])

	doautocmd pace CursorMovedI
	Assert_Equal(21, 3, Get_Chars())
	Assert_True(7, exists('g:pace_info'))
	eval_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(22, '0.00', eval_any[1])
	Assert_Equal(23, '3', eval_any[2])
	Assert_Equal(24, '3', eval_any[3])
	Assert_Equal(25, '0', eval_any[4])

	doautocmd pace CursorMovedI
	Assert_Equal(26, mockup.time.before, Get_Tick())
	Assert_Equal(27, 4, Get_Chars())
	Assert_Equal(28, 0, Get_Secs())
	Assert_True(8, exists('g:pace_info'))
	eval_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(29, '0.00', eval_any[1])
	Assert_Equal(30, '4', eval_any[2])
	Assert_Equal(31, '4', eval_any[3])
	Assert_Equal(32, '0', eval_any[4])

	Assert_True(9, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave

	unlet! g:pace_info g:pace_policy
	g:pace_policy = 12007
	Assert_Equal(33, -1, Get_Chars())
	Assert_Equal(34, -1, Get_Secs())

	Assert_True(10, exists('#pace'))
	Assert_True(11, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	Assert_Equal(35, 4, Get_Chars_Sum())
	Assert_Equal(36, 0, Get_Secs_Sum())
	Assert_True(12, exists('g:pace_info'))
	eval_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(37, '0.00', eval_any[1])	# tick
	Assert_Equal(38, '4', eval_any[2])	# pace
	Assert_Equal(39, '4', eval_any[3])	# chars
	Assert_Equal(40, '0', eval_any[4])	# secs
	Assert_Equal(41, 0, Get_Chars())

	Assert_True(13, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	Assert_Equal(42, mockup.time.before, Get_Tick())
	Assert_Equal(43, 1, Get_Chars())
	Assert_True(14, exists('g:pace_info'))
	eval_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(44, '0.00', eval_any[1])
	Assert_Equal(45, '5', eval_any[2])
	Assert_Equal(46, '5', eval_any[3])
	Assert_Equal(47, '0', eval_any[4])

	doautocmd pace CursorMovedI
	Assert_Equal(48, 2, Get_Chars())
	Assert_True(15, exists('g:pace_info'))
	eval_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(49, '0.00', eval_any[1])
	Assert_Equal(50, '6', eval_any[2])
	Assert_Equal(51, '6', eval_any[3])
	Assert_Equal(52, '0', eval_any[4])

	doautocmd pace CursorMovedI
	Assert_Equal(53, 3, Get_Chars())
	Assert_True(16, exists('g:pace_info'))
	eval_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(54, '0.00', eval_any[1])
	Assert_Equal(55, '7', eval_any[2])
	Assert_Equal(56, '7', eval_any[3])
	Assert_Equal(57, '0', eval_any[4])

	doautocmd pace CursorMovedI
	Assert_Equal(58, mockup.time.before, Get_Tick())
	Assert_Equal(59, 4, Get_Chars())
	Assert_Equal(60, 0, Get_Secs())
	Assert_True(17, exists('g:pace_info'))
	eval_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(61, '0.00', eval_any[1])
	Assert_Equal(62, '8', eval_any[2])
	Assert_Equal(63, '8', eval_any[3])
	Assert_Equal(64, '0', eval_any[4])

	Assert_True(18, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave

	new

	unlet! g:pace_info g:pace_policy
	g:pace_policy = 11007
	Assert_Equal(65, -1, Get_Chars())
	Assert_Equal(66, -1, Get_Secs())

	Assert_True(19, exists('#pace'))
	Assert_True(20, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	Assert_Equal(67, 8, Get_Chars_Sum())
	Assert_Equal(68, 0, Get_Secs_Sum())
	Assert_True(21, exists('g:pace_info'))
	eval_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(69, '0.00', eval_any[1])	# tick
	Assert_Equal(70, '8', eval_any[2])	# pace
	Assert_Equal(71, '8', eval_any[3])	# chars
	Assert_Equal(72, '0', eval_any[4])	# secs
	Assert_Equal(73, 0, Get_Chars())

	Assert_True(22, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	Assert_Equal(74, mockup.time.before, Get_Tick())
	Assert_Equal(75, 1, Get_Chars())
	Assert_True(23, exists('g:pace_info'))
	eval_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(76, '0.00', eval_any[1])
	Assert_Equal(77, '9', eval_any[2])
	Assert_Equal(78, '9', eval_any[3])
	Assert_Equal(79, '0', eval_any[4])

	doautocmd pace CursorMovedI
	Assert_Equal(80, 2, Get_Chars())
	Assert_True(24, exists('g:pace_info'))
	eval_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(81, '0.00', eval_any[1])
	Assert_Equal(82, '10', eval_any[2])
	Assert_Equal(83, '10', eval_any[3])
	Assert_Equal(84, '0', eval_any[4])

	doautocmd pace CursorMovedI
	Assert_Equal(85, 3, Get_Chars())
	Assert_True(25, exists('g:pace_info'))
	eval_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(86, '0.00', eval_any[1])
	Assert_Equal(87, '11', eval_any[2])
	Assert_Equal(88, '11', eval_any[3])
	Assert_Equal(89, '0', eval_any[4])

	doautocmd pace CursorMovedI
	Assert_Equal(90, mockup.time.before, Get_Tick())
	Assert_Equal(91, 4, Get_Chars())
	Assert_Equal(92, 0, Get_Secs())
	Assert_True(26, exists('g:pace_info'))
	eval_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(93, '0.00', eval_any[1])
	Assert_Equal(94, '12', eval_any[2])
	Assert_Equal(95, '12', eval_any[3])
	Assert_Equal(96, '0', eval_any[4])

	Assert_True(27, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave

	Assert_True(28, exists('#pace'))
	Assert_True(29, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter

	Assert_Equal(97, (12 * 1000000), pace.carry)
	Assert_True(30, exists('#pace#CursorMovedI#*'))
	mockup.time.after = [0, 166666667] # ≈1/6
	Set_Secs(0)
####	Set_Parts(pace.carry)

	doautocmd pace CursorMovedI
	Assert_Equal(98, 0, Get_Secs())
	Assert_Equal(99, (166666667 + 12000000), Get_Parts())
	doautocmd pace CursorMovedI
	Assert_Equal(100, 0, Get_Secs())
	Assert_Equal(101, (333333334 + 12000000), Get_Parts())
	doautocmd pace CursorMovedI
	Assert_Equal(102, 0, Get_Secs())
	Assert_Equal(103, (500000001 + 12000000), Get_Parts())
	doautocmd pace CursorMovedI
	Assert_Equal(104, 0, Get_Secs())
	Assert_Equal(105, (666666668 + 12000000), Get_Parts())
	doautocmd pace CursorMovedI
	Assert_Equal(106, 0, Get_Secs())
	Assert_Equal(107, (833333335 + 12000000), Get_Parts())
	doautocmd pace CursorMovedI
	Assert_Equal(108, 1, Get_Secs())	# (1012000002 / 1000000000)
	Assert_Equal(109, 12000002, Get_Parts()) # (1012000002 % 1000000000)
	Assert_Equal(110, mockup.time.before, Get_Tick())
	Assert_Equal(111, 6, Get_Chars())
	Assert_True(31, exists('g:pace_info'))
	eval_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(112, '0.16', eval_any[1])
	Assert_Equal(113, '18', eval_any[2])
	Assert_Equal(114, '18', eval_any[3])
	Assert_Equal(115, '1', eval_any[4])
	doautocmd pace CursorMovedI
	Assert_Equal(116, mockup.time.before, Get_Tick())
	Assert_Equal(117, 7, Get_Chars())
	Assert_Equal(118, 1, Get_Secs())
	Assert_True(32, exists('g:pace_info'))
	eval_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(119, '0.16', eval_any[1])
	Assert_Equal(120, '19', eval_any[2])
	Assert_Equal(121, '19', eval_any[3])
	Assert_Equal(122, '1', eval_any[4])

	Assert_True(33, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave
	Assert_Equal(123, (166666667 + 12000002), pace.carry)
	mockup.mode = 'n'
	const eval_2: number = Pace_Load(0)
	Assert_Equal(124, 0, pace.carry)

	const eval_3: number = Pace_Load(1)
	mockup.mode = 'i'
	unlet! g:pace_info g:pace_policy g:pace_sample
	g:pace_policy = 10007
	Assert_Equal(125, -1, Get_Chars())
	Assert_Equal(126, -1, Get_Secs())
	Assert_True(34, pace.sample_in < Pace.sample_below)

	try
		g:pace_sample = Pace.sample_above - Pace.sample_below
		Assert_True(35, exists('#pace'))
		Assert_True(36, exists('#pace#InsertEnter#*'))
		doautocmd pace InsertEnter
		Assert_Equal(127, &updatetime, pace.sample_in)
		Assert_True(37, exists('g:pace_info'))
		eval_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
		Assert_Equal(128, '0.00', eval_any[1])
		Assert_Equal(129, '0', eval_any[2])
		Assert_Equal(130, '0', eval_any[3])
		Assert_Equal(131, '0', eval_any[4])

		Assert_Equal(132, 0, pace.carry)
		Assert_True(38, exists('#pace#CursorMovedI#*'))
		mockup.time.after = [0, 166666667] # ≈1/6
		Set_Secs(0)

		doautocmd pace CursorMovedI
		Assert_Equal(133, 0, Get_Secs())
		Assert_Equal(134, 166666667, Get_Parts())
		doautocmd pace CursorMovedI
		Assert_Equal(135, 0, Get_Secs())
		Assert_Equal(136, 333333334, Get_Parts())
		doautocmd pace CursorMovedI
		Assert_Equal(137, 0, Get_Secs())
		Assert_Equal(138, 500000001, Get_Parts())
		doautocmd pace CursorMovedI
		Assert_Equal(139, 0, Get_Secs())
		Assert_Equal(140, 666666668, Get_Parts())
		doautocmd pace CursorMovedI
		Assert_Equal(141, 0, Get_Secs())
		Assert_Equal(142, 833333335, Get_Parts())
		doautocmd pace CursorMovedI
		Assert_Equal(143, 1, Get_Secs())
		Assert_Equal(144, 2, Get_Parts())
		Assert_Equal(145, mockup.time.before, Get_Tick())
		Assert_Equal(146, 6, Get_Chars())
		Assert_True(39, exists('g:pace_info'))
		eval_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
		Assert_Equal(147, '0.00', eval_any[1])
		Assert_Equal(148, '0', eval_any[2])
		Assert_Equal(149, '0', eval_any[3])
		Assert_Equal(150, '0', eval_any[4])
		Assert_True(40, exists('#pace#CursorHoldI#*'))
		doautocmd pace CursorHoldI
		Assert_True(41, exists('g:pace_info'))
		eval_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
		Assert_Equal(151, '0.00', eval_any[1])
		Assert_Equal(152, '6', eval_any[2])
		Assert_Equal(153, '6', eval_any[3])
		Assert_Equal(154, '1', eval_any[4])

		Assert_True(42, exists('#pace#CursorMovedI#*'))
		doautocmd pace CursorMovedI
		Assert_True(43, exists('#pace#CursorHoldI#*'))
		doautocmd pace CursorHoldI
		Assert_Equal(155, mockup.time.before, Get_Tick())
		Assert_Equal(156, 7, Get_Chars())
		Assert_Equal(157, 1, Get_Secs())
		Assert_True(44, exists('g:pace_info'))
		eval_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
		Assert_Equal(158, '0.00', eval_any[1])
		Assert_Equal(159, '7', eval_any[2])
		Assert_Equal(160, '7', eval_any[3])
		Assert_Equal(161, '1', eval_any[4])

		Assert_True(45, exists('#pace#InsertLeave#*'))
		doautocmd pace InsertLeave
		Assert_Equal(162, (166666667 + 2), pace.carry)
		mockup.mode = 'n'
		const eval_4: number = Pace_Load(0)
		Assert_Equal(163, 0, pace.carry)
	finally
		&updatetime = pace.state.updatetime
	endtry
finally
	mockup.mode = eval_mode
	mockup.time.after = eval_time_after
endtry

quitall
#####################################|EOF|####################################
