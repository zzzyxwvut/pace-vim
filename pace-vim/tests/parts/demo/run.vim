"""""""""""""""""""""""""""""""""""|run.vim|""""""""""""""""""""""""""""""""""
let s:cpoptions = &cpoptions
set cpoptions-=C					" Join line-breaks.

try
	call s:Assert_Not_Equal(1, 'i', s:mockup.mode)
	call s:Assert_Equal(1, 0, s:Get_Chars())
	call s:Assert_Equal(2, 0, s:Get_Secs())
	call s:Assert_True(1, exists('g:demo_info'))
	let s:run_any = matchlist(g:demo_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(3, '0.00', s:run_any[1])	" tick
	call s:Assert_Equal(4, '0', s:run_any[2])	" pace
	call s:Assert_Equal(5, '0', s:run_any[3])	" chars
	call s:Assert_Equal(6, '0', s:run_any[4])	" secs

	call s:demo.run(s:turn)

	call s:Assert_Equal(7, s:mockup.time.before, s:Get_Tick())
	call s:Assert_Equal(8, 686, s:Get_Chars())
	call s:Assert_Equal(9, 0, s:Get_Secs())
	call s:Assert_True(2, exists('g:demo_info'))
	let s:run_any = matchlist(g:demo_info,
				\ '\v(\d+\.\d\d),\s+(\d+),\s+(\d+),\s+(\d+)')
	call s:Assert_Equal(10, '0.00', s:run_any[1])
	call s:Assert_Equal(11, '686', s:run_any[2])
	call s:Assert_Equal(12, '686', s:run_any[3])
	call s:Assert_Equal(13, '0', s:run_any[4])

	let s:run_cursor = 1

	for s:run_num in [0, 1, 2, 3]
		let s:run_linage = s:demo.linage[s:run_num]
		call s:Assert_Equal(14,
			\ s:demo.text[(s:run_cursor + s:run_num) :
				\ (s:run_cursor + s:run_num + s:run_linage[2])],
			\ getbufline(s:run_linage[0],
				\ (len(getbufline(s:run_linage[0], 1, '$')) -
							\ s:run_linage[2]),
				\ '$'))
		let s:run_cursor += s:run_linage[2]
	endfor
finally
	let @z = s:demo.reg_z
	let &g:statusline = s:demo.state.statusline
	let &equalalways = s:demo.state.equalalways
	let &rulerformat = s:demo.state.rulerformat
	let &ruler = s:demo.state.ruler
	let &maxfuncdepth = s:demo.state.maxfuncdepth
	let &laststatus = s:demo.state.laststatus
	let s:run_switchbuf = &switchbuf

	try
		setglobal switchbuf=useopen
		execute 'sbuffer '.s:demo.state.buffer
	catch	/.*/
		call s:demo.errmsg(v:exception)
	finally
		let &switchbuf = s:run_switchbuf
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
