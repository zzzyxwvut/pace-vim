""""""""""""""""""""""""""""""|eval-tail-ns.vim|""""""""""""""""""""""""""""""
let s:cpoptions = &cpoptions
set cpoptions-=C					" Join line-breaks.

let $TEST_DEMO_CURSOR_OFFSET = 0
let $TEST_SECOND_PARTS = 0
let s:eval_mode = s:mockup.mode
let s:eval_time_after = s:mockup.time.after
call s:Assert_Not_Equal(1, 'i', s:mockup.mode)

" The real reltime(a, b) result can be opaque.
call s:Assert_Equal(501, [-1, 999999999], s:Reltime([0, 0], [0, -1]))

try
	let s:insertmode = 'i'
	let s:mockup.mode = 'i'
	call s:Assert_Equal(1, 0, s:Get_Chars())
	call s:Assert_Equal(2, 0, s:Get_Secs())
	call s:Assert_True(1, exists('g:demo_info'))
	let s:eval_any = matchlist(g:demo_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(3, '0.00', s:eval_any[1])	" tick
	call s:Assert_Equal(4, '0', s:eval_any[2])	" pace
	call s:Assert_Equal(5, '0', s:eval_any[3])	" chars
	call s:Assert_Equal(6, '0', s:eval_any[4])	" secs

	call s:demo.eval(s:turn)
	call s:Assert_Equal(7, s:mockup.time.before, s:Get_Tick())
	call s:Assert_Equal(8, 1, s:Get_Chars())
	call s:Assert_True(2, exists('g:demo_info'))
	let s:eval_any = matchlist(g:demo_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(9, '0.00', s:eval_any[1])
	call s:Assert_Equal(10, '1', s:eval_any[2])
	call s:Assert_Equal(11, '1', s:eval_any[3])
	call s:Assert_Equal(12, '0', s:eval_any[4])

	call s:demo.eval(s:turn)
	call s:Assert_Equal(13, 2, s:Get_Chars())
	call s:Assert_True(3, exists('g:demo_info'))
	let s:eval_any = matchlist(g:demo_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(14, '0.00', s:eval_any[1])
	call s:Assert_Equal(15, '2', s:eval_any[2])
	call s:Assert_Equal(16, '2', s:eval_any[3])
	call s:Assert_Equal(17, '0', s:eval_any[4])

	call s:demo.eval(s:turn)
	call s:Assert_Equal(18, 3, s:Get_Chars())
	call s:Assert_True(4, exists('g:demo_info'))
	let s:eval_any = matchlist(g:demo_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(19, '0.00', s:eval_any[1])
	call s:Assert_Equal(20, '3', s:eval_any[2])
	call s:Assert_Equal(21, '3', s:eval_any[3])
	call s:Assert_Equal(22, '0', s:eval_any[4])

	call s:demo.eval(s:turn)
	call s:Assert_Equal(23, s:mockup.time.before, s:Get_Tick())
	call s:Assert_Equal(24, 4, s:Get_Chars())
	call s:Assert_Equal(25, 0, s:Get_Secs())
	call s:Assert_True(5, exists('g:demo_info'))
	let s:eval_any = matchlist(g:demo_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(26, '0.00', s:eval_any[1])
	call s:Assert_Equal(27, '4', s:eval_any[2])
	call s:Assert_Equal(28, '4', s:eval_any[3])
	call s:Assert_Equal(29, '0', s:eval_any[4])

	let s:mockup.time.after = [0, 166666667]	" ≈1/6
	call s:Set_Secs(0)
	call s:Assert_Equal(30, (4 * 1000000), s:Get_Parts())

	call s:demo.eval(s:turn)
	call s:Assert_Equal(31, 0, s:Get_Secs())
	call s:Assert_Equal(32, (166666667 + 4000000), s:Get_Parts())
	call s:demo.eval(s:turn)
	call s:Assert_Equal(33, 0, s:Get_Secs())
	call s:Assert_Equal(34, (333333334 + 4000000), s:Get_Parts())
	call s:demo.eval(s:turn)
	call s:Assert_Equal(35, 0, s:Get_Secs())
	call s:Assert_Equal(36, (500000001 + 4000000), s:Get_Parts())
	call s:demo.eval(s:turn)
	call s:Assert_Equal(37, 0, s:Get_Secs())
	call s:Assert_Equal(38, (666666668 + 4000000), s:Get_Parts())
	call s:demo.eval(s:turn)
	call s:Assert_Equal(39, 0, s:Get_Secs())
	call s:Assert_Equal(40, (833333335 + 4000000), s:Get_Parts())
	call s:demo.eval(s:turn)
	call s:Assert_Equal(41, 1, s:Get_Secs())	" (1004000002 / 1000000000)
	call s:Assert_Equal(42, 4000002, s:Get_Parts()) " (1004000002 % 1000000000)
	call s:Assert_Equal(43, s:mockup.time.before, s:Get_Tick())
	call s:Assert_Equal(44, (4 + 6), s:Get_Chars())
	call s:Assert_True(6, exists('g:demo_info'))
	let s:eval_any = matchlist(g:demo_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(45, '0.16', s:eval_any[1])
	call s:Assert_Equal(46, '10', s:eval_any[2])
	call s:Assert_Equal(47, '10', s:eval_any[3])
	call s:Assert_Equal(48, '1', s:eval_any[4])
finally
	let s:mockup.mode = s:eval_mode
	let s:mockup.time.after = s:eval_time_after
endtry

let &cpoptions = s:cpoptions
unlet s:cpoptions
quit
"""""""""""""""""""""""""""""""""""""|EOF|""""""""""""""""""""""""""""""""""""
