vim9script

# Description:	A _blob_ runner for the "Eval*" functions (Vim 9.0)
# Author:	Aliaksei Budavei (0x000c70 AT gmail DOT com)
# Version:	2.0
# Last Change:	2023-Sep-23
# Copyleft ())
#
# Dependencies:	cmdline_info, eval, reltime, and statusline features.
#
# Caveats:	The "winheight" option is set to 1.

if !(has('reltime') && has('cmdline_info') && has('statusline') &&
							v:numbersize == 64)
	finish
endif

var runner: dict<any> = {handle: expand('<script>'), reg_z: @z, text: []}

# Try to roll over the sub-second unit (see profile_sub() of profile.c).
const parts: number = len(reltime()) == 2
	? reduce([reltime([0, 0], [0, -1])],
		(_: number, v: list<number>): number =>
					v[0] == -1 && string(v[1]) =~ '^9\+$'
			? strlen(v[1])
			: 0,
		0)
	: 0

if parts != 6 && parts != 9 && reltimestr(reltime())[-7 : -7] != '.'
	throw 'My mind is going...'
endif

if parts == 6

def Eval1(store: dict<any>, Blob2Nr_: func(blob): number,
						Nr2Blob_: func(number): blob)
	const tick: list<number> = reltime(store.a)
	const go: blob = store.b
	const c: number = Blob2Nr_(go[8 : 15]) + tick[1]
	const [b: number, d: number] = [(Blob2Nr_(go[0 : 7]) + tick[0] +
							c / 1000000),
					(Blob2Nr_(go[16 : 23]) + 1)]
	store.b = Nr2Blob_(b) + Nr2Blob_(c % 1000000) + Nr2Blob_(d)
	g:runner_info = printf('%-9s %2i, %7i, %5i',
			tick[0] .. (printf('.%06i', tick[1]))[: 2] .. ',',
			(d / b),
			d,
			b)
	store.a = reltime()
enddef

def Eval0(store: dict<any>, Blob2Nr_: func(blob): number,
						Nr2Blob_: func(number): blob)
	const tick: list<number> = reltime(store.a)
	const go: blob = store.b
	const c: number = Blob2Nr_(go[8 : 15]) + tick[1]
	const [b: number, d: number] = [(Blob2Nr_(go[0 : 7]) + tick[0] +
							c / 1000000),
					(Blob2Nr_(go[16 : 23]) + 1)]
	store.b = Nr2Blob_(b) + Nr2Blob_(c % 1000000) + Nr2Blob_(d)
	g:runner_info = printf('%-9s %2i, %7i, %5i',
			tick[0] .. (printf('.%06i', tick[1]))[: 2] .. ',',
			b != 0
				? (d / b)
				: d,
			d,
			b)
	store.a = reltime()
enddef

elseif parts == 9

def Eval1(store: dict<any>, Blob2Nr_: func(blob): number,
						Nr2Blob_: func(number): blob)
	const tick: list<number> = reltime(store.a)
	const go: blob = store.b
	const c: number = Blob2Nr_(go[8 : 15]) + tick[1]
	const [b: number, d: number] = [(Blob2Nr_(go[0 : 7]) + tick[0] +
							c / 1000000000),
					(Blob2Nr_(go[16 : 23]) + 1)]
	store.b = Nr2Blob_(b) + Nr2Blob_(c % 1000000000) + Nr2Blob_(d)
	g:runner_info = printf('%-9s %2i, %7i, %5i',
			tick[0] .. (printf('.%09i', tick[1]))[: 2] .. ',',
			(d / b),
			d,
			b)
	store.a = reltime()
enddef

def Eval0(store: dict<any>, Blob2Nr_: func(blob): number,
						Nr2Blob_: func(number): blob)
	const tick: list<number> = reltime(store.a)
	const go: blob = store.b
	const c: number = Blob2Nr_(go[8 : 15]) + tick[1]
	const [b: number, d: number] = [(Blob2Nr_(go[0 : 7]) + tick[0] +
							c / 1000000000),
					(Blob2Nr_(go[16 : 23]) + 1)]
	store.b = Nr2Blob_(b) + Nr2Blob_(c % 1000000000) + Nr2Blob_(d)
	g:runner_info = printf('%-9s %2i, %7i, %5i',
			tick[0] .. (printf('.%09i', tick[1]))[: 2] .. ',',
			b != 0
				? (d / b)
				: d,
			d,
			b)
	store.a = reltime()
