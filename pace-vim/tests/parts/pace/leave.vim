""""""""""""""""""""""""""""""""""|leave.vim|"""""""""""""""""""""""""""""""""
" Also see test.vim.

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
	execute bufwinnr(s:leave_buffer_1).'wincmd w'
	only
	execute 'bwipeout '.s:leave_buffer_2
finally
	let s:mockup.mode = s:leave_mode
endtry

quitall
"""""""""""""""""""""""""""""""""""""|EOF|""""""""""""""""""""""""""""""""""""
