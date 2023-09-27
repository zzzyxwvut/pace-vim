##################################|swap.vim|##################################
if winnr('$') != 1
	only
endif

pace.dump = {'0': [[0, 0, 0, 0]]}

const swap_mode: string = mockup.mode
Assert_Not_Equal(1, 'i', mockup.mode)

try
	# MAKE A TRANSITION WITH s:Enter().
	const swap_status_1: string = 'swap_1'
	const swap_buffer_1: number = bufnr('%')
	setbufvar(swap_buffer_1, '&statusline', swap_status_1)
	const swap_1: number = Pace_Load(1)
	insertmode = 'i'
	mockup.mode = 'i'
	unlet! g:pace_policy
	g:pace_policy = 10007

	# Attempt and abandon typing in an only window.
	Assert_True(1, exists('#pace'))
	Assert_True(2, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	Assert_True(3, !empty(&rulerformat))
	Assert_Equal(1, swap_status_1, &l:statusline)
	Assert_True(4, &rulerformat =~ 'g:pace_info')
	Assert_True(5, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave

	new
	const swap_status_2: string = 'swap_2'
	const swap_buffer_2: number = bufnr('%')
	setbufvar(swap_buffer_2, '&statusline', swap_status_2)

	# Attempt and abandon typing in another window.
	Assert_True(6, exists('#pace'))
	Assert_True(7, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	Assert_True(8, empty(&rulerformat))
	Assert_Not_Equal(2, swap_status_2, &l:statusline)
	Assert_True(9, &l:statusline =~ 'g:pace_info')
	Assert_True(10, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave

	# Attempt and abandon typing in another window, but through
	# an alternate viewport.
	split
	Assert_True(11, exists('#pace'))
	Assert_True(12, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	Assert_Not_Equal(3, swap_status_2, &l:statusline)
	Assert_True(13, &l:statusline =~ 'g:pace_info')
	Assert_True(14, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave

	# Return to the initial viewport of another window.
	wincmd j
	Assert_Equal(2, swap_status_2, &l:statusline)
	Assert_True(15, &l:statusline !~ 'g:pace_info')

	# Attempt and abandon typing in the initial window.
	execute ':' .. bufwinnr(swap_buffer_1) .. 'wincmd w'
	Assert_True(16, exists('#pace'))
	Assert_True(17, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	Assert_Not_Equal(4, swap_status_1, &l:statusline)
	Assert_True(18, &l:statusline =~ 'g:pace_info')
	Assert_True(19, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave

	# MAKE A TRANSITION WITH s:Pace_Load().
	mockup.mode = 'n'
	const swap_2: number = Pace_Load(0)
	Assert_True(20, !exists('#pace#InsertEnter#*'))
	Assert_Equal(3, swap_status_1, &l:statusline)
	Assert_True(21, &l:statusline !~ 'g:pace_info')

	# MAKE A TRANSITION WITH s:Pace_Free().
	const swap_3: number = Pace_Free()
	Assert_True(22, !exists('#pace'))
	Assert_Equal(4, swap_status_1, &l:statusline)
	Assert_True(23, &l:statusline !~ 'g:pace_info')

	# Return to the initial viewport of another window.
	wincmd k
	Assert_Equal(5, swap_status_2, &l:statusline)
	Assert_True(24, &l:statusline !~ 'g:pace_info')

	# Return to the alternate viewport of another window.
	wincmd k
	Assert_Equal(6, swap_status_2, &l:statusline)
	Assert_True(25, &l:statusline !~ 'g:pace_info')

	# Allow for re-sourcing.
	execute ':' .. bufwinnr(swap_buffer_1) .. 'wincmd w'
	only
	execute 'bwipeout ' .. swap_buffer_2
finally
	mockup.mode = swap_mode
endtry

unlet! g:pace_dump
quitall
#####################################|EOF|####################################
