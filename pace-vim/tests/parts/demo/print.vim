""""""""""""""""""""""""""""""""""|print.vim|"""""""""""""""""""""""""""""""""
let s:cpoptions = &cpoptions
set cpoptions-=C					" Join line-breaks.

try
	let s:print_pos = 0
	let s:print_num = 0
	let s:print_cursor = 1

	call s:Assert_Not_Equal(1, 'i', s:mockup.mode)
	call s:Assert_Equal(1, 0, s:Get_Chars())
	call s:Assert_Equal(2, 0, s:Get_Secs())
	call s:Assert_True(1, exists('g:demo_info'))
	let s:print_any = matchlist(g:demo_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(3, '0.00', s:print_any[1])	" tick
	call s:Assert_Equal(4, '0', s:print_any[2])	" pace
	call s:Assert_Equal(5, '0', s:print_any[3])	" chars
	call s:Assert_Equal(6, '0', s:print_any[4])	" secs


	" The 1st\ quatrain.
	let s:print_off = s:demo.linage[0].offset
	let s:print_match = s:demo.linage[0].match

	while s:demo.text[s:print_pos] !~# s:print_match
		let s:print_pos += 1
	endwhile

	call s:demo.print(s:turn,
			\ s:print_pos,
			\ (s:print_off + s:print_pos),
			\ s:demo.linage[0].name,
			\ (s:print_off + 1),
			\ (len(s:demo.linage) - 1))
	let s:print_pos += s:print_off + 1
	call s:Assert_Equal(7, s:mockup.time.before, s:Get_Tick())
	call s:Assert_Equal(8, 193, s:Get_Chars())
	call s:Assert_True(2, exists('g:demo_info'))
	let s:print_any = matchlist(g:demo_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(9, '0.00', s:print_any[1])
	call s:Assert_Equal(10, '193', s:print_any[2])
	call s:Assert_Equal(11, '193', s:print_any[3])
	call s:Assert_Equal(12, '0', s:print_any[4])

	let s:print_linage = s:demo.linage[s:print_num]
	call s:Assert_Equal(13,
		\ s:demo.text[(s:print_cursor + s:print_num) :
			\ (s:print_cursor + s:print_num + s:print_linage.offset)],
		\ getbufline(s:print_linage.name,
			\ (len(getbufline(s:print_linage.name, 1, '$')) -
							\ s:print_linage.offset),
			\ '$'))
	let s:print_num += 1
	let s:print_cursor += s:print_linage.offset


	" The 2nd\ quatrain.
	let s:print_off = s:demo.linage[1].offset
	let s:print_match = s:demo.linage[1].match

	while s:demo.text[s:print_pos] !~# s:print_match
		let s:print_pos += 1
	endwhile

	call s:demo.print(s:turn,
			\ s:print_pos,
			\ (s:print_off + s:print_pos),
			\ s:demo.linage[1].name,
			\ (s:print_off + 1),
			\ (len(s:demo.linage) - 2))
	let s:print_pos += s:print_off + 1
	call s:Assert_Equal(14, s:mockup.time.before, s:Get_Tick())
	call s:Assert_Equal(15, 386, s:Get_Chars())
	call s:Assert_True(3, exists('g:demo_info'))
	let s:print_any = matchlist(g:demo_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(16, '0.00', s:print_any[1])
	call s:Assert_Equal(17, '386', s:print_any[2])
	call s:Assert_Equal(18, '386', s:print_any[3])
	call s:Assert_Equal(19, '0', s:print_any[4])

	let s:print_linage = s:demo.linage[s:print_num]
	call s:Assert_Equal(20,
		\ s:demo.text[(s:print_cursor + s:print_num) :
			\ (s:print_cursor + s:print_num + s:print_linage.offset)],
		\ getbufline(s:print_linage.name,
			\ (len(getbufline(s:print_linage.name, 1, '$')) -
							\ s:print_linage.offset),
			\ '$'))
	let s:print_num += 1
	let s:print_cursor += s:print_linage.offset


	" The 3rd\ quatrain.
	let s:print_off = s:demo.linage[2].offset
	let s:print_match = s:demo.linage[2].match

	while s:demo.text[s:print_pos] !~# s:print_match
		let s:print_pos += 1
	endwhile

	call s:demo.print(s:turn,
			\ s:print_pos,
			\ (s:print_off + s:print_pos),
			\ s:demo.linage[2].name,
			\ (s:print_off + 1),
			\ (len(s:demo.linage) - 3))
	let s:print_pos += s:print_off + 1
	call s:Assert_Equal(21, s:mockup.time.before, s:Get_Tick())
	call s:Assert_Equal(22, 579, s:Get_Chars())
	call s:Assert_True(4, exists('g:demo_info'))
	let s:print_any = matchlist(g:demo_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(23, '0.00', s:print_any[1])
	call s:Assert_Equal(24, '579', s:print_any[2])
	call s:Assert_Equal(25, '579', s:print_any[3])
	call s:Assert_Equal(26, '0', s:print_any[4])

	let s:print_linage = s:demo.linage[s:print_num]
	call s:Assert_Equal(27,
		\ s:demo.text[(s:print_cursor + s:print_num) :
			\ (s:print_cursor + s:print_num + s:print_linage.offset)],
		\ getbufline(s:print_linage.name,
			\ (len(getbufline(s:print_linage.name, 1, '$')) -
							\ s:print_linage.offset),
			\ '$'))
	let s:print_num += 1
	let s:print_cursor += s:print_linage.offset


	" The\ couplet.
	let s:print_off = s:demo.linage[3].offset
	let s:print_match = s:demo.linage[3].match

	while s:demo.text[s:print_pos] !~# s:print_match
		let s:print_pos += 1
	endwhile

	call s:demo.print(s:turn,
			\ s:print_pos,
			\ (s:print_off + s:print_pos),
			\ s:demo.linage[3].name,
			\ (s:print_off + 1),
			\ (len(s:demo.linage) - 4))
	let s:print_pos += s:print_off + 1
	call s:Assert_Equal(28, s:mockup.time.before, s:Get_Tick())
	call s:Assert_Equal(29, 686, s:Get_Chars())
	call s:Assert_Equal(30, 0, s:Get_Secs())
	call s:Assert_True(5, exists('g:demo_info'))
	let s:print_any = matchlist(g:demo_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(31, '0.00', s:print_any[1])
	call s:Assert_Equal(32, '686', s:print_any[2])
	call s:Assert_Equal(33, '686', s:print_any[3])
	call s:Assert_Equal(34, '0', s:print_any[4])

	let s:print_linage = s:demo.linage[s:print_num]
	call s:Assert_Equal(35,
		\ s:demo.text[(s:print_cursor + s:print_num) :
			\ (s:print_cursor + s:print_num + s:print_linage.offset)],
		\ getbufline(s:print_linage.name,
			\ (len(getbufline(s:print_linage.name, 1, '$')) -
							\ s:print_linage.offset),
			\ '$'))
""	let s:print_num += 1
""	let s:print_cursor += s:print_linage.offset
finally
	let @z = s:demo.reg_z
	let &g:statusline = s:demo.state.statusline
	let &equalalways = s:demo.state.equalalways
	let &rulerformat = s:demo.state.rulerformat
	let &ruler = s:demo.state.ruler
	let &maxfuncdepth = s:demo.state.maxfuncdepth
	let &laststatus = s:demo.state.laststatus
	let s:print_switchbuf = &switchbuf

	try
		setglobal switchbuf=useopen
		execute 'sbuffer ' .. s:demo.state.buffer
	catch	/.*/
		call s:Err_Msg(s:demo, v:exception)
	finally
		let &switchbuf = s:print_switchbuf
	endtry

	" Allow for re-sourcing.
	if has('autocmd') && &eventignore !~? '\v%(all|sourcepre)'
		augroup demo
			autocmd! demo
			autocmd SourcePre	<buffer> only
		augroup END
	else
		only
	endif
endtry

let &cpoptions = s:cpoptions
unlet s:cpoptions
quitall
"""""""""""""""""""""""""""""""""""""|EOF|""""""""""""""""""""""""""""""""""""
