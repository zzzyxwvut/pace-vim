""""""""""""""""""""""""""""""""""|save.vim|""""""""""""""""""""""""""""""""""
if exists(':PaceSaveTo') != 2
	quit
endif

let s:pace.dump = {'0': [[0, 0, 0, 0]]}
let s:save_mode = s:mockup.mode

try
	call s:Assert_Not_Equal(1, 'i', s:mockup.mode)
	let s:save_1 = s:Pace_Load(1)
	let s:insertmode = 'i'
	let s:mockup.mode = 'i'
	unlet! g:pace_policy
	let g:pace_policy = 10007

	" Note that the effects of the following autocmds are asserted in
	" the remaining tests of this script.
	call s:Assert_True(1, exists('#pace'))
	call s:Assert_True(2, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	call s:Assert_True(3, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	call s:Assert_True(4, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave
finally
	let s:mockup.mode = s:save_mode
endtry

PaceSaveTo .
unlet! g:pace_dump
execute 'source '.split(expand('pace_*'), "\n")[-1]
call s:Assert_True(5, exists('g:pace_dump'))
call s:Assert_Equal(1, s:pace.dump, g:pace_dump)
unlet! g:pace_dump
quit
"""""""""""""""""""""""""""""""""""""|EOF|""""""""""""""""""""""""""""""""""""
