""""""""""""""""""""""""""""""""""|load.vim|""""""""""""""""""""""""""""""""""
let s:cpoptions = &cpoptions
set cpoptions-=C					" Join line-breaks.

let s:pace.dump = {'0': [[0, 0, 0, 0]]}
silent! autocmd! pace
call s:Assert_True(1, s:pace.load == 0)

let s:load_event = &eventignore !~?
		\ '\v%(all|insert%(enter|change|leave)|cursor%(hold|moved)i)'
call s:Assert_Equal(1, &eventignore, s:load_event ? &eventignore : '')
let s:load_on_1 = s:Pace_Load(1)
call s:Assert_True(2, exists('#pace#InsertEnter#*'))
let s:load_on_2 = s:Pace_Load(1)
call s:Assert_True(3, exists('#pace#InsertEnter#*'))
call s:Assert_Not_Equal(1, s:load_on_1, s:load_on_2)

let s:load_off_1 = s:Pace_Load(0)
call s:Assert_True(4, !exists('#pace#InsertEnter#*'))
let s:load_off_2 = s:Pace_Load(0)
call s:Assert_True(5, !exists('#pace#InsertEnter#*'))
call s:Assert_Not_Equal(2, s:load_off_1, s:load_off_2)

let s:load_mode = s:mockup.mode
call s:Assert_Not_Equal(3, 'i', s:mockup.mode)
let s:load_on_3 = s:Pace_Load(1)

try
	let s:mockup.mode = 'i'
	let s:load_off_3 = s:Pace_Load(0)
	call s:Assert_Not_Equal(4, s:load_off_1, s:load_off_3)
	call s:Assert_True(6, exists('#pace#InsertEnter#*'))
finally
	let s:mockup.mode = s:load_mode
endtry

let s:load_ignore = &eventignore
let s:load_off_4 = s:Pace_Load(0)

try
	for s:load_name in ['all', 'CursorHoldI', 'CursorMovedI',
			\ 'InsertEnter', 'InsertChange', 'InsertLeave']
		let &eventignore = s:load_name
		let s:load_on_n = s:Pace_Load(1)
		call s:Assert_Not_Equal(5, s:load_on_1, s:load_on_n)
		call s:Assert_True(7, !exists('#pace#InsertEnter#*'))
	endfor
finally
	let &eventignore = s:load_ignore
	let s:load_event = &eventignore !~?
		\ '\v%(all|insert%(enter|change|leave)|cursor%(hold|moved)i)'
	call s:Assert_Equal(2, &eventignore, s:load_event ? &eventignore : '')
endtry

try
	unlet! g:pace_sample
	call s:Assert_True(8, s:pace.sample.in < s:pace.sample.below)

	let s:pace.sample.in = s:pace.sample.below - 1
	let s:load_on_n = s:Pace_Load(1)
	call s:Assert_Not_Equal(6, &updatetime, s:pace.sample.in)
	let s:load_off_n = s:Pace_Load(0)

	let s:pace.sample.in = s:pace.sample.above + 1
	let s:load_on_n = s:Pace_Load(1)
	call s:Assert_Not_Equal(7, &updatetime, s:pace.sample.in)
	let s:load_off_n = s:Pace_Load(0)

	let s:pace.sample.in = s:pace.sample.below
	let s:load_on_n = s:Pace_Load(1)
	call s:Assert_Equal(3, &updatetime, s:pace.sample.in)
	let s:load_off_n = s:Pace_Load(0)

	let s:pace.sample.in = s:pace.sample.above
	let s:load_on_n = s:Pace_Load(1)
	call s:Assert_Equal(4, &updatetime, s:pace.sample.in)
	let s:load_off_n = s:Pace_Load(0)

	let s:pace.sample.in = s:pace.sample.above - s:pace.sample.below
	let s:load_on_n = s:Pace_Load(1)
	call s:Assert_Equal(5, &updatetime, s:pace.sample.in)
	let s:load_off_n = s:Pace_Load(0)
finally
	let &updatetime = s:pace.state.updatetime
endtry

let &cpoptions = s:cpoptions
unlet s:cpoptions
quit
"""""""""""""""""""""""""""""""""""""|EOF|""""""""""""""""""""""""""""""""""""
