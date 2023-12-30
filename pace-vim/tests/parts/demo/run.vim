###################################|run.vim|##################################
try
	var run_linage: Linage
	var run_any: list<any>

	Assert_Not_Equal(1, 'i', mockup.mode)
	Assert_Not_Equal(2, demo, null_object)
	Assert_Not_Equal(3, turn, null_object)
	Assert_Equal(1, 0, Get_Chars())
	Assert_Equal(2, 0, Get_Secs())
	Assert_True(1, exists('g:demo_info'))
	run_any = matchlist(g:demo_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(3, '0.00', run_any[1])	# tick
	Assert_Equal(4, '0', run_any[2])	# pace
	Assert_Equal(5, '0', run_any[3])	# chars
	Assert_Equal(6, '0', run_any[4])	# secs

	Run(demo, turn)

	Assert_Equal(7, mockup.time.before, Get_Tick())
	Assert_Equal(8, 686, Get_Chars())
	Assert_Equal(9, 0, Get_Secs())
	Assert_True(2, exists('g:demo_info'))
	run_any = matchlist(g:demo_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(10, '0.00', run_any[1])
	Assert_Equal(11, '686', run_any[2])
	Assert_Equal(12, '686', run_any[3])
	Assert_Equal(13, '0', run_any[4])

	var run_cursor: number = 1

	for run_num in [0, 1, 2, 3]
		run_linage = demo.linage[run_num]
		Assert_Equal(14,
			demo.text[(run_cursor + run_num) :
				(run_cursor + run_num + run_linage.offset)],
			getbufline(run_linage.name,
				(len(getbufline(run_linage.name, 1, '$')) -
							run_linage.offset),
				'$'))
		run_cursor += run_linage.offset
	endfor
finally
	@z = demo.reg_z
	demo.state.Restore()

	const run_switchbuf: string = &switchbuf

	try
		setglobal switchbuf=useopen
		execute 'sbuffer ' .. demo.state.buffer
	catch	/.*/
		Err_Msg(demo, v:exception)
	finally
		&switchbuf = run_switchbuf
	endtry

	# Allow for re-sourcing.
	if has('autocmd') && &eventignore !~? '\v%(all|sourcepre)'
		augroup demo
			autocmd! demo
			autocmd SourcePre	<buffer> only
		augroup END
	else
		only
	endif
endtry

quitall
#####################################|EOF|####################################
