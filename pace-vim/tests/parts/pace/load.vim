##################################|load.vim|##################################
pace.dump = {'0': [[0, 0, 0, 0]]}
var load_on_n: number
var load_off_n: number
silent! autocmd! pace
Assert_True(1, !pace.load)
var load_event: bool = &eventignore !~?
		'\v%(all|insert%(enter|change|leave)|cursor%(hold|moved)i)'
Assert_Equal(1, &eventignore, load_event ? &eventignore : '')
const load_on_1: number = Pace_Load(1)
Assert_True(2, exists('#pace#InsertEnter#*'))
const load_on_2: number = Pace_Load(1)
Assert_True(3, exists('#pace#InsertEnter#*'))
Assert_Not_Equal(1, load_on_1, load_on_2)

const load_off_1: number = Pace_Load(0)
Assert_True(4, !exists('#pace#InsertEnter#*'))
const load_off_2: number = Pace_Load(0)
Assert_True(5, !exists('#pace#InsertEnter#*'))
Assert_Not_Equal(2, load_off_1, load_off_2)

const load_mode: string = mockup.mode
Assert_Not_Equal(3, 'i', mockup.mode)
const load_on_3: number = Pace_Load(1)

try
	mockup.mode = 'i'
	const load_off_3: number = Pace_Load(0)
	Assert_Not_Equal(4, load_off_1, load_off_3)
	Assert_True(6, exists('#pace#InsertEnter#*'))
finally
	mockup.mode = load_mode
endtry

const load_ignore: string = &eventignore
const load_off_4: number = Pace_Load(0)

try
	for load_name in ['all', 'CursorHoldI', 'CursorMovedI',
				'InsertEnter', 'InsertChange', 'InsertLeave']
		&eventignore = load_name
		load_on_n = Pace_Load(1)
		Assert_Not_Equal(5, load_on_1, load_on_n)
		Assert_True(7, !exists('#pace#InsertEnter#*'))
	endfor
finally
	&eventignore = load_ignore
	load_event = &eventignore !~?
		'\v%(all|insert%(enter|change|leave)|cursor%(hold|moved)i)'
	Assert_Equal(2, &eventignore, load_event ? &eventignore : '')
endtry

try
	unlet! g:pace_sample
	Assert_True(8, pace.sample.in < pace.sample.below)

	pace.sample.in = pace.sample.below - 1
	load_on_n = Pace_Load(1)
	Assert_Not_Equal(6, &updatetime, pace.sample.in)
	load_off_n = Pace_Load(0)

	pace.sample.in = pace.sample.above + 1
	load_on_n = Pace_Load(1)
	Assert_Not_Equal(7, &updatetime, pace.sample.in)
	load_off_n = Pace_Load(0)

	pace.sample.in = pace.sample.below
	load_on_n = Pace_Load(1)
	Assert_Equal(3, &updatetime, pace.sample.in)
	load_off_n = Pace_Load(0)

	pace.sample.in = pace.sample.above
	load_on_n = Pace_Load(1)
	Assert_Equal(4, &updatetime, pace.sample.in)
	load_off_n = Pace_Load(0)

	pace.sample.in = pace.sample.above - pace.sample.below
	load_on_n = Pace_Load(1)
	Assert_Equal(5, &updatetime, pace.sample.in)
	load_off_n = Pace_Load(0)
finally
	&updatetime = pace.state.updatetime
endtry

quit
#####################################|EOF|####################################
