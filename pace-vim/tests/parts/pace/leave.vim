""""""""""""""""""""""""""""""""""|leave.vim|"""""""""""""""""""""""""""""""""
" Also see {enter,test}.vim.

let s:pace.dump = {'0': [[0, 0, 0, 0]]}
let s:leave_buffer_1 = bufnr('%')
let s:leave_mode = s:mockup.mode
let s:leave_1 = s:Pace_Load(1)
let s:insertmode = 'i'

try
	call s:Assert_Not_Equal(1, 'i', s:mockup.mode)
	let s:mockup.mode = 'i'

	call s:Assert_True(1, !exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(1, -1, s:Get_Chars())
	call s:Assert_Equal(2, -1, s:Get_Secs())
	call s:Assert_True(2, exists('#pace'))
	call s:Assert_True(3, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	call s:Assert_Equal(3, 0, s:Get_Chars())
	call s:Assert_Equal(4, 0, s:Get_Secs())
	call s:Assert_True(4, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	call s:Assert_Equal(5, 2, s:Get_Chars())
	call s:Assert_Equal(6, 0, s:Get_Secs())
	call s:Assert_True(5, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave

	" [log_hits, all_hits, char, sec]
	let s:leave_whole = s:pace.dump[0][0]
	call s:Assert_Equal(7, 1, s:leave_whole[0])
	call s:Assert_Equal(8, 1, s:leave_whole[1])
	call s:Assert_Equal(9, 2, s:leave_whole[2])
	call s:Assert_Equal(10, 0, s:leave_whole[3])

	call s:Assert_True(6, exists('g:pace_amin'))
	call s:Assert_Equal(11, g:pace_amin, (s:leave_whole[2] * 60))

	" [buf_hits, last_hit, char, sec]
	let s:leave_total = s:pace.dump[s:leave_buffer_1][0]
	call s:Assert_Equal(12, 1, s:leave_total[0])
	call s:Assert_Equal(13, 1, s:leave_total[1])
	call s:Assert_Equal(14, 2, s:leave_total[2])
	call s:Assert_Equal(15, 0, s:leave_total[3])

	" [this_hit, hit_time, char, sec]
	let s:leave_hit = s:pace.dump[s:leave_buffer_1][-1]
	call s:Assert_Equal(16, 1, s:leave_hit[0])
	call s:Assert_Equal(17, 0, s:leave_hit[1])
	call s:Assert_Equal(18, 2, s:leave_hit[2])
	call s:Assert_Equal(19, 0, s:leave_hit[3])

	call s:Assert_Equal(20, -1, s:Get_Chars())
	call s:Assert_Equal(21, -1, s:Get_Secs())
finally
	let s:mockup.mode = s:leave_mode
endtry


new
let s:leave_buffer_2 = bufnr('%')

try
	call s:Assert_Not_Equal(2, 'i', s:mockup.mode)
	let s:mockup.mode = 'i'

	call s:Assert_True(7, !exists('#pace#InsertLeave#*'))
	call s:Assert_Equal(22, -1, s:Get_Chars())
	call s:Assert_Equal(23, -1, s:Get_Secs())
	call s:Assert_True(8, exists('#pace'))
	call s:Assert_True(9, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	call s:Assert_Equal(24, 0, s:Get_Chars())
	call s:Assert_Equal(25, 0, s:Get_Secs())
	call s:Assert_True(10, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	call s:Assert_Equal(26, 2, s:Get_Chars())
	call s:Assert_Equal(27, 0, s:Get_Secs())
	call s:Assert_True(11, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave

	" [log_hits, all_hits, char, sec]
	let s:leave_whole = s:pace.dump[0][0]
	call s:Assert_Equal(28, 2, s:leave_whole[0])
	call s:Assert_Equal(29, 2, s:leave_whole[1])
	call s:Assert_Equal(30, 4, s:leave_whole[2])
	call s:Assert_Equal(31, 0, s:leave_whole[3])

	call s:Assert_True(12, exists('g:pace_amin'))
	call s:Assert_Equal(32, g:pace_amin, (s:leave_whole[2] * 60))

	" [buf_hits, last_hit, char, sec]
	let s:leave_total = s:pace.dump[s:leave_buffer_2][0]
	call s:Assert_Equal(33, 1, s:leave_total[0])
	call s:Assert_Equal(34, 2, s:leave_total[1])
	call s:Assert_Equal(35, 2, s:leave_total[2])
	call s:Assert_Equal(36, 0, s:leave_total[3])

	" [this_hit, hit_time, char, sec]
	let s:leave_hit = s:pace.dump[s:leave_buffer_2][-1]
	call s:Assert_Equal(37, 2, s:leave_hit[0])
	call s:Assert_Equal(38, 0, s:leave_hit[1])
	call s:Assert_Equal(39, 2, s:leave_hit[2])
	call s:Assert_Equal(40, 0, s:leave_hit[3])

	call s:Assert_Equal(41, -1, s:Get_Chars())
	call s:Assert_Equal(42, -1, s:Get_Secs())

	" Allow for re-sourcing.
	execute bufwinnr(s:leave_buffer_1) .. 'wincmd w'
	only
	execute 'bwipeout ' .. s:leave_buffer_2
finally
	let s:mockup.mode = s:leave_mode
endtry

try
	call s:Assert_Not_Equal(3, 'i', s:mockup.mode)
	let s:mockup.mode = 'i'
	unlet! g:pace_sample g:pace_policy
	let g:pace_policy = 10001	" The 'i' only (and discarding null).
	call s:Assert_True(13, exists('#pace'))

	" The inhibited updating of g:pace_info.
	let s:pace.sample.in = s:pace.sample.above + 1

	let s:insertmode = 'i'
	call s:Assert_True(14, !exists('#pace#CursorMovedI#*'))
	call s:Assert_True(15, !exists('#pace#InsertLeave#*'))
	call s:Assert_True(16, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	call s:Assert_True(17, exists('g:pace_info'))
	call s:Assert_True(18, !islocked('g:pace_info'))
	call s:Assert_True(19, exists('#pace#CursorMovedI#*'))
	call s:Assert_True(20, exists('#pace#InsertLeave#*'))

	let s:insertmode = 'r'
	call s:Assert_True(21, exists('#pace#InsertChange#*'))
	doautocmd pace InsertChange
	call s:Assert_True(22, exists('g:pace_info'))
	call s:Assert_True(23, !islocked('g:pace_info'))
	call s:Assert_True(24, !exists('#pace#CursorMovedI#*'))
	call s:Assert_True(25, !exists('#pace#InsertLeave#*'))

	let s:insertmode = 'i'
	call s:Assert_True(26, exists('#pace#InsertChange#*'))
	doautocmd pace InsertChange
	call s:Assert_True(27, exists('g:pace_info'))
	call s:Assert_True(28, !islocked('g:pace_info'))
	call s:Assert_True(29, exists('#pace#CursorMovedI#*'))
	call s:Assert_True(30, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave
	call s:Assert_True(31, exists('g:pace_info'))
	call s:Assert_True(32, !islocked('g:pace_info'))

	" The continuous updating of g:pace_info.
	let s:pace.sample.in = s:pace.sample.below - 1

	let s:insertmode = 'i'
	call s:Assert_True(33, !exists('#pace#CursorMovedI#*'))
	call s:Assert_True(34, !exists('#pace#InsertLeave#*'))
	call s:Assert_True(35, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	call s:Assert_True(36, exists('g:pace_info'))
	call s:Assert_True(37, !islocked('g:pace_info'))
	call s:Assert_True(38, exists('#pace#CursorMovedI#*'))
	call s:Assert_True(39, exists('#pace#InsertLeave#*'))

	let s:insertmode = 'r'
	call s:Assert_True(40, exists('#pace#InsertChange#*'))
	doautocmd pace InsertChange
	call s:Assert_True(41, exists('g:pace_info'))
	call s:Assert_True(42, !islocked('g:pace_info'))
	call s:Assert_True(43, !exists('#pace#CursorMovedI#*'))
	call s:Assert_True(44, !exists('#pace#InsertLeave#*'))

	let s:insertmode = 'i'
	call s:Assert_True(45, exists('#pace#InsertChange#*'))
	doautocmd pace InsertChange
	call s:Assert_True(46, exists('g:pace_info'))
	call s:Assert_True(47, !islocked('g:pace_info'))
	call s:Assert_True(48, exists('#pace#CursorMovedI#*'))
	call s:Assert_True(49, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave
	call s:Assert_True(50, exists('g:pace_info'))
	call s:Assert_True(51, !islocked('g:pace_info'))

	" The sampling updating of g:pace_info.
	let s:pace.sample.in = s:pace.sample.above - s:pace.sample.below

	let s:insertmode = 'i'
	call s:Assert_True(52, !exists('#pace#CursorMovedI#*'))
	call s:Assert_True(53, !exists('#pace#CursorHoldI#*'))
	call s:Assert_True(54, !exists('#pace#InsertLeave#*'))
	call s:Assert_True(55, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	call s:Assert_True(56, exists('g:pace_info'))
	call s:Assert_True(57, !islocked('g:pace_info'))
	call s:Assert_True(58, exists('#pace#CursorMovedI#*'))
	call s:Assert_True(59, exists('#pace#InsertLeave#*'))
	call s:Assert_True(60, exists('#pace#CursorHoldI#*'))
	doautocmd pace CursorHoldI
	call s:Assert_True(61, exists('g:pace_info'))
	call s:Assert_True(62, !islocked('g:pace_info'))

	let s:insertmode = 'r'
	call s:Assert_True(63, exists('#pace#InsertChange#*'))
	doautocmd pace InsertChange
	call s:Assert_True(64, exists('g:pace_info'))
	call s:Assert_True(65, !islocked('g:pace_info'))
	call s:Assert_True(66, !exists('#pace#CursorMovedI#*'))
	call s:Assert_True(67, !exists('#pace#CursorHoldI#*'))
	call s:Assert_True(68, !exists('#pace#InsertLeave#*'))

	let s:insertmode = 'i'
	call s:Assert_True(69, exists('#pace#InsertChange#*'))
	doautocmd pace InsertChange
	call s:Assert_True(70, exists('g:pace_info'))
	call s:Assert_True(71, !islocked('g:pace_info'))
	call s:Assert_True(72, exists('#pace#CursorMovedI#*'))
	call s:Assert_True(73, exists('#pace#CursorHoldI#*'))
	doautocmd pace CursorHoldI
	call s:Assert_True(74, exists('g:pace_info'))
	call s:Assert_True(75, !islocked('g:pace_info'))
	call s:Assert_True(76, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave
	call s:Assert_True(77, exists('g:pace_info'))
	call s:Assert_True(78, !islocked('g:pace_info'))
finally
	let s:mockup.mode = s:leave_mode
	let s:insertmode = 'i'
	let g:pace_policy = 10007
endtry

quitall
"""""""""""""""""""""""""""""""""""""|EOF|""""""""""""""""""""""""""""""""""""
