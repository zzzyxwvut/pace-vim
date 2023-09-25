""""""""""""""""""""""""""""""""""|enter.vim|"""""""""""""""""""""""""""""""""
" Also see {load,swap,test}.vim.
def s:Test_()
pace.dump = {'0': [[0, 0, 0, 0]]}
const enter_mode: string = mockup.mode
Assert_Not_Equal(1, 'i', mockup.mode)
const enter_1: number = Pace_Load(1)
Assert_True(1, !exists('#pace#CursorMovedI#*'))
Assert_True(2, !exists('#pace#InsertLeave#*'))
insertmode = 'i'
unlet! g:pace_policy
g:pace_policy = 10007

try
	mockup.mode = 'i'
	Assert_True(3, exists('#pace'))
	Assert_True(4, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	Assert_True(5, exists('#pace#InsertChange#*'))
	doautocmd pace InsertChange
	Assert_True(6, exists('#pace#InsertChange#*'))
finally
	mockup.mode = enter_mode
endtry

try
	mockup.mode = 'i'
	insertmode = 'i'		# 0x1
	Assert_True(7, exists('#pace'))
	unlet! g:pace_policy

	for enter_policy in [10001, 10003, 10005, 10007]
		g:pace_policy = enter_policy
		Assert_True(8, exists('#pace#InsertEnter#*'))
		doautocmd pace InsertEnter
		Assert_True(9, exists('#pace#CursorMovedI#*'))
	endfor

	for enter_policy in [10000, 10002, 10004, 10006]
		g:pace_policy = enter_policy
		Assert_True(10, exists('#pace#InsertEnter#*'))
		doautocmd pace InsertEnter
		Assert_True(11, !exists('#pace#CursorMovedI#*'))
	endfor

	insertmode = 'r'		# 0x2

	for enter_policy in [10002, 10003, 10006, 10007]
		g:pace_policy = enter_policy
		Assert_True(12, exists('#pace#InsertEnter#*'))
		doautocmd pace InsertEnter
		Assert_True(13, exists('#pace#CursorMovedI#*'))
	endfor

	for enter_policy in [10000, 10001, 10004, 10005]
		g:pace_policy = enter_policy
		Assert_True(14, exists('#pace#InsertEnter#*'))
		doautocmd pace InsertEnter
		Assert_True(15, !exists('#pace#CursorMovedI#*'))
	endfor

	insertmode = 'v'		# 0x4

	for enter_policy in [10004, 10005, 10006, 10007]
		g:pace_policy = enter_policy
		Assert_True(16, exists('#pace#InsertEnter#*'))
		doautocmd pace InsertEnter
		Assert_True(17, exists('#pace#CursorMovedI#*'))
	endfor

	for enter_policy in [10000, 10001, 10002, 10003]
		g:pace_policy = enter_policy
		Assert_True(18, exists('#pace#InsertEnter#*'))
		doautocmd pace InsertEnter
		Assert_True(19, !exists('#pace#CursorMovedI#*'))
	endfor
finally
	mockup.mode = enter_mode
	insertmode = 'i'
endtry

try
	mockup.mode = 'i'
	Assert_True(20, exists('#pace'))

	unlet! g:pace_policy
	g:pace_policy = 12007
	Assert_True(21, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	Assert_True(22, !has_key(pace.dump, bufnr('%')))
	Assert_Equal(1, 0, Get_Chars_Sum())
	Assert_Equal(2, 0, Get_Secs_Sum())

	Assert_True(23, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	Assert_True(24, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	Assert_True(25, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave
	Assert_True(26, exists('#pace'))
	Assert_True(27, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter

	Assert_True(28, has_key(pace.dump, bufnr('%')))
	Assert_Equal(3, pace.dump[bufnr('%')][0][2], Get_Chars_Sum())
	Assert_Equal(4, pace.dump[bufnr('%')][0][3], Get_Secs_Sum())

	unlet! g:pace_policy
	g:pace_policy = 11007
	Assert_True(29, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	Assert_Equal(5, pace.dump[0][0][2], Get_Chars_Sum())
	Assert_Equal(6, pace.dump[0][0][3], Get_Secs_Sum())

	unlet! g:pace_policy
	g:pace_policy = 10007
	Assert_True(30, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	Assert_Equal(7, 0, Get_Chars_Sum())
	Assert_Equal(8, 0, Get_Secs_Sum())
finally
	mockup.mode = enter_mode
endtry

unlet! g:pace_policy
g:pace_policy = 10007
Assert_True(31, exists('#pace'))
Assert_True(32, exists('#pace#InsertEnter#*'))
doautocmd pace InsertEnter
Assert_True(33, pace.dump[0][0][1] > pace.dump[0][0][0])
Assert_Equal(9, 0, Get_Chars())
Assert_Equal(10, 0, Get_Secs())
Assert_Equal(11, mockup.time.before, pace.epoch)
Assert_Equal(12, mockup.time.before, Get_Tick())
Assert_True(34, exists('g:pace_info'))
var enter_any: list<string>
enter_any = matchlist(g:pace_info, '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
Assert_Equal(13, '0.00', enter_any[1])	# tick
Assert_Equal(14, '0', enter_any[2])	# pace
Assert_Equal(15, '0', enter_any[3])	# chars
Assert_Equal(16, '0', enter_any[4])	# secs
Assert_True(35, (winnr('$') == 1 ? &rulerformat : &l:statusline) =~
								'g:pace_info')
Assert_True(36, exists('#pace#InsertLeave#*'))
doautocmd pace InsertLeave

try
	unlet! g:pace_sample
	Assert_True(37, pace.sample.in < pace.sample.below)

	# The inhibited updating of g:pace_info.
	pace.sample.in = pace.sample.above + 1
	Assert_True(38, !exists('#pace#CursorMovedI#*'))
	Assert_True(39, !exists('#pace#InsertLeave#*'))
	Assert_True(40, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	Assert_True(41, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	Assert_True(42, exists('g:pace_info'))
	enter_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(17, '0.00', enter_any[1])
	Assert_Equal(18, '0', enter_any[2])
	Assert_Equal(19, '0', enter_any[3])
	Assert_Equal(20, '0', enter_any[4])
	Assert_True(43, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave
	Assert_True(44, exists('g:pace_info'))
	enter_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(21, '0.00', enter_any[1])
	Assert_Equal(22, '2', enter_any[2])
	Assert_Equal(23, '2', enter_any[3])
	Assert_Equal(24, '0', enter_any[4])

	# The continuous updating of g:pace_info.
	pace.sample.in = pace.sample.below - 1
	Assert_True(45, !exists('#pace#CursorMovedI#*'))
	Assert_True(46, !exists('#pace#InsertLeave#*'))
	Assert_True(47, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	Assert_True(48, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	Assert_True(49, exists('g:pace_info'))
	enter_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(25, '0.00', enter_any[1])
	Assert_Equal(26, '2', enter_any[2])
	Assert_Equal(27, '2', enter_any[3])
	Assert_Equal(28, '0', enter_any[4])
	Assert_True(50, exists('#pace#InsertLeave#*'))
	Assert_True(51, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave

	# The sampling updating of g:pace_info.
	pace.sample.in = pace.sample.above - pace.sample.below
	Assert_True(52, !exists('#pace#CursorMovedI#*'))
	Assert_True(53, !exists('#pace#CursorHoldI#*'))
	Assert_True(54, !exists('#pace#InsertLeave#*'))
	Assert_True(55, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	Assert_True(56, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	Assert_True(57, exists('g:pace_info'))
	enter_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(29, '0.00', enter_any[1])
	Assert_Equal(30, '0', enter_any[2])
	Assert_Equal(31, '0', enter_any[3])
	Assert_Equal(32, '0', enter_any[4])
	Assert_True(58, exists('#pace#CursorHoldI#*'))
	doautocmd pace CursorHoldI
	Assert_True(59, exists('g:pace_info'))
	enter_any = matchlist(g:pace_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(33, '0.00', enter_any[1])
	Assert_Equal(34, '2', enter_any[2])
	Assert_Equal(35, '2', enter_any[3])
	Assert_Equal(36, '0', enter_any[4])
	Assert_True(60, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave
finally
	&updatetime = pace.state.updatetime
endtry

quitall
enddef

call s:Test_()
"""""""""""""""""""""""""""""""""""""|EOF|""""""""""""""""""""""""""""""""""""
