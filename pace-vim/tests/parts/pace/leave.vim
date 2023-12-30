##################################|leave.vim|#################################
# Also see {enter,test}.vim.
pace.dump = {'0': [[0, 0, 0, 0]]}
const leave_buffer_1: number = bufnr('%')
const leave_mode: string = mockup.mode
const leave_1: number = Pace_Load(1)
insertmode = 'i'
var leave_hit: list<number>
var leave_total: list<number>
var leave_whole: list<number>

try
	Assert_Not_Equal(1, 'i', mockup.mode)
	mockup.mode = 'i'

	Assert_True(1, !exists('#pace#InsertLeave#*'))
	Assert_Equal(1, -1, Get_Chars())
	Assert_Equal(2, -1, Get_Secs())
	Assert_True(2, exists('#pace'))
	Assert_True(3, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	Assert_Equal(3, 0, Get_Chars())
	Assert_Equal(4, 0, Get_Secs())
	Assert_True(4, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	Assert_Equal(5, 2, Get_Chars())
	Assert_Equal(6, 0, Get_Secs())
	Assert_True(5, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave

	# [log_hits, all_hits, char, sec]
	leave_whole = pace.dump[0][0]
	Assert_Equal(7, 1, leave_whole[0])
	Assert_Equal(8, 1, leave_whole[1])
	Assert_Equal(9, 2, leave_whole[2])
	Assert_Equal(10, 0, leave_whole[3])

	Assert_True(6, exists('g:pace_amin'))
	Assert_Equal(11, g:pace_amin, (leave_whole[2] * 60))

	# [buf_hits, last_hit, char, sec]
	leave_total = pace.dump[leave_buffer_1][0]
	Assert_Equal(12, 1, leave_total[0])
	Assert_Equal(13, 1, leave_total[1])
	Assert_Equal(14, 2, leave_total[2])
	Assert_Equal(15, 0, leave_total[3])

	# [this_hit, hit_time, char, sec]
	leave_hit = pace.dump[leave_buffer_1][-1]
	Assert_Equal(16, 1, leave_hit[0])
	Assert_Equal(17, 0, leave_hit[1])
	Assert_Equal(18, 2, leave_hit[2])
	Assert_Equal(19, 0, leave_hit[3])

	Assert_Equal(20, -1, Get_Chars())
	Assert_Equal(21, -1, Get_Secs())
finally
	mockup.mode = leave_mode
endtry


new
const leave_buffer_2: number = bufnr('%')

try
	Assert_Not_Equal(2, 'i', mockup.mode)
	mockup.mode = 'i'

	Assert_True(7, !exists('#pace#InsertLeave#*'))
	Assert_Equal(22, -1, Get_Chars())
	Assert_Equal(23, -1, Get_Secs())
	Assert_True(8, exists('#pace'))
	Assert_True(9, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	Assert_Equal(24, 0, Get_Chars())
	Assert_Equal(25, 0, Get_Secs())
	Assert_True(10, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	Assert_Equal(26, 2, Get_Chars())
	Assert_Equal(27, 0, Get_Secs())
	Assert_True(11, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave

	# [log_hits, all_hits, char, sec]
	leave_whole = pace.dump[0][0]
	Assert_Equal(28, 2, leave_whole[0])
	Assert_Equal(29, 2, leave_whole[1])
	Assert_Equal(30, 4, leave_whole[2])
	Assert_Equal(31, 0, leave_whole[3])

	Assert_True(12, exists('g:pace_amin'))
	Assert_Equal(32, g:pace_amin, (leave_whole[2] * 60))

	# [buf_hits, last_hit, char, sec]
	leave_total = pace.dump[leave_buffer_2][0]
	Assert_Equal(33, 1, leave_total[0])
	Assert_Equal(34, 2, leave_total[1])
	Assert_Equal(35, 2, leave_total[2])
	Assert_Equal(36, 0, leave_total[3])

	# [this_hit, hit_time, char, sec]
	leave_hit = pace.dump[leave_buffer_2][-1]
	Assert_Equal(37, 2, leave_hit[0])
	Assert_Equal(38, 0, leave_hit[1])
	Assert_Equal(39, 2, leave_hit[2])
	Assert_Equal(40, 0, leave_hit[3])

	Assert_Equal(41, -1, Get_Chars())
	Assert_Equal(42, -1, Get_Secs())

	# Allow for re-sourcing.
	execute ':' .. bufwinnr(leave_buffer_1) .. 'wincmd w'
	only
	execute 'bwipeout ' .. leave_buffer_2
finally
	mockup.mode = leave_mode
endtry

try
	Assert_Not_Equal(3, 'i', mockup.mode)
	mockup.mode = 'i'
	unlet! g:pace_sample g:pace_policy
	g:pace_policy = 10001		# The 'i' only (and discarding null).
	Assert_True(13, exists('#pace'))

	# The inhibited updating of g:pace_info.
	pace.sample_in = Pace.sample_above + 1

	insertmode = 'i'
	Assert_True(14, !exists('#pace#CursorMovedI#*'))
	Assert_True(15, !exists('#pace#InsertLeave#*'))
	Assert_True(16, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	Assert_True(17, exists('g:pace_info'))
	Assert_True(18, !islocked('g:pace_info'))
	Assert_True(19, exists('#pace#CursorMovedI#*'))
	Assert_True(20, exists('#pace#InsertLeave#*'))

	insertmode = 'r'
	Assert_True(21, exists('#pace#InsertChange#*'))
	doautocmd pace InsertChange
	Assert_True(22, exists('g:pace_info'))
	Assert_True(23, !islocked('g:pace_info'))
	Assert_True(24, !exists('#pace#CursorMovedI#*'))
	Assert_True(25, !exists('#pace#InsertLeave#*'))

	insertmode = 'i'
	Assert_True(26, exists('#pace#InsertChange#*'))
	doautocmd pace InsertChange
	Assert_True(27, exists('g:pace_info'))
	Assert_True(28, !islocked('g:pace_info'))
	Assert_True(29, exists('#pace#CursorMovedI#*'))
	Assert_True(30, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave
	Assert_True(31, exists('g:pace_info'))
	Assert_True(32, !islocked('g:pace_info'))

	# The continuous updating of g:pace_info.
	pace.sample_in = Pace.sample_below - 1

	insertmode = 'i'
	Assert_True(33, !exists('#pace#CursorMovedI#*'))
	Assert_True(34, !exists('#pace#InsertLeave#*'))
	Assert_True(35, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	Assert_True(36, exists('g:pace_info'))
	Assert_True(37, !islocked('g:pace_info'))
	Assert_True(38, exists('#pace#CursorMovedI#*'))
	Assert_True(39, exists('#pace#InsertLeave#*'))

	insertmode = 'r'
	Assert_True(40, exists('#pace#InsertChange#*'))
	doautocmd pace InsertChange
	Assert_True(41, exists('g:pace_info'))
	Assert_True(42, !islocked('g:pace_info'))
	Assert_True(43, !exists('#pace#CursorMovedI#*'))
	Assert_True(44, !exists('#pace#InsertLeave#*'))

	insertmode = 'i'
	Assert_True(45, exists('#pace#InsertChange#*'))
	doautocmd pace InsertChange
	Assert_True(46, exists('g:pace_info'))
	Assert_True(47, !islocked('g:pace_info'))
	Assert_True(48, exists('#pace#CursorMovedI#*'))
	Assert_True(49, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave
	Assert_True(50, exists('g:pace_info'))
	Assert_True(51, !islocked('g:pace_info'))

	# The sampling updating of g:pace_info.
	pace.sample_in = Pace.sample_above - Pace.sample_below

	insertmode = 'i'
	Assert_True(52, !exists('#pace#CursorMovedI#*'))
	Assert_True(53, !exists('#pace#CursorHoldI#*'))
	Assert_True(54, !exists('#pace#InsertLeave#*'))
	Assert_True(55, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	Assert_True(56, exists('g:pace_info'))
	Assert_True(57, !islocked('g:pace_info'))
	Assert_True(58, exists('#pace#CursorMovedI#*'))
	Assert_True(59, exists('#pace#InsertLeave#*'))
	Assert_True(60, exists('#pace#CursorHoldI#*'))
	doautocmd pace CursorHoldI
	Assert_True(61, exists('g:pace_info'))
	Assert_True(62, !islocked('g:pace_info'))

	insertmode = 'r'
	Assert_True(63, exists('#pace#InsertChange#*'))
	doautocmd pace InsertChange
	Assert_True(64, exists('g:pace_info'))
	Assert_True(65, !islocked('g:pace_info'))
	Assert_True(66, !exists('#pace#CursorMovedI#*'))
	Assert_True(67, !exists('#pace#CursorHoldI#*'))
	Assert_True(68, !exists('#pace#InsertLeave#*'))

	insertmode = 'i'
	Assert_True(69, exists('#pace#InsertChange#*'))
	doautocmd pace InsertChange
	Assert_True(70, exists('g:pace_info'))
	Assert_True(71, !islocked('g:pace_info'))
	Assert_True(72, exists('#pace#CursorMovedI#*'))
	Assert_True(73, exists('#pace#CursorHoldI#*'))
	doautocmd pace CursorHoldI
	Assert_True(74, exists('g:pace_info'))
	Assert_True(75, !islocked('g:pace_info'))
	Assert_True(76, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave
	Assert_True(77, exists('g:pace_info'))
	Assert_True(78, !islocked('g:pace_info'))
finally
	mockup.mode = leave_mode
	insertmode = 'i'
	g:pace_policy = 10007
endtry

quitall
#####################################|EOF|####################################
