""""""""""""""""""""""""""""""""""|free.vim|""""""""""""""""""""""""""""""""""
let s:pace.dump = {'0': [[0, 0, 0, 0]]}
unlet! g:pace_dump g:pace_pool
let s:free_1 = -1
let s:free_mode = s:mockup.mode

try
	call s:Assert_Not_Equal(1, 'i', s:mockup.mode)
	let s:mockup.mode = 'i'
	let s:free_1 = s:Pace_Free()
	call s:Assert_True(1, exists('s:pace'))
	call s:Assert_True(2, !exists('g:pace_dump'))
	call s:Assert_True(3, !exists('g:pace_pool'))
finally
	let s:mockup.mode = s:free_mode
endtry

let s:free_2 = s:Pace_Free()
call s:Assert_True(4, !exists('s:pace'))
call s:Assert_True(5, !exists('#pace'))
call s:Assert_True(6, exists('g:pace_pool'))
call s:Assert_True(7, exists('g:pace_dump'))
call s:Assert_Not_Equal(2, s:free_1, s:free_2)

let s:free_3 = s:Pace_Free()
call s:Assert_True(8, !exists('s:pace'))
call s:Assert_True(9, !exists('#pace'))
call s:Assert_True(10, exists('g:pace_pool'))
call s:Assert_True(11, exists('g:pace_dump'))
call s:Assert_Equal(1, s:free_1, s:free_3)

unlet! g:pace_dump g:pace_pool
let s:free_4 = -1
let s:free_mode = s:mockup.mode

try
	call s:Assert_Not_Equal(3, 'i', s:mockup.mode)
	let s:mockup.mode = 'i'
	let s:free_4 = s:Pace_Free()
	call s:Assert_True(12, !exists('s:pace'))
	call s:Assert_True(13, !exists('#pace'))
	call s:Assert_True(14, !exists('g:pace_dump'))
	call s:Assert_True(15, !exists('g:pace_pool'))
finally
	let s:mockup.mode = s:free_mode
endtry

call s:Assert_Equal(2, s:free_1, s:free_4)
quit
"""""""""""""""""""""""""""""""""""""|EOF|""""""""""""""""""""""""""""""""""""
