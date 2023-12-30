##################################|free.vim|##################################
pace.dump = {'0': [[0, 0, 0, 0]]}
unlet! g:pace_dump g:pace_pool
var free_mode: string = mockup.mode
var free_1: number = -1

try
	Assert_Not_Equal(1, 'i', mockup.mode)
	mockup.mode = 'i'
	free_1 = Pace_Free()
	Assert_True(1, exists('s:pace'))
	Assert_True(101, pace != null_object)
	Assert_True(2, !exists('g:pace_dump'))
	Assert_True(3, !exists('g:pace_pool'))
finally
	mockup.mode = free_mode
endtry

const free_2: number = Pace_Free()
Assert_True(4, exists('s:pace'))
Assert_True(102, pace == null_object)
Assert_True(5, !exists('#pace'))
Assert_True(6, exists('g:pace_pool'))
Assert_True(7, exists('g:pace_dump'))
Assert_Not_Equal(2, free_1, free_2)

const free_3: number = Pace_Free()
Assert_True(8, exists('s:pace'))
Assert_True(103, pace == null_object)
Assert_True(9, !exists('#pace'))
Assert_True(10, exists('g:pace_pool'))
Assert_True(11, exists('g:pace_dump'))
Assert_Equal(1, free_1, free_3)

unlet! g:pace_dump g:pace_pool
free_mode = mockup.mode
var free_4: number = -1

try
	Assert_Not_Equal(3, 'i', mockup.mode)
	mockup.mode = 'i'
	free_4 = Pace_Free()
	Assert_True(12, exists('s:pace'))
	Assert_True(104, pace == null_object)
	Assert_True(13, !exists('#pace'))
	Assert_True(14, !exists('g:pace_dump'))
	Assert_True(15, !exists('g:pace_pool'))
finally
	mockup.mode = free_mode
endtry

Assert_Equal(2, free_1, free_4)
quit
#####################################|EOF|####################################
