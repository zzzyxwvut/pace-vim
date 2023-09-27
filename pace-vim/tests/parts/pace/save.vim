##################################|save.vim|##################################
if exists(':PaceSaveTo') != 2
	quit
endif

pace.dump = {'0': [[0, 0, 0, 0]]}
const save_mode: string = mockup.mode

try
	Assert_Not_Equal(1, 'i', mockup.mode)
	const save_1: number = Pace_Load(1)
	insertmode = 'i'
	mockup.mode = 'i'
	unlet! g:pace_policy
	g:pace_policy = 10007

	# Note that the effects of the following autocmds are asserted in
	# the remaining tests of this script.
	Assert_True(1, exists('#pace'))
	Assert_True(2, exists('#pace#InsertEnter#*'))
	doautocmd pace InsertEnter
	Assert_True(3, exists('#pace#CursorMovedI#*'))
	doautocmd pace CursorMovedI
	doautocmd pace CursorMovedI
	Assert_True(4, exists('#pace#InsertLeave#*'))
	doautocmd pace InsertLeave
finally
	mockup.mode = save_mode
endtry

PaceSaveTo .
unlet! g:pace_dump
execute 'source ' .. split(expand('pace_*'), "\n")[-1]
Assert_True(5, exists('g:pace_dump'))
Assert_Equal(1, pace.dump, g:pace_dump)
unlet g:pace_dump
quit
#####################################|EOF|####################################
