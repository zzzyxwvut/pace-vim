""""""""""""""""""""""""""""""""""|swap.vim|""""""""""""""""""""""""""""""""""
if winnr('$') != 1
	only
endif

let s:pace.dump = {'0': [[0, 0, 0, 0]]}
let s:swap_mode = s:mockup.mode
call s:Assert_Not_Equal(1, 'i', s:mockup.mode)

try
	" MAKE A TRANSITION WITH s:pace.enter().
	let s:swap_status_1 = 'swap_1'
	let s:swap_buffer_1 = bufnr('%')
	call setbufvar(s:swap_buffer_1, '&statusline', s:swap_status_1)
	let s:swap_1 = s:Pace_Load(1)
	let s:insertmode = 'i'
	let s:mockup.mode = 'i'
	unlet! g:pace_policy
	let g:pace_policy = 10007

	" Attempt and abandon typing in an only window.
	call s:Assert_True(1, exists('#pace'))
	call s:Assert_True(2, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	call s:Assert_True(3, !empty(&rulerformat))
	call s:Assert_Equal(1, s:swap_status_1, &l:statusline)
	call s:Assert_True(4, &rulerformat =~ 'g:pace_info')
	call s:Assert_True(5, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave

	new
	let s:swap_status_2 = 'swap_2'
	let s:swap_buffer_2 = bufnr('%')
	call setbufvar(s:swap_buffer_2, '&statusline', s:swap_status_2)

	" Attempt and abandon typing in another window.
	call s:Assert_True(6, exists('#pace'))
	call s:Assert_True(7, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	call s:Assert_True(8, empty(&rulerformat))
	call s:Assert_Not_Equal(2, s:swap_status_2, &l:statusline)
	call s:Assert_True(9, &l:statusline =~ 'g:pace_info')
	call s:Assert_True(10, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave

	" Attempt and abandon typing in another window, but through
	" an alternate viewport.
	split
	call s:Assert_True(11, exists('#pace'))
	call s:Assert_True(12, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	call s:Assert_Not_Equal(3, s:swap_status_2, &l:statusline)
	call s:Assert_True(13, &l:statusline =~ 'g:pace_info')
	call s:Assert_True(14, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave

	" Return to the initial viewport of another window.
	wincmd j
	call s:Assert_Equal(2, s:swap_status_2, &l:statusline)
	call s:Assert_True(15, &l:statusline !~ 'g:pace_info')

	" Attempt and abandon typing in the initial window.
	execute bufwinnr(s:swap_buffer_1).'wincmd w'
	call s:Assert_True(16, exists('#pace'))
	call s:Assert_True(17, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	call s:Assert_Not_Equal(4, s:swap_status_1, &l:statusline)
	call s:Assert_True(18, &l:statusline =~ 'g:pace_info')
	call s:Assert_True(19, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave

	" MAKE A TRANSITION WITH s:Pace_Load().
	let s:mockup.mode = 'n'
	let s:swap_2 = s:Pace_Load(0)
	call s:Assert_True(20, !exists('#pace#InsertEnter#*'))
	call s:Assert_Equal(3, s:swap_status_1, &l:statusline)
	call s:Assert_True(21, &l:statusline !~ 'g:pace_info')

	" MAKE A TRANSITION WITH s:Pace_Free().
	let s:swap_3 = s:Pace_Free()
	call s:Assert_True(22, !exists('#pace'))
	call s:Assert_Equal(4, s:swap_status_1, &l:statusline)
	call s:Assert_True(23, &l:statusline !~ 'g:pace_info')

	" Return to the initial viewport of another window.
	wincmd k
	call s:Assert_Equal(5, s:swap_status_2, &l:statusline)
	call s:Assert_True(24, &l:statusline !~ 'g:pace_info')

	" Return to the alternate viewport of another window.
	wincmd k
	call s:Assert_Equal(6, s:swap_status_2, &l:statusline)
	call s:Assert_True(25, &l:statusline !~ 'g:pace_info')

	" Allow for re-sourcing.
	execute bufwinnr(s:swap_buffer_1).'wincmd w'
	only
	execute 'bwipeout '.s:swap_buffer_2
finally
	let s:mockup.mode = s:swap_mode
endtry

unlet! g:pace_dump
quitall
"""""""""""""""""""""""""""""""""""""|EOF|""""""""""""""""""""""""""""""""""""