enddef

else

# The 1e+06 constants rely on 1e-06 seconds obtainable from reltimestr().

def Eval1(store: dict<any>, Blob2Nr_: func(blob): number,
						Nr2Blob_: func(number): blob)
	const unit: string = reltimestr(reltime(store.a))
	const go: blob = store.b
	const c: number = Blob2Nr_(go[8 : 15]) + str2nr(unit[-6 :])
	const [b: number, d: number] = [(Blob2Nr_(go[0 : 7]) + str2nr(unit) +
							c / 1000000),
					(Blob2Nr_(go[16 : 23]) + 1)]
	store.b = Nr2Blob_(b) + Nr2Blob_(c % 1000000) + Nr2Blob_(d)
	g:runner_info = printf('%-9s %2i, %7i, %5i',
			trim(unit)[: -5] .. ',',
			(d / b),
			d,
			b)
	store.a = reltime()
enddef

def Eval0(store: dict<any>, Blob2Nr_: func(blob): number,
						Nr2Blob_: func(number): blob)
	const unit: string = reltimestr(reltime(store.a))
	const go: blob = store.b
	const c: number = Blob2Nr_(go[8 : 15]) + str2nr(unit[-6 :])
	const [b: number, d: number] = [(Blob2Nr_(go[0 : 7]) + str2nr(unit) +
							c / 1000000),
					(Blob2Nr_(go[16 : 23]) + 1)]
	store.b = Nr2Blob_(b) + Nr2Blob_(c % 1000000) + Nr2Blob_(d)
	g:runner_info = printf('%-9s %2i, %7i, %5i',
			trim(unit)[: -5] .. ',',
			b != 0
				? (d / b)
				: d,
			d,
			b)
	store.a = reltime()
enddef

endif

# { \
# printf "\n\t\   '0': '00', "; \
# for i in {1..255}; do \
#	if test $(($i & 3)) -eq 0; then \
#		printf '\n\t\ '; \
#	fi; \
#	printf '%13s' "$(printf "'%i': '%02x', " $i $i)"; \
# done; \
# printf '\n'; \
# } > /tmp/bytes_d
def Nr2BlobLookupDict(): func(number): blob
	return ((hh: dict<string>) => (n: number): blob => {
		return eval('0z' ..
				hh[and(0xff, (n >> 56))] ..
				hh[and(0xff, (n >> 48))] ..
				hh[and(0xff, (n >> 40))] ..
				hh[and(0xff, (n >> 32))] ..
				hh[and(0xff, (n >> 24))] ..
				hh[and(0xff, (n >> 16))] ..
				hh[and(0xff, (n >>  8))] ..
				hh[and(0xff, n)])
	})({'0': '00',   '1': '01',   '2': '02',   '3': '03',
	  '4': '04',   '5': '05',   '6': '06',   '7': '07',
	  '8': '08',   '9': '09',  '10': '0a',  '11': '0b',
	 '12': '0c',  '13': '0d',  '14': '0e',  '15': '0f',
	 '16': '10',  '17': '11',  '18': '12',  '19': '13',
	 '20': '14',  '21': '15',  '22': '16',  '23': '17',
	 '24': '18',  '25': '19',  '26': '1a',  '27': '1b',
	 '28': '1c',  '29': '1d',  '30': '1e',  '31': '1f',
	 '32': '20',  '33': '21',  '34': '22',  '35': '23',
	 '36': '24',  '37': '25',  '38': '26',  '39': '27',
	 '40': '28',  '41': '29',  '42': '2a',  '43': '2b',
	 '44': '2c',  '45': '2d',  '46': '2e',  '47': '2f',
	 '48': '30',  '49': '31',  '50': '32',  '51': '33',
	 '52': '34',  '53': '35',  '54': '36',  '55': '37',
	 '56': '38',  '57': '39',  '58': '3a',  '59': '3b',
	 '60': '3c',  '61': '3d',  '62': '3e',  '63': '3f',
	 '64': '40',  '65': '41',  '66': '42',  '67': '43',
	 '68': '44',  '69': '45',  '70': '46',  '71': '47',
	 '72': '48',  '73': '49',  '74': '4a',  '75': '4b',
	 '76': '4c',  '77': '4d',  '78': '4e',  '79': '4f',
	 '80': '50',  '81': '51',  '82': '52',  '83': '53',
	 '84': '54',  '85': '55',  '86': '56',  '87': '57',
	 '88': '58',  '89': '59',  '90': '5a',  '91': '5b',
	 '92': '5c',  '93': '5d',  '94': '5e',  '95': '5f',
	 '96': '60',  '97': '61',  '98': '62',  '99': '63',
	'100': '64', '101': '65', '102': '66', '103': '67',
	'104': '68', '105': '69', '106': '6a', '107': '6b',
	'108': '6c', '109': '6d', '110': '6e', '111': '6f',
	'112': '70', '113': '71', '114': '72', '115': '73',
	'116': '74', '117': '75', '118': '76', '119': '77',
	'120': '78', '121': '79', '122': '7a', '123': '7b',
	'124': '7c', '125': '7d', '126': '7e', '127': '7f',
	'128': '80', '129': '81', '130': '82', '131': '83',
	'132': '84', '133': '85', '134': '86', '135': '87',
	'136': '88', '137': '89', '138': '8a', '139': '8b',
	'140': '8c', '141': '8d', '142': '8e', '143': '8f',
	'144': '90', '145': '91', '146': '92', '147': '93',
	'148': '94', '149': '95', '150': '96', '151': '97',
	'152': '98', '153': '99', '154': '9a', '155': '9b',
	'156': '9c', '157': '9d', '158': '9e', '159': '9f',
	'160': 'a0', '161': 'a1', '162': 'a2', '163': 'a3',
	'164': 'a4', '165': 'a5', '166': 'a6', '167': 'a7',
	'168': 'a8', '169': 'a9', '170': 'aa', '171': 'ab',
	'172': 'ac', '173': 'ad', '174': 'ae', '175': 'af',
	'176': 'b0', '177': 'b1', '178': 'b2', '179': 'b3',
	'180': 'b4', '181': 'b5', '182': 'b6', '183': 'b7',
	'184': 'b8', '185': 'b9', '186': 'ba', '187': 'bb',
	'188': 'bc', '189': 'bd', '190': 'be', '191': 'bf',
	'192': 'c0', '193': 'c1', '194': 'c2', '195': 'c3',
	'196': 'c4', '197': 'c5', '198': 'c6', '199': 'c7',
	'200': 'c8', '201': 'c9', '202': 'ca', '203': 'cb',
	'204': 'cc', '205': 'cd', '206': 'ce', '207': 'cf',
	'208': 'd0', '209': 'd1', '210': 'd2', '211': 'd3',
	'212': 'd4', '213': 'd5', '214': 'd6', '215': 'd7',
	'216': 'd8', '217': 'd9', '218': 'da', '219': 'db',
	'220': 'dc', '221': 'dd', '222': 'de', '223': 'df',
	'224': 'e0', '225': 'e1', '226': 'e2', '227': 'e3',
	'228': 'e4', '229': 'e5', '230': 'e6', '231': 'e7',
	'232': 'e8', '233': 'e9', '234': 'ea', '235': 'eb',
	'236': 'ec', '237': 'ed', '238': 'ee', '239': 'ef',
	'240': 'f0', '241': 'f1', '242': 'f2', '243': 'f3',
	'244': 'f4', '245': 'f5', '246': 'f6', '247': 'f7',
	'248': 'f8', '249': 'f9', '250': 'fa', '251': 'fb',
	'252': 'fc', '253': 'fd', '254': 'fe', '255': 'ff'})
enddef

