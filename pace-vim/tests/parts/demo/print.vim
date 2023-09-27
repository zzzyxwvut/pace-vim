##################################|print.vim|#################################
try
	var print_cursor: number = 1
	var print_linage: dict<any>
	var print_num: number = 0
	var print_pos: number = 0
	var print_match: string
	var print_off: number
	var print_any: list<any>

	Assert_Not_Equal(1, 'i', mockup.mode)
	Assert_Equal(1, 0, Get_Chars())
	Assert_Equal(2, 0, Get_Secs())
	Assert_True(1, exists('g:demo_info'))
	print_any = matchlist(g:demo_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(3, '0.00', print_any[1])	# tick
	Assert_Equal(4, '0', print_any[2])	# pace
	Assert_Equal(5, '0', print_any[3])	# chars
	Assert_Equal(6, '0', print_any[4])	# secs


	# The 1st\ quatrain.
	print_off = demo.linage[0].offset
	print_match = demo.linage[0].match

	while demo.text[print_pos] !~# print_match
		print_pos += 1
	endwhile

	Print(demo,
		turn,
		print_pos,
		(print_off + print_pos),
		demo.linage[0].name,
		(print_off + 1),
		(len(demo.linage) - 1))
	print_pos += print_off + 1
	Assert_Equal(7, mockup.time.before, Get_Tick())
	Assert_Equal(8, 193, Get_Chars())
	Assert_True(2, exists('g:demo_info'))
	print_any = matchlist(g:demo_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(9, '0.00', print_any[1])
	Assert_Equal(10, '193', print_any[2])
	Assert_Equal(11, '193', print_any[3])
	Assert_Equal(12, '0', print_any[4])

	print_linage = demo.linage[print_num]
	Assert_Equal(13,
		demo.text[(print_cursor + print_num) :
			(print_cursor + print_num + print_linage.offset)],
		getbufline(print_linage.name,
			(len(getbufline(print_linage.name, 1, '$')) -
							print_linage.offset),
			'$'))
	print_num += 1
	print_cursor += print_linage.offset


	# The 2nd\ quatrain.
	print_off = demo.linage[1].offset
	print_match = demo.linage[1].match

	while demo.text[print_pos] !~# print_match
		print_pos += 1
	endwhile

	Print(demo,
		turn,
		print_pos,
		(print_off + print_pos),
		demo.linage[1].name,
		(print_off + 1),
		(len(demo.linage) - 2))
	print_pos += print_off + 1
	Assert_Equal(14, mockup.time.before, Get_Tick())
	Assert_Equal(15, 386, Get_Chars())
	Assert_True(3, exists('g:demo_info'))
	print_any = matchlist(g:demo_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(16, '0.00', print_any[1])
	Assert_Equal(17, '386', print_any[2])
	Assert_Equal(18, '386', print_any[3])
	Assert_Equal(19, '0', print_any[4])

	print_linage = demo.linage[print_num]
	Assert_Equal(20,
		demo.text[(print_cursor + print_num) :
			(print_cursor + print_num + print_linage.offset)],
		getbufline(print_linage.name,
			(len(getbufline(print_linage.name, 1, '$')) -
							print_linage.offset),
			'$'))
	print_num += 1
	print_cursor += print_linage.offset


	# The 3rd\ quatrain.
	print_off = demo.linage[2].offset
	print_match = demo.linage[2].match

	while demo.text[print_pos] !~# print_match
		print_pos += 1
	endwhile

	Print(demo,
		turn,
		print_pos,
		(print_off + print_pos),
		demo.linage[2].name,
		(print_off + 1),
		(len(demo.linage) - 3))
	print_pos += print_off + 1
	Assert_Equal(21, mockup.time.before, Get_Tick())
	Assert_Equal(22, 579, Get_Chars())
	Assert_True(4, exists('g:demo_info'))
	print_any = matchlist(g:demo_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(23, '0.00', print_any[1])
	Assert_Equal(24, '579', print_any[2])
	Assert_Equal(25, '579', print_any[3])
	Assert_Equal(26, '0', print_any[4])

	print_linage = demo.linage[print_num]
	Assert_Equal(27,
		demo.text[(print_cursor + print_num) :
			(print_cursor + print_num + print_linage.offset)],
		getbufline(print_linage.name,
			(len(getbufline(print_linage.name, 1, '$')) -
							print_linage.offset),
			'$'))
	print_num += 1
	print_cursor += print_linage.offset


	# The\ couplet.
	print_off = demo.linage[3].offset
	print_match = demo.linage[3].match

	while demo.text[print_pos] !~# print_match
		print_pos += 1
	endwhile

	Print(demo,
		turn,
		print_pos,
		(print_off + print_pos),
		demo.linage[3].name,
		(print_off + 1),
		(len(demo.linage) - 4))
	print_pos += print_off + 1
	Assert_Equal(28, mockup.time.before, Get_Tick())
	Assert_Equal(29, 686, Get_Chars())
	Assert_Equal(30, 0, Get_Secs())
	Assert_True(5, exists('g:demo_info'))
	print_any = matchlist(g:demo_info,
				'\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	Assert_Equal(31, '0.00', print_any[1])
	Assert_Equal(32, '686', print_any[2])
	Assert_Equal(33, '686', print_any[3])
	Assert_Equal(34, '0', print_any[4])

	print_linage = demo.linage[print_num]
	Assert_Equal(35,
		demo.text[(print_cursor + print_num) :
			(print_cursor + print_num + print_linage.offset)],
		getbufline(print_linage.name,
			(len(getbufline(print_linage.name, 1, '$')) -
							print_linage.offset),
			'$'))
##	print_num += 1
##	print_cursor += print_linage.offset
finally
	@z = demo.reg_z
	&g:statusline = demo.state.statusline
	&equalalways = demo.state.equalalways
	&rulerformat = demo.state.rulerformat
	&ruler = demo.state.ruler
	&maxfuncdepth = demo.state.maxfuncdepth
	&laststatus = demo.state.laststatus
	const print_switchbuf: string = &switchbuf

	try
		setglobal switchbuf=useopen
		execute 'sbuffer ' .. demo.state.buffer
	catch	/.*/
		Err_Msg(demo, v:exception)
	finally
		&switchbuf = print_switchbuf
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
