""""""""""""""""""""""""""""""""""|eval.vim|""""""""""""""""""""""""""""""""""
let s:cpoptions = &cpoptions
set cpoptions-=C					" Join line-breaks.

let s:eval_mode = s:mockup.mode
call s:Assert_Not_Equal(1, 'i', s:mockup.mode)

try
	let s:insertmode = 'i'
	let s:mockup.mode = 'i'
	call s:Assert_Equal(1, 0, s:demo.char)
	call s:Assert_Equal(2, 0, s:demo.sec)
	call s:Assert_True(1, exists('g:demo_info'))
	let s:eval_any = matchlist(g:demo_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(3, '0.00', s:eval_any[1])	" tick
	call s:Assert_Equal(4, '0', s:eval_any[2])	" pace
	call s:Assert_Equal(5, '0', s:eval_any[3])	" chars
	call s:Assert_Equal(6, '0', s:eval_any[4])	" secs

	call s:demo.eval()
	call s:Assert_Equal(7, s:demo.break, s:mockup.time.before)
	call s:Assert_Equal(8, 1, s:demo.char)
	call s:Assert_True(2, exists('g:demo_info'))
	let s:eval_any = matchlist(g:demo_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(9, '0.00', s:eval_any[1])
	call s:Assert_Equal(10, '1', s:eval_any[2])
	call s:Assert_Equal(11, '1', s:eval_any[3])
	call s:Assert_Equal(12, '0', s:eval_any[4])

	call s:demo.eval()
	call s:Assert_Equal(13, 2, s:demo.char)
	call s:Assert_True(3, exists('g:demo_info'))
	let s:eval_any = matchlist(g:demo_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(14, '0.00', s:eval_any[1])
	call s:Assert_Equal(15, '2', s:eval_any[2])
	call s:Assert_Equal(16, '2', s:eval_any[3])
	call s:Assert_Equal(17, '0', s:eval_any[4])

	call s:demo.eval()
	call s:Assert_Equal(18, 3, s:demo.char)
	call s:Assert_True(4, exists('g:demo_info'))
	let s:eval_any = matchlist(g:demo_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(19, '0.00', s:eval_any[1])
	call s:Assert_Equal(20, '3', s:eval_any[2])
	call s:Assert_Equal(21, '3', s:eval_any[3])
	call s:Assert_Equal(22, '0', s:eval_any[4])

	call s:demo.eval()
	call s:Assert_Equal(23, s:demo.break, s:mockup.time.before)
	call s:Assert_Equal(24, 4, s:demo.char)
	call s:Assert_Equal(25, 0, s:demo.sec)
	call s:Assert_True(5, exists('g:demo_info'))
	let s:eval_any = matchlist(g:demo_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(26, '0.00', s:eval_any[1])
	call s:Assert_Equal(27, '4', s:eval_any[2])
	call s:Assert_Equal(28, '4', s:eval_any[3])
	call s:Assert_Equal(29, '0', s:eval_any[4])
finally
	let s:mockup.mode = s:eval_mode
endtry

let &cpoptions = s:cpoptions
unlet s:cpoptions
quit
"""""""""""""""""""""""""""""""""""""|EOF|""""""""""""""""""""""""""""""""""""
