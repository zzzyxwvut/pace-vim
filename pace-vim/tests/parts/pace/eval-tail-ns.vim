""""""""""""""""""""""""""""""|eval-tail-ns.vim|""""""""""""""""""""""""""""""
let s:cpoptions = &cpoptions
set cpoptions-=C					" Join line-breaks.

let $TEST_PACE_CURSOR_OFFSET = 0
let $TEST_SECOND_PARTS = 0
let s:pace.dump = {'0': [[0, 0, 0, 0]]}
let s:eval_mode = s:mockup.mode
let s:eval_time_after = s:mockup.time.after
call s:Assert_Not_Equal(1, 'i', s:mockup.mode)

" The real reltime(a, b) result can be opaque.
call s:Assert_Equal(501, [-1, 999999999], s:Reltime([0, 0], [0, -1]))

try
	let s:eval_1 = s:Pace_Load(1)
	let s:insertmode = 'i'
	let s:mockup.mode = 'i'

	unlet! g:pace_info g:pace_policy
	let g:pace_policy = 10007
	call s:Assert_Equal(1, -1, s:Get_Chars())
	call s:Assert_Equal(2, -1, s:Get_Secs())

	call s:Assert_True(1, exists('#pace'))
	call s:Assert_True(2, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	call s:Assert_Equal(3, 0, s:Get_Chars_Sum())
	call s:Assert_Equal(4, 0, s:Get_Secs_Sum())
	call s:Assert_True(3, exists('g:pace_info'))
	let s:eval_any = matchlist(g:pace_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(5, '0.00', s:eval_any[1])	" tick
	call s:Assert_Equal(6, '0', s:eval_any[2])	" pace
	call s:Assert_Equal(7, '0', s:eval_any[3])	" chars
	call s:Assert_Equal(8, '0', s:eval_any[4])	" secs
	call s:Assert_Equal(9, 0, s:Get_Chars())

	call s:Assert_True(4, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	call s:Assert_Equal(10, s:mockup.time.before, s:Get_Tick())
	call s:Assert_Equal(11, 1, s:Get_Chars())
	call s:Assert_True(5, exists('g:pace_info'))
	let s:eval_any = matchlist(g:pace_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(12, '0.00', s:eval_any[1])
	call s:Assert_Equal(13, '1', s:eval_any[2])
	call s:Assert_Equal(14, '1', s:eval_any[3])
	call s:Assert_Equal(15, '0', s:eval_any[4])

	doautocmd pace CursorMovedI
	call s:Assert_Equal(16, 2, s:Get_Chars())
	call s:Assert_True(6, exists('g:pace_info'))
	let s:eval_any = matchlist(g:pace_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(17, '0.00', s:eval_any[1])
	call s:Assert_Equal(18, '2', s:eval_any[2])
	call s:Assert_Equal(19, '2', s:eval_any[3])
	call s:Assert_Equal(20, '0', s:eval_any[4])

	doautocmd pace CursorMovedI
	call s:Assert_Equal(21, 3, s:Get_Chars())
	call s:Assert_True(7, exists('g:pace_info'))
	let s:eval_any = matchlist(g:pace_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(22, '0.00', s:eval_any[1])
	call s:Assert_Equal(23, '3', s:eval_any[2])
	call s:Assert_Equal(24, '3', s:eval_any[3])
	call s:Assert_Equal(25, '0', s:eval_any[4])

	doautocmd pace CursorMovedI
	call s:Assert_Equal(26, s:mockup.time.before, s:Get_Tick())
	call s:Assert_Equal(27, 4, s:Get_Chars())
	call s:Assert_Equal(28, 0, s:Get_Secs())
	call s:Assert_True(8, exists('g:pace_info'))
	let s:eval_any = matchlist(g:pace_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(29, '0.00', s:eval_any[1])
	call s:Assert_Equal(30, '4', s:eval_any[2])
	call s:Assert_Equal(31, '4', s:eval_any[3])
	call s:Assert_Equal(32, '0', s:eval_any[4])

	call s:Assert_True(9, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave

	unlet! g:pace_info g:pace_policy
	let g:pace_policy = 12007
	call s:Assert_Equal(33, -1, s:Get_Chars())
	call s:Assert_Equal(34, -1, s:Get_Secs())

	call s:Assert_True(10, exists('#pace'))
	call s:Assert_True(11, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	call s:Assert_Equal(35, 4, s:Get_Chars_Sum())
	call s:Assert_Equal(36, 0, s:Get_Secs_Sum())
	call s:Assert_True(12, exists('g:pace_info'))
	let s:eval_any = matchlist(g:pace_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(37, '0.00', s:eval_any[1])	" tick
	call s:Assert_Equal(38, '4', s:eval_any[2])	" pace
	call s:Assert_Equal(39, '4', s:eval_any[3])	" chars
	call s:Assert_Equal(40, '0', s:eval_any[4])	" secs
	call s:Assert_Equal(41, 0, s:Get_Chars())

	call s:Assert_True(13, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	call s:Assert_Equal(42, s:mockup.time.before, s:Get_Tick())
	call s:Assert_Equal(43, 1, s:Get_Chars())
	call s:Assert_True(14, exists('g:pace_info'))
	let s:eval_any = matchlist(g:pace_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(44, '0.00', s:eval_any[1])
	call s:Assert_Equal(45, '5', s:eval_any[2])
	call s:Assert_Equal(46, '5', s:eval_any[3])
	call s:Assert_Equal(47, '0', s:eval_any[4])

	doautocmd pace CursorMovedI
	call s:Assert_Equal(48, 2, s:Get_Chars())
	call s:Assert_True(15, exists('g:pace_info'))
	let s:eval_any = matchlist(g:pace_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(49, '0.00', s:eval_any[1])
	call s:Assert_Equal(50, '6', s:eval_any[2])
	call s:Assert_Equal(51, '6', s:eval_any[3])
	call s:Assert_Equal(52, '0', s:eval_any[4])

	doautocmd pace CursorMovedI
	call s:Assert_Equal(53, 3, s:Get_Chars())
	call s:Assert_True(16, exists('g:pace_info'))
	let s:eval_any = matchlist(g:pace_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(54, '0.00', s:eval_any[1])
	call s:Assert_Equal(55, '7', s:eval_any[2])
	call s:Assert_Equal(56, '7', s:eval_any[3])
	call s:Assert_Equal(57, '0', s:eval_any[4])

	doautocmd pace CursorMovedI
	call s:Assert_Equal(58, s:mockup.time.before, s:Get_Tick())
	call s:Assert_Equal(59, 4, s:Get_Chars())
	call s:Assert_Equal(60, 0, s:Get_Secs())
	call s:Assert_True(17, exists('g:pace_info'))
	let s:eval_any = matchlist(g:pace_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(61, '0.00', s:eval_any[1])
	call s:Assert_Equal(62, '8', s:eval_any[2])
	call s:Assert_Equal(63, '8', s:eval_any[3])
	call s:Assert_Equal(64, '0', s:eval_any[4])

	call s:Assert_True(18, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave

	new

	unlet! g:pace_info g:pace_policy
	let g:pace_policy = 11007
	call s:Assert_Equal(65, -1, s:Get_Chars())
	call s:Assert_Equal(66, -1, s:Get_Secs())

	call s:Assert_True(19, exists('#pace'))
	call s:Assert_True(20, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	call s:Assert_Equal(67, 8, s:Get_Chars_Sum())
	call s:Assert_Equal(68, 0, s:Get_Secs_Sum())
	call s:Assert_True(21, exists('g:pace_info'))
	let s:eval_any = matchlist(g:pace_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(69, '0.00', s:eval_any[1])	" tick
	call s:Assert_Equal(70, '8', s:eval_any[2])	" pace
	call s:Assert_Equal(71, '8', s:eval_any[3])	" chars
	call s:Assert_Equal(72, '0', s:eval_any[4])	" secs
	call s:Assert_Equal(73, 0, s:Get_Chars())

	call s:Assert_True(22, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	call s:Assert_Equal(74, s:mockup.time.before, s:Get_Tick())
	call s:Assert_Equal(75, 1, s:Get_Chars())
	call s:Assert_True(23, exists('g:pace_info'))
	let s:eval_any = matchlist(g:pace_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(76, '0.00', s:eval_any[1])
	call s:Assert_Equal(77, '9', s:eval_any[2])
	call s:Assert_Equal(78, '9', s:eval_any[3])
	call s:Assert_Equal(79, '0', s:eval_any[4])

	doautocmd pace CursorMovedI
	call s:Assert_Equal(80, 2, s:Get_Chars())
	call s:Assert_True(24, exists('g:pace_info'))
	let s:eval_any = matchlist(g:pace_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(81, '0.00', s:eval_any[1])
	call s:Assert_Equal(82, '10', s:eval_any[2])
	call s:Assert_Equal(83, '10', s:eval_any[3])
	call s:Assert_Equal(84, '0', s:eval_any[4])

	doautocmd pace CursorMovedI
	call s:Assert_Equal(85, 3, s:Get_Chars())
	call s:Assert_True(25, exists('g:pace_info'))
	let s:eval_any = matchlist(g:pace_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(86, '0.00', s:eval_any[1])
	call s:Assert_Equal(87, '11', s:eval_any[2])
	call s:Assert_Equal(88, '11', s:eval_any[3])
	call s:Assert_Equal(89, '0', s:eval_any[4])

	doautocmd pace CursorMovedI
	call s:Assert_Equal(90, s:mockup.time.before, s:Get_Tick())
	call s:Assert_Equal(91, 4, s:Get_Chars())
	call s:Assert_Equal(92, 0, s:Get_Secs())
	call s:Assert_True(26, exists('g:pace_info'))
	let s:eval_any = matchlist(g:pace_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(93, '0.00', s:eval_any[1])
	call s:Assert_Equal(94, '12', s:eval_any[2])
	call s:Assert_Equal(95, '12', s:eval_any[3])
	call s:Assert_Equal(96, '0', s:eval_any[4])

	call s:Assert_True(27, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave

	call s:Assert_True(28, exists('#pace'))
	call s:Assert_True(29, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter

	call s:Assert_Equal(97, (12 * 1000000), s:pace.carry)
	call s:Assert_True(30, exists('#pace#CursorMovedI#*'))
	let s:mockup.time.after = [0, 166666667] " ≈1/6
	call s:Set_Secs(0)
""""	call s:Set_Parts(s:pace.carry)

	doautocmd pace CursorMovedI
	call s:Assert_Equal(98, 0, s:Get_Secs())
	call s:Assert_Equal(99, (166666667 + 12000000), s:Get_Parts())
	doautocmd pace CursorMovedI
	call s:Assert_Equal(100, 0, s:Get_Secs())
	call s:Assert_Equal(101, (333333334 + 12000000), s:Get_Parts())
	doautocmd pace CursorMovedI
	call s:Assert_Equal(102, 0, s:Get_Secs())
	call s:Assert_Equal(103, (500000001 + 12000000), s:Get_Parts())
	doautocmd pace CursorMovedI
	call s:Assert_Equal(104, 0, s:Get_Secs())
	call s:Assert_Equal(105, (666666668 + 12000000), s:Get_Parts())
	doautocmd pace CursorMovedI
	call s:Assert_Equal(106, 0, s:Get_Secs())
	call s:Assert_Equal(107, (833333335 + 12000000), s:Get_Parts())
	doautocmd pace CursorMovedI
	call s:Assert_Equal(108, 1, s:Get_Secs())	" (1012000002 / 1000000000)
	call s:Assert_Equal(109, 12000002, s:Get_Parts()) " (1012000002 % 1000000000)
	call s:Assert_Equal(110, s:mockup.time.before, s:Get_Tick())
	call s:Assert_Equal(111, 6, s:Get_Chars())
	call s:Assert_True(31, exists('g:pace_info'))
	let s:eval_any = matchlist(g:pace_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(112, '0.16', s:eval_any[1])
	call s:Assert_Equal(113, '18', s:eval_any[2])
	call s:Assert_Equal(114, '18', s:eval_any[3])
	call s:Assert_Equal(115, '1', s:eval_any[4])

	call s:Assert_True(32, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave
	call s:Assert_Equal(116, 12000002, s:pace.carry)
	let s:mockup.mode = 'n'
	let s:eval_2 = s:Pace_Load(0)
	call s:Assert_Equal(117, 0, s:pace.carry)
finally
	let s:mockup.mode = s:eval_mode
	let s:mockup.time.after = s:eval_time_after
endtry

let &cpoptions = s:cpoptions
unlet s:cpoptions
quitall
"""""""""""""""""""""""""""""""""""""|EOF|""""""""""""""""""""""""""""""""""""
