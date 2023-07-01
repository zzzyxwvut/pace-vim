" Description:	A profiling routine for the "eval*" runners (Vim 7.0)
" Author:	Aliaksei Budavei (0x000c70 AT gmail DOT com)
" Version:	1.0
" Last Change:	2023-Jul-01
" Copyleft ())
"
" Dependencies:	eval and profile features.
"
" Usage:	Change the directory to this file's location and open the file
"		in Vim and source it to commence profiling that shall generate
"		a file eval-vim_version-localtime.vim populated with collected
"		data, e.g. (8+ minutes):
"
"		time for i in {0..3}; do \
"			EVAL_PROFILE_LR_THEN_TB=1 \
"			EVAL_PROFILE_ITERATIONS=2 \
"			EVAL_PROFILE_LINE_COUNT=4 \
"			EVAL_PROFILE_FILENAME=/etc/motd \
"				vim -i NONE \
"					-U NONE \
"					-u \$VIMRUNTIME/vimrc_example.vim \
"					+set\ directory=/tmp \
"					+so\ % \
"					profiler.vim; \
"		done
"
" Notes:	Each runner can be stopped in the tracks by hitting Ctrl-c.

let s:cpoptions = &cpoptions
set cpoptions-=C					" Join line-breaks.

if !(has('profile') && filereadable('left-right/eval.vim') &&
					\ filereadable('top-bottom/eval.vim'))
	let &cpoptions = s:cpoptions
	unlet s:cpoptions
	finish
endif

try
	let s:fname = $EVAL_PROFILE_FILENAME
	let s:fname = empty(s:fname) ? '../../../../demo/vimvat.txt' : s:fname

	if !filereadable(s:fname)
		echomsg '`'.s:fname."': No such file"
		let &cpoptions = s:cpoptions
		unlet s:fname s:cpoptions
		finish
	endif

	" Define EVAL_PROFILE_LINE_COUNT when the line count for the file is
	" greater than 1024 and less than 4096.
	let s:lines = $EVAL_PROFILE_LINE_COUNT
	let s:times = $EVAL_PROFILE_ITERATIONS
	let s:args = empty(s:lines)
		\ ? [str2nr(s:times), s:fname]
		\ : [str2nr(s:times), s:fname, str2nr(s:lines)]
	let s:dirs = split(&directory, ',')
	execute printf('profile start %s/eval-%s-%s.vim',
					\ empty(s:dirs) ? '.' : s:dirs[0],
					\ v:version,
					\ localtime())
	profile func *Eval[01]

	if !empty($EVAL_PROFILE_LR_THEN_TB)
		source left-right/eval.vim
		call call('Eval_Runner_LR_7_0', s:args)
		source top-bottom/eval.vim
		call call('Eval_Runner_TB_7_0', s:args)
	else
		source top-bottom/eval.vim
		call call('Eval_Runner_TB_7_0', s:args)
		source left-right/eval.vim
		call call('Eval_Runner_LR_7_0', s:args)
	endif
finally
	let &cpoptions = s:cpoptions
	unlet! s:dirs s:args s:times s:lines s:fname s:cpoptions
endtry

quitall

" vim:fdm=marker:sw=8:ts=8:noet:nolist:nosta:
