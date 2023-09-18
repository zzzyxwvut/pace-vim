""""""""""""""""""""""""""""|carryover-tail-f.vim|""""""""""""""""""""""""""""
let s:cpoptions = &cpoptions
set cpoptions-=C					" Join line-breaks.

let $TEST_PACE_CURSOR_OFFSET = 0
call s:Assert_Equal(1,
		\ {
			\ '0': [[3, 3, 33, 3]],
			\ '1': [[1, 1, 11, 1], [1, 360, 11, 1]],
			\ '2': [[1, 2, 11, 1], [2, 362, 11, 1]],
			\ '3': [[1, 3, 11, 1], [3, 364, 11, 1]],
		\ },
		\ s:pace.dump)

let &cpoptions = s:cpoptions
unlet! g:pace_dump s:cpoptions
quit
"""""""""""""""""""""""""""""""""""""|EOF|""""""""""""""""""""""""""""""""""""
