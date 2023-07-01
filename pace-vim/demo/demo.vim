" Description:	The demo-imitation of the "pace.vim" script
" Author:	Aliaksei Budavei (0x000c70 AT gmail DOT com)
" Repository:	https://github.com/zzzyxwvut/pace-vim/tree/vim/7/0/master
" Bundles:	https://www.vim.org/scripts/script.php?script_id=5472
" Version:	1.2
" Last Change:	2023-Jun-29
" Copyleft ())
"
" Dependencies:	cmdline_info, eval, reltime, and statusline features.
"
"		The "vimvat.txt" sonnet included.
"
" Usage:	Source the file: ":lcd %:p:h | so %".
"
" Notes:	In order to preview any other file, change values of the keys
"		of s:demo.data dictionary's dictionary.  (Read the innermost
"		list elements of the value of s:demo.data.part as follows:
"		seek the leftmost 'line_match' as regexp at the accumulated
"		'line_offset' and print the line and its current 'line_offset'
"		lines that follow; otherwise print a null line.  The value of
"		s:demo.data.turn must equal the number of s:demo.data.part
"		list elements less one.)
"
"		In order to adjust the typing pace, vary s:demo.delay values.
"
" Caveats:	The "winheight" option is set to 1.

let s:cpoptions	= &cpoptions						" {{{1
set cpoptions-=C					" Join line-breaks.

if !(has('reltime') && has('cmdline_info') && has('statusline') &&
							\ len(reltime()) == 2)
	let &cpoptions	= s:cpoptions
	unlet s:cpoptions
	finish
endif

let s:demo	= {
	\ 'char':	0,
	\ 'sec':	0,
	\ 'gear':	4,
	\ 'microf':	printf('%%0%ii', len(reltime([0, 0], [0, -1])[1])),
	\ 'reg_z':	@z,
	\ 'handle':	expand('<sfile>'),
	\ 'begin':	reltime(),
	\ 'break':	reltime(),
	\ 'file':	[],
	\ 'delay':	[70, 90, 80, 60],
	\ 'state':	{
		\ 'buffer':		bufnr('%'),
		\ 'laststatus':		&laststatus,
		\ 'maxfuncdepth':	&maxfuncdepth,
		\ 'ruler':		&ruler,
		\ 'rulerformat':	&rulerformat,
		\ 'winheight':		&winheight,
		\ 'equalalways':	&equalalways,
		\ 'statusline':		&g:statusline,
	\ },
	\ 'data':	{
		\ 'fname':	'vimvat.txt',
		\ 'cols':	50,
		\ 'lines':	20,
		\ 'turn':	3,
		\ 'part':	[
			\ ['1st\ quatrain',	'^Of _vim_',		3],
			\ ['2nd\ quatrain',	'^Mnem0nic\$',		3],
			\ ['3rd\ quatrain',	'^No pop-ups',		3],
			\ ['the\ couplet',	'^Go to,',		1],
		\ ],
	\ },
\ }			" [ buffer_name, line_match, line_offset ]

function! s:demo.eval1() abort						" {{{1
	let l:tick	= reltime(l:self.break) + reltime(l:self.begin)
	let [l:self.char, l:self.sec]	= [(l:self.char + 1), l:tick[2]]
	let g:demo_info			= printf('%-9s %2i, %7i, %5i',
		\ l:tick[0].('.'.printf(l:self.microf, l:tick[1]))[:2].',',
		\ (l:self.char / l:self.sec),
		\ l:self.char,
		\ l:self.sec)
	let l:self.break		= reltime()
endfunction

function! s:demo.eval0() abort						" {{{1
	let l:tick	= reltime(l:self.break) + reltime(l:self.begin)
	let [l:self.char, l:self.sec]	= [(l:self.char + 1), l:tick[2]]
	let g:demo_info			= printf('%-9s %2i, %7i, %5i',
		\ l:tick[0].('.'.printf(l:self.microf, l:tick[1]))[:2].',',
		\ (l:self.sec != 0 ?
			\ l:self.char / l:self.sec :
			\ l:self.char),
		\ l:self.char,
		\ l:self.sec)
	let l:self.break		= reltime()
endfunction

