""""""""""""""""""""""""""""""""""|enter.vim|"""""""""""""""""""""""""""""""""
" Also see {load,swap,test}.vim.

let s:cpoptions = &cpoptions
set cpoptions-=C					" Join line-breaks.

let s:pace.dump = {'0': [[0, 0, 0, 0]]}
let s:enter_mode = s:mockup.mode
call s:Assert_Not_Equal(1, 'i', s:mockup.mode)
let s:enter_1 = s:Pace_Load(1)
call s:Assert_True(1, !exists('#pace#CursorMovedI#*'))
call s:Assert_True(2, !exists('#pace#InsertLeave#*'))
let s:insertmode = 'i'
unlet! g:pace_policy
let g:pace_policy = 10007

try
	let s:mockup.mode = 'i'
	call s:Assert_True(3, exists('#pace'))
	call s:Assert_True(4, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	call s:Assert_True(5, exists('#pace#InsertChange#*'))
	doautocmd pace InsertChange
	call s:Assert_True(6, exists('#pace#InsertChange#*'))
finally
	let s:mockup.mode = s:enter_mode
endtry

try
	let s:mockup.mode = 'i'
	let s:insertmode = 'i'		" 0x1
	call s:Assert_True(7, exists('#pace'))
	unlet! g:pace_policy

	for s:enter_policy in [10001, 10003, 10005, 10007]
		let g:pace_policy = s:enter_policy
		call s:Assert_True(8, exists('#pace#InsertEnter#*'))
		doautocmd pace InsertEnter
		call s:Assert_True(9, exists('#pace#CursorMovedI#*'))
	endfor

	for s:enter_policy in [10000, 10002, 10004, 10006]
		let g:pace_policy = s:enter_policy
		call s:Assert_True(10, exists('#pace#InsertEnter#*'))
		doautocmd pace InsertEnter
		call s:Assert_True(11, !exists('#pace#CursorMovedI#*'))
	endfor

	let s:insertmode = 'r'		" 0x2

	for s:enter_policy in [10002, 10003, 10006, 10007]
		let g:pace_policy = s:enter_policy
		call s:Assert_True(12, exists('#pace#InsertEnter#*'))
		doautocmd pace InsertEnter
		call s:Assert_True(13, exists('#pace#CursorMovedI#*'))
	endfor

	for s:enter_policy in [10000, 10001, 10004, 10005]
		let g:pace_policy = s:enter_policy
		call s:Assert_True(14, exists('#pace#InsertEnter#*'))
		doautocmd pace InsertEnter
		call s:Assert_True(15, !exists('#pace#CursorMovedI#*'))
	endfor

	let s:insertmode = 'v'		" 0x4

	for s:enter_policy in [10004, 10005, 10006, 10007]
		let g:pace_policy = s:enter_policy
		call s:Assert_True(16, exists('#pace#InsertEnter#*'))
		doautocmd pace InsertEnter
		call s:Assert_True(17, exists('#pace#CursorMovedI#*'))
	endfor

	for s:enter_policy in [10000, 10001, 10002, 10003]
		let g:pace_policy = s:enter_policy
		call s:Assert_True(18, exists('#pace#InsertEnter#*'))
		doautocmd pace InsertEnter
		call s:Assert_True(19, !exists('#pace#CursorMovedI#*'))
	endfor
finally
	let s:mockup.mode = s:enter_mode
	let s:insertmode = 'i'
endtry

try
	let s:mockup.mode = 'i'
	call s:Assert_True(20, exists('#pace'))

	unlet! g:pace_policy
	let g:pace_policy = 12007
	call s:Assert_True(21, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	call s:Assert_True(22, !has_key(s:pace.dump, bufnr('%')))
	call s:Assert_Equal(1, 0, s:Get_Chars_Sum())
	call s:Assert_Equal(2, 0, s:Get_Secs_Sum())

	call s:Assert_True(23, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	call s:Assert_True(24, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	call s:Assert_True(25, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave
	call s:Assert_True(26, exists('#pace'))
	call s:Assert_True(27, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter

	call s:Assert_True(28, has_key(s:pace.dump, bufnr('%')))
	call s:Assert_Equal(3, s:pace.dump[bufnr('%')][0][2], s:Get_Chars_Sum())
	call s:Assert_Equal(4, s:pace.dump[bufnr('%')][0][3], s:Get_Secs_Sum())

	unlet! g:pace_policy
	let g:pace_policy = 11007
	call s:Assert_True(29, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	call s:Assert_Equal(5, s:pace.dump[0][0][2], s:Get_Chars_Sum())
	call s:Assert_Equal(6, s:pace.dump[0][0][3], s:Get_Secs_Sum())

	unlet! g:pace_policy
	let g:pace_policy = 10007
	call s:Assert_True(30, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	call s:Assert_Equal(7, 0, s:Get_Chars_Sum())
	call s:Assert_Equal(8, 0, s:Get_Secs_Sum())
finally
	let s:mockup.mode = s:enter_mode
endtry

unlet! g:pace_policy
let g:pace_policy = 10007
call s:Assert_True(31, exists('#pace'))
call s:Assert_True(32, exists('#pace#InsertEnter#*'))
doautocmd pace InsertEnter
call s:Assert_True(33, s:pace.dump[0][0][1] > s:pace.dump[0][0][0])
call s:Assert_Equal(9, 0, s:Get_Chars())
call s:Assert_Equal(10, 0, s:Get_Secs())
call s:Assert_Equal(11, s:mockup.time.before, s:pace.epoch)
call s:Assert_Equal(12, s:mockup.time.before, s:Get_Tick())
call s:Assert_True(34, exists('g:pace_info'))
let s:enter_any = matchlist(g:pace_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
call s:Assert_Equal(13, '0.00', s:enter_any[1])	" tick
call s:Assert_Equal(14, '0', s:enter_any[2])	" pace
call s:Assert_Equal(15, '0', s:enter_any[3])	" chars
call s:Assert_Equal(16, '0', s:enter_any[4])	" secs
call s:Assert_True(35, (winnr('$') == 1 ? &rulerformat : &l:statusline) =~
							\ 'g:pace_info')
call s:Assert_True(36, exists('#pace#InsertLeave#*'))
doautocmd pace InsertLeave

try
	unlet! g:pace_sample
	call s:Assert_True(37, s:pace.sample.in < s:pace.sample.below)

	" The inhibited updating of g:pace_info.
	let s:pace.sample.in = s:pace.sample.above + 1
	call s:Assert_True(38, !exists('#pace#CursorMovedI#*'))
	call s:Assert_True(39, !exists('#pace#InsertLeave#*'))
	call s:Assert_True(40, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	call s:Assert_True(41, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	call s:Assert_True(42, exists('g:pace_info'))
	let s:enter_any = matchlist(g:pace_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(17, '0.00', s:enter_any[1])
	call s:Assert_Equal(18, '0', s:enter_any[2])
	call s:Assert_Equal(19, '0', s:enter_any[3])
	call s:Assert_Equal(20, '0', s:enter_any[4])
	call s:Assert_True(43, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave
	call s:Assert_True(44, exists('g:pace_info'))
	let s:enter_any = matchlist(g:pace_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(21, '0.00', s:enter_any[1])
	call s:Assert_Equal(22, '2', s:enter_any[2])
	call s:Assert_Equal(23, '2', s:enter_any[3])
	call s:Assert_Equal(24, '0', s:enter_any[4])

	" The continuous updating of g:pace_info.
	let s:pace.sample.in = s:pace.sample.below - 1
	call s:Assert_True(45, !exists('#pace#CursorMovedI#*'))
	call s:Assert_True(46, !exists('#pace#InsertLeave#*'))
	call s:Assert_True(47, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	call s:Assert_True(48, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	call s:Assert_True(49, exists('g:pace_info'))
	let s:enter_any = matchlist(g:pace_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(25, '0.00', s:enter_any[1])
	call s:Assert_Equal(26, '2', s:enter_any[2])
	call s:Assert_Equal(27, '2', s:enter_any[3])
	call s:Assert_Equal(28, '0', s:enter_any[4])
	call s:Assert_True(50, exists('#pace#InsertLeave#*'))
	call s:Assert_True(51, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave

	" The sampling updating of g:pace_info.
	let s:pace.sample.in = s:pace.sample.above - s:pace.sample.below
	call s:Assert_True(52, !exists('#pace#CursorMovedI#*'))
	call s:Assert_True(53, !exists('#pace#CursorHoldI#*'))
	call s:Assert_True(54, !exists('#pace#InsertLeave#*'))
	call s:Assert_True(55, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	call s:Assert_True(56, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	call s:Assert_True(57, exists('g:pace_info'))
	let s:enter_any = matchlist(g:pace_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(29, '0.00', s:enter_any[1])
	call s:Assert_Equal(30, '0', s:enter_any[2])
	call s:Assert_Equal(31, '0', s:enter_any[3])
	call s:Assert_Equal(32, '0', s:enter_any[4])
	call s:Assert_True(58, exists('#pace#CursorHoldI#*'))
	doautocmd pace CursorHoldI
	call s:Assert_True(59, exists('g:pace_info'))
	let s:enter_any = matchlist(g:pace_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(33, '0.00', s:enter_any[1])
	call s:Assert_Equal(34, '2', s:enter_any[2])
	call s:Assert_Equal(35, '2', s:enter_any[3])
	call s:Assert_Equal(36, '0', s:enter_any[4])
	call s:Assert_True(60, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave
finally
	let &updatetime = s:pace.state.updatetime
endtry

let &cpoptions = s:cpoptions
unlet s:cpoptions
quitall
"""""""""""""""""""""""""""""""""""""|EOF|""""""""""""""""""""""""""""""""""""
