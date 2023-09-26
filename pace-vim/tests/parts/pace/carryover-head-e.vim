""""""""""""""""""""""""""""|carryover-head-e.vim|""""""""""""""""""""""""""""
let s:cpoptions = &cpoptions
set cpoptions-=C					" Join line-breaks.

unlet! g:pace_lock g:pace_dump
let g:pace_dump = {
	\ '1': [[1, 1, 11, 1], [1, 360, 11, 1]],
	\ '2': [[1, 2, 11, 1], [2, 362, 11, 1]],
\ }

let &cpoptions = s:cpoptions
unlet s:cpoptions
let $TEST_PACE_CURSOR_OFFSET = 14
"""""""""""""""""""""""""""""""""""""|EOF|""""""""""""""""""""""""""""""""""""