function! s:demo.print(i, j, name, lines) abort				" {{{1
	if a:lines < 1
		return
	endif

	execute 'noautocmd belowright keepalt keepjumps '.a:lines.'new +setlocal
		\\ bufhidden=hide\ buftype=nofile\ foldcolumn&\ nobuflisted\ noswapfile
		\\ statusline=%<%f\\\ %h%m%r%=[%{g:demo_info}]\\\ %-14.14(%l,%c%V%)\\\ %P
		\\ textwidth=0\ winheight&\ winfixheight\ noequalalways +'.a:name.'+'

	if !&l:modifiable
		setlocal modifiable
	endif

	if &l:readonly
		setlocal noreadonly
	endif

	if join(getbufline('%', 1, a:lines), '') != ''
		" Add some empty lines at the buffer end and set cursor there.
		call map(range(a:lines), "setline(line('$') + 1, '')")
		normal! G
	endif

	try
		if a:i < 0 || a:j < 0 || a:i > a:j
			return
		endif

		let l:a		= split(join(l:self.file[a:i : a:j], "\n"), '\zs')
		let l:z		= len(l:a)
		lockvar l:a l:z
		let l:k		= localtime() % l:self.gear	" Seed [0-3].
		let l:n		= 0

		while l:self.sec < 1 && l:n < l:z
			let @z	= l:a[l:n]
			normal! "zp
			call l:self.eval0()
			execute "sleep ".l:self.delay[l:k % l:self.gear]."m"
			redrawstatus
			let l:k	+= 1
			let l:n	+= 1
		endwhile

		sleep 60m

		while l:n < l:z
			let @z	= l:a[l:n]
			normal! "zp
			call l:self.eval1()
			execute "sleep ".l:self.delay[l:k % l:self.gear]."m"
			redrawstatus
			let l:k	+= 1
			let l:n	+= 1
		endwhile
	finally
		if l:self.data.turn
			call setbufvar(bufnr('%'), '&statusline', '')
			normal! gg
		endif

		setlocal nomodifiable
		redraw!
	endtry
endfunction

function! s:demo.run() abort						" {{{1
	let [l:z, l:n, l:m]			= [len(l:self.file), 0, 0]
	let [l:self.break, l:self.begin]	= [reltime(), reltime()]

	for [l:name, l:match, l:offset] in l:self.data.part
		while l:n < l:z && l:self.file[l:n] !~# l:match
			let l:n	+= 1
		endwhile

		let [l:m, l:p]	= l:n < l:z ? [l:n, l:n] : [l:m, -1]
		call l:self.print(l:p, l:p + l:offset, l:name, l:offset + 1)
		let l:n		= l:m + l:offset + 1
		let l:self.data.turn	-= 1
	endfor
endfunction

function! s:demo.errmsg(entry) abort					" {{{1
	echohl ErrorMsg| echomsg l:self.handle.': '.a:entry| echohl None
endfunction

try									" {{{1
	if !&g:modifiable || &g:readonly
		throw 1024
	elseif !filereadable(s:demo.data.fname)
		throw 2048
	endif

	let s:demo.file		= readfile(s:demo.data.fname, '', s:demo.data.lines)
	lockvar s:demo.file
	let s:demo.data.cols	= max(map(s:demo.file[:], 'len(v:val)'))

	if len(s:demo.file) < s:demo.data.lines
		throw 4096
	elseif winwidth(0) < s:demo.data.cols
		throw 8192
	endif

	if has('autocmd') && &eventignore !~? '\v%(all|vimresized)'
		augroup demo
			autocmd! demo
			autocmd VimResized	* redraw!
		augroup END
	endif

	setglobal maxfuncdepth& rulerformat& ruler
	setglobal statusline=%<%f\ %h%m%r%=%-14.14(%l,%c%V%)\ %P
	unlet! g:demo_info
	let g:demo_info	= printf('%-9s %2i, %7i, %5i', '0.00,', 0, 0, 0)
	let s:demo.gear		= len(s:demo.delay)
	let s:demo.data.turn	= len(s:demo.data.part) - 1

	if !&laststatus
		set laststatus&
	endif

	if winnr('$') > 1
		only
	endif

	redraw!
	call s:demo.run()
catch	/\<1024\>/
	call s:demo.errmsg("Cannot make changes")
catch	/\<2048\>/
	call s:demo.errmsg('`'.s:demo.data.fname."': No such file")
catch	/\<4096\>/
	call s:demo.errmsg('`'.s:demo.data.fname
		\ ."': Invalid line count: ".len(s:demo.file)." < "
					\ .s:demo.data.lines)
catch	/\<8192\>/
	call s:demo.errmsg("Narrow width: ".winwidth(0)." < "
					\ .s:demo.data.cols)
catch	/^Vim:Interrupt$/	" Silence this error message.
finally
	let @z			= s:demo.reg_z
	let &g:statusline	= s:demo.state.statusline
	let &equalalways	= s:demo.state.equalalways
"	let &winheight		= s:demo.state.winheight
	let &rulerformat	= s:demo.state.rulerformat
	let &ruler		= s:demo.state.ruler
	let &maxfuncdepth	= s:demo.state.maxfuncdepth
	let &laststatus		= s:demo.state.laststatus
	let &cpoptions		= s:cpoptions
	let s:switchbuf		= &switchbuf

	try
		setglobal switchbuf=useopen
		execute 'sbuffer '.s:demo.state.buffer
		lcd -
	catch	/.*/
		call s:demo.errmsg(v:exception)
	finally
		let &switchbuf	= s:switchbuf
	endtry

	unlet s:switchbuf s:demo s:cpoptions
	silent! autocmd! demo
	silent! augroup! demo
endtry									" }}}1

" vim:fdm=marker:sw=8:ts=8:noet:nolist:nosta:
