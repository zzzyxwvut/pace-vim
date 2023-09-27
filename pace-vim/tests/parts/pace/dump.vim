""""""""""""""""""""""""""""""""""|dump.vim|""""""""""""""""""""""""""""""""""
def s:Test_()
pace.dump = {'0': [[0, 0, 0, 0]]}
const dump_1: dict<string> = Pace_Dump(1)
Assert_Equal(1, type({}), type(dump_1))
Assert_True(1, has_key(dump_1, printf('%08i', 0)))
Assert_True(2, !has_key(dump_1, printf('%08i', bufnr('%'))))
const dump_mode: string = mockup.mode

try
	Assert_Not_Equal(1, 'i', mockup.mode)
	const dump_2: number = Pace_Load(1)
	insertmode = 'i'
	mockup.mode = 'i'
	unlet! g:pace_policy
	g:pace_policy = 10007

	# Note that the effects of the following autocmds are asserted in
	# the remaining tests of this script.
	Assert_True(3, exists('#pace'))
	Assert_True(4, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	Assert_True(5, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	Assert_True(6, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave
finally
	mockup.mode = dump_mode
endtry

const dump_3: dict<string> = Pace_Dump(1)
Assert_True(7, has_key(dump_3, '_rejects'))
Assert_Equal(2, 0, str2nr(dump_3['_rejects']))

Assert_True(8, has_key(dump_3, '_buffers'))
var dump_any: list<string>
dump_any = matchlist(dump_3['_buffers'], '\v(\w+)\s+(\w+)\s+(\w+)\s+(\w+)')
Assert_Equal(3, 'pace', dump_any[1])
Assert_Equal(4, 'chars', dump_any[2])
Assert_Equal(5, 'secs', dump_any[3])
Assert_Equal(6, 'hits', dump_any[4])

Assert_True(9, has_key(dump_3, printf('%08i', bufnr('%'))))
dump_any = matchlist(dump_3[printf('%08i', bufnr('%'))],
					'\v\s*(\d+)\s+(\d+)\s+(\d+)\s+(\d+)')
Assert_Equal(7, 4, str2nr(dump_any[1]))		# pace
Assert_Equal(8, 4, str2nr(dump_any[2]))		# chars
Assert_Equal(9, 0, str2nr(dump_any[3]))		# secs
Assert_Equal(10, 1, str2nr(dump_any[4]))	# hits

const dump_4: dict<any> = Pace_Dump(0)
Assert_Equal(11, type({}), type(dump_4))
Assert_True(10, dump_4 isnot pace.dump)
Assert_True(11, has_key(dump_4, 0))
Assert_True(12, has_key(dump_4, bufnr('%')))

# The whole: [log_hits, all_hits, char, sec]
Assert_Equal(12, [1, 1, 4, 0], dump_4[0][0])
# Buffer total: [buf_hits, last_hit, char, sec]
Assert_Equal(13, [1, 1, 4, 0], dump_4[bufnr('%')][0])
# Hit instance: [this_hit, hit_time, char, sec]
Assert_Equal(14, [1, 0, 4, 0], dump_4[bufnr('%')][1])

var dump_out: string
var dump_dump: dict<any>

redir => dump_out
silent PaceDump
redir END

dump_dump = eval(dump_out[stridx(dump_out, '{') :])
Assert_Equal(15, dump_4, dump_dump)

redir => dump_out
silent PaceDump 0 0 0 0
redir END

dump_dump = eval(dump_out[stridx(dump_out, '{') :])
Assert_Equal(16, dump_4, dump_dump)

redir => dump_out
silent PaceDump 0 0 0
redir END

const dump_z: number = eval(dump_out[stridx(dump_out, '[') :])
Assert_Equal(17, dump_4[0][0][0], dump_z)

redir => dump_out
silent PaceDump 0 0
redir END

const dump_y: list<number> = eval(dump_out[stridx(dump_out, '[') :])
Assert_Equal(18, dump_4[0][0], dump_y)

redir => dump_out
silent PaceDump 0
redir END

const dump_x: list<list<number>> = eval(dump_out[stridx(dump_out, '[') :])
Assert_Equal(19, dump_4[0], dump_x)

redir => dump_out
silent PaceSum
redir END

for [dump_key: string, dump_value: string] in map(split(dump_out, "\n"),
								'eval(v:val)')
	Assert_Equal(20, dump_3[dump_key], dump_value)
endfor

quit
enddef

call s:Test_()
"""""""""""""""""""""""""""""""""""""|EOF|""""""""""""""""""""""""""""""""""""
