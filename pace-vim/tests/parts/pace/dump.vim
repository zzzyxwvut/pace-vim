""""""""""""""""""""""""""""""""""|dump.vim|""""""""""""""""""""""""""""""""""
let s:cpoptions = &cpoptions
set cpoptions-=C					" Join line-breaks.

let s:pace.dump = {'0': [[0, 0, 0, 0]]}
let s:dump_1 = s:Pace_Dump(1)
call s:Assert_Equal(1, type({}), type(s:dump_1))
call s:Assert_True(1, has_key(s:dump_1, printf('%08i', 0)))
call s:Assert_True(2, !has_key(s:dump_1, printf('%08i', bufnr('%'))))
let s:dump_mode = s:mockup.mode

try
	call s:Assert_Not_Equal(1, 'i', s:mockup.mode)
	let s:dump_2 = s:Pace_Load(1)
	let s:insertmode = 'i'
	let s:mockup.mode = 'i'
	unlet! g:pace_policy
	let g:pace_policy = 10007

	" Note that the effects of the following autocmds are asserted in
	" the remaining tests of this script.
	call s:Assert_True(3, exists('#pace'))
	call s:Assert_True(4, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	call s:Assert_True(5, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	call s:Assert_True(6, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave
finally
	let s:mockup.mode = s:dump_mode
endtry

let s:dump_3 = s:Pace_Dump(1)
call s:Assert_True(7, has_key(s:dump_3, '_rejects'))
call s:Assert_Equal(2, 0, str2nr(s:dump_3['_rejects']))

call s:Assert_True(8, has_key(s:dump_3, '_buffers'))
let s:dump_any = matchlist(s:dump_3['_buffers'],
				\ '\v(\w+)\s+(\w+)\s+(\w+)\s+(\w+)')
call s:Assert_Equal(3, 'pace', s:dump_any[1])
call s:Assert_Equal(4, 'chars', s:dump_any[2])
call s:Assert_Equal(5, 'secs', s:dump_any[3])
call s:Assert_Equal(6, 'hits', s:dump_any[4])

call s:Assert_True(9, has_key(s:dump_3, printf('%08i', bufnr('%'))))
let s:dump_any = matchlist(s:dump_3[printf('%08i', bufnr('%'))],
				\ '\v\s*(\d+)\s+(\d+)\s+(\d+)\s+(\d+)')
call s:Assert_Equal(7, 4, str2nr(s:dump_any[1]))	" pace
call s:Assert_Equal(8, 4, str2nr(s:dump_any[2]))	" chars
call s:Assert_Equal(9, 0, str2nr(s:dump_any[3]))	" secs
call s:Assert_Equal(10, 1, str2nr(s:dump_any[4]))	" hits

let s:dump_4 = s:Pace_Dump(0)
call s:Assert_Equal(11, type({}), type(s:dump_4))
call s:Assert_True(10, s:dump_4 isnot s:pace.dump)
call s:Assert_True(11, has_key(s:dump_4, 0))
call s:Assert_True(12, has_key(s:dump_4, bufnr('%')))

" The whole: [log_hits, all_hits, char, sec]
call s:Assert_Equal(12, [1, 1, 4, 0], s:dump_4[0][0])
" Buffer total: [buf_hits, last_hit, char, sec]
call s:Assert_Equal(13, [1, 1, 4, 0], s:dump_4[bufnr('%')][0])
" Hit instance: [this_hit, hit_time, char, sec]
call s:Assert_Equal(14, [1, 0, 4, 0], s:dump_4[bufnr('%')][1])

redir => s:dump_out
silent PaceDump
redir END

let s:dump_dump = eval(s:dump_out[stridx(s:dump_out, '{') :])
call s:Assert_Equal(15, s:dump_4, s:dump_dump)

redir => s:dump_out
silent PaceDump 0 0 0 0
redir END

let s:dump_dump = eval(s:dump_out[stridx(s:dump_out, '{') :])
call s:Assert_Equal(16, s:dump_4, s:dump_dump)

redir => s:dump_out
silent PaceDump 0 0 0
redir END

let s:dump_z = eval(s:dump_out[stridx(s:dump_out, '[') :])
call s:Assert_Equal(17, s:dump_4[0][0][0], s:dump_z)

redir => s:dump_out
silent PaceDump 0 0
redir END

let s:dump_y = eval(s:dump_out[stridx(s:dump_out, '[') :])
call s:Assert_Equal(18, s:dump_4[0][0], s:dump_y)

redir => s:dump_out
silent PaceDump 0
redir END

let s:dump_x = eval(s:dump_out[stridx(s:dump_out, '[') :])
call s:Assert_Equal(19, s:dump_4[0], s:dump_x)

redir => s:dump_out
silent PaceSum
redir END

for [s:dump_key, s:dump_value] in map(split(s:dump_out, "\n"), 'eval(v:val)')
	call s:Assert_Equal(20, s:dump_3[s:dump_key], s:dump_value)
endfor

let &cpoptions = s:cpoptions
unlet s:cpoptions
quit
"""""""""""""""""""""""""""""""""""""|EOF|""""""""""""""""""""""""""""""""""""