# { \
# printf "\n\t\ '00', "; \
# for i in {1..255}; do \
#	if test $(($i & 7)) -eq 0; then \
#		printf '\n\t\ '; \
#	fi; \
#	printf "'%02x', " $i; \
# done; \
# printf '\n'; \
# } > /tmp/bytes_l
def Nr2BlobLookupList(): func(number): blob
	return ((hh: list<string>) => (n: number): blob => {
		return eval('0z' ..
				hh[and(0xff, (n >> 56))] ..
				hh[and(0xff, (n >> 48))] ..
				hh[and(0xff, (n >> 40))] ..
				hh[and(0xff, (n >> 32))] ..
				hh[and(0xff, (n >> 24))] ..
				hh[and(0xff, (n >> 16))] ..
				hh[and(0xff, (n >>  8))] ..
				hh[and(0xff, n)])
	})(['00', '01', '02', '03', '04', '05', '06', '07',
	'08', '09', '0a', '0b', '0c', '0d', '0e', '0f',
	'10', '11', '12', '13', '14', '15', '16', '17',
	'18', '19', '1a', '1b', '1c', '1d', '1e', '1f',
	'20', '21', '22', '23', '24', '25', '26', '27',
	'28', '29', '2a', '2b', '2c', '2d', '2e', '2f',
	'30', '31', '32', '33', '34', '35', '36', '37',
	'38', '39', '3a', '3b', '3c', '3d', '3e', '3f',
	'40', '41', '42', '43', '44', '45', '46', '47',
	'48', '49', '4a', '4b', '4c', '4d', '4e', '4f',
	'50', '51', '52', '53', '54', '55', '56', '57',
	'58', '59', '5a', '5b', '5c', '5d', '5e', '5f',
	'60', '61', '62', '63', '64', '65', '66', '67',
	'68', '69', '6a', '6b', '6c', '6d', '6e', '6f',
	'70', '71', '72', '73', '74', '75', '76', '77',
	'78', '79', '7a', '7b', '7c', '7d', '7e', '7f',
	'80', '81', '82', '83', '84', '85', '86', '87',
	'88', '89', '8a', '8b', '8c', '8d', '8e', '8f',
	'90', '91', '92', '93', '94', '95', '96', '97',
	'98', '99', '9a', '9b', '9c', '9d', '9e', '9f',
	'a0', 'a1', 'a2', 'a3', 'a4', 'a5', 'a6', 'a7',
	'a8', 'a9', 'aa', 'ab', 'ac', 'ad', 'ae', 'af',
	'b0', 'b1', 'b2', 'b3', 'b4', 'b5', 'b6', 'b7',
	'b8', 'b9', 'ba', 'bb', 'bc', 'bd', 'be', 'bf',
	'c0', 'c1', 'c2', 'c3', 'c4', 'c5', 'c6', 'c7',
	'c8', 'c9', 'ca', 'cb', 'cc', 'cd', 'ce', 'cf',
	'd0', 'd1', 'd2', 'd3', 'd4', 'd5', 'd6', 'd7',
	'd8', 'd9', 'da', 'db', 'dc', 'dd', 'de', 'df',
	'e0', 'e1', 'e2', 'e3', 'e4', 'e5', 'e6', 'e7',
	'e8', 'e9', 'ea', 'eb', 'ec', 'ed', 'ee', 'ef',
	'f0', 'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7',
	'f8', 'f9', 'fa', 'fb', 'fc', 'fd', 'fe', 'ff'])
enddef

# { \
# for i in {0..255}; do \
#	printf '%02x' $i; \
# done; \
# printf '\n'; \
# } > /tmp/bytes_s
def Nr2BlobLookupString(): func(number): blob
	return ((hh: string) => (n: number): blob => {
		const [a, b, c, d, e, f, g, h] =
					[(and(0xff, (n >> 56)) << 1),
					(and(0xff, (n >> 48)) << 1),
					(and(0xff, (n >> 40)) << 1),
					(and(0xff, (n >> 32)) << 1),
					(and(0xff, (n >> 24)) << 1),
					(and(0xff, (n >> 16)) << 1),
					(and(0xff, (n >>  8)) << 1),
					(and(0xff, n) << 1)]
		return eval('0z' ..
				hh[a : (a + 1)] ..
				hh[b : (b + 1)] ..
				hh[c : (c + 1)] ..
				hh[d : (d + 1)] ..
				hh[e : (e + 1)] ..
				hh[f : (f + 1)] ..
				hh[g : (g + 1)] ..
				hh[h : (h + 1)])
	})( '000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff')
enddef

def Nr2BlobPrintf(): func(number): blob
	return (n: number): blob => {
		return eval(printf('0z%02x%02x%02x%02x%02x%02x%02x%02x',
					and(0xff, (n >> 56)),
					and(0xff, (n >> 48)),
					and(0xff, (n >> 40)),
					and(0xff, (n >> 32)),
					and(0xff, (n >> 24)),
					and(0xff, (n >> 16)),
					and(0xff, (n >>  8)),
					and(0xff, n)))
	}
enddef

def Blob2Nr(): func(blob): number
	return (b: blob): number => {
		return (and(0xff, b[0]) << 56) +
					(and(0xff, b[1]) << 48) +
					(and(0xff, b[2]) << 40) +
					(and(0xff, b[3]) << 32) +
					(and(0xff, b[4]) << 24) +
					(and(0xff, b[5]) << 16) +
					(and(0xff, b[6]) <<  8) +
					(and(0xff, b[7]))
	}
enddef

def Print(self: dict<any>, times: number, delay: string,
						Blob2Nr_: func(blob): number,
						Nr2Blob_: func(number): blob)
	noautocmd belowright keepalt keepjumps :16new +setlocal
		\\ bufhidden=hide\ buftype=nofile\ foldcolumn&\ nobuflisted\ noswapfile
		\\ statusline=%<%f\\\ %h%m%r%=[%{g:runner_info}]\\\ %-14.14(%l,%c%V%)\\\ %P
		\\ textwidth=0\ winheight&\ winfixheight\ noequalalways +access_runner+

	if !&l:modifiable
		setlocal modifiable
	endif

	if &l:readonly
		setlocal noreadonly
	endif

	try
		const cc: list<string> = split(join(self.text, "\n"), '\zs')
		const z: number = len(cc)

		for i in range(times)
			setline((line('$') + 1), '')
			normal! G
			var n: number = 0

			# (store.b is a blob.)
			# 00-07: seconds,
			# 08-15: micro- or nano-seconds,
			# 16-23: characters.
			var store: dict<any> = {
				b: (Nr2Blob_(0) + Nr2Blob_(0) + Nr2Blob_(0)),
				a: reltime()
			}

			while Blob2Nr_(store.b[0 : 7]) < 1 && n < z
				@z = cc[n]
				normal! "zp
				Eval0(store, Blob2Nr_, Nr2Blob_)
				execute 'sleep ' .. delay
				redrawstatus
				n += 1
			endwhile

			while n < z
				@z = cc[n]
				normal! "zp
				Eval1(store, Blob2Nr_, Nr2Blob_)
				execute 'sleep ' .. delay
				redrawstatus
				n += 1
			endwhile
		endfor
	finally
		setlocal nomodifiable
		redraw!
	endtry
enddef

def Err_Msg(self: dict<any>, entry: string)
	echohl ErrorMsg | echomsg self.handle .. ': ' .. entry | echohl None
enddef

def g:Access_Runner_BLOB_9_0(fname: string, lines: number,
					times: number, delay: string): number
	if runner == null_dict || mode() != 'n'
		return 0
	endif

	const buffer: number = bufnr('%')

	try
		if !&g:modifiable || &g:readonly
			throw 1024
		elseif !filereadable(fname)
			throw 2048
		endif

		runner.text = readfile(fname, '', lines)
		lockvar runner.text
		setglobal maxfuncdepth& rulerformat& ruler
		setglobal statusline=%<%f\ %h%m%r%=%-14.14(%l,%c%V%)\ %P
		unlet! g:runner_info
		g:runner_info = printf('%-9s %2i, %7i, %5i', '0.00,', 0, 0, 0)

		if !&laststatus
			set laststatus&
		endif

		if winnr('$') > 1
			only
		endif

		redraw!
		const strategy: string = $ACCESS_NR_2_BLOB_STRATEGY
		Print(runner,
				times,
				delay,
				Blob2Nr(),
				strategy =~? '\<string\>'
					? Nr2BlobLookupString()
					: strategy =~? '\<list\>'
						? Nr2BlobLookupList()
						: strategy =~? '\<dict\>'
							? Nr2BlobLookupDict()
							: Nr2BlobPrintf())
	catch	/\<1024\>/
		Err_Msg(runner, "Cannot make changes")
	catch	/\<2048\>/
		Err_Msg(runner, '`' .. fname
					.. "': No such file")
	catch	/^Vim:Interrupt$/	# Silence this error message.
	finally
		if runner == null_dict	# See Vim patch 9.0.1501 (issues/12245).
			return 1
		endif

		@z = runner.reg_z
		const switchbuf: string = &switchbuf

		try
			setglobal switchbuf=useopen
			execute 'sbuffer ' .. buffer
		catch	/.*/
			Err_Msg(runner, v:exception)
		finally
			&switchbuf = switchbuf
		endtry

		runner = null_dict
	endtry

	return 1
enddef

defcompile

# vim:fdm=syntax:sw=8:ts=8:noet:nolist:nosta:
