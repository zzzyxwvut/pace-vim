""""""""""""""""""""""""""""|carryover-tail-a.vim|""""""""""""""""""""""""""""
let $TEST_PACE_CURSOR_OFFSET = 0
call s:Assert_Equal(1, {'0': [[0, 0, 0, 0]]}, s:pace.dump)
unlet! g:pace_dump
quit
"""""""""""""""""""""""""""""""""""""|EOF|""""""""""""""""""""""""""""""""""""
