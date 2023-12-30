" Description:	A profiling routine for the "assign" runners (Vim 7.0)
" Author:	Aliaksei Budavei (0x000c70 AT gmail DOT com)
" Version:	1.0
" Last Change:	2023-Sep-17
" Copyleft ())
"
" Dependencies:	eval and profile features.
"
" Usage:	Change the directory to this file's location and open the file
"		in Vim and source it to commence profiling that shall generate
"		a file assign-vim_version-localtime.vim populated with collected
"		data.  E.g. (8+ minutes for the 286-character /etc/motd):
"
"		time for i in {0..3}; do \
"			ASSIGN_PROFILE_LR_THEN_TB=1 \
"			ASSIGN_PROFILE_ITERATIONS=2 \
"			ASSIGN_PROFILE_LINE_COUNT=4 \
"			ASSIGN_PROFILE_FILENAME=/etc/motd \
"				vim -i NONE \
"					-U NONE \
"					-u \$VIMRUNTIME/vimrc_example.vim \
"					+set\ directory=/tmp \
"					+source\ % \
"					profiler.vim; \
"		done
"
" Notes:	Each runner can be stopped in the tracks by hitting Ctrl-c.

let s:cpoptions = &cpoptions
set cpoptions-=C					" Join line-breaks.

if !(has('profile') && filereadable('left-right/assign.vim') &&
					\ filereadable('top-bottom/assign.vim'))
	let &cpoptions = s:cpoptions
	unlet s:cpoptions
	finish
endif

try
	let s:fname = $ASSIGN_PROFILE_FILENAME
	let s:fname = empty(s:fname) ? '../../../README.md' : s:fname

	if !filereadable(s:fname)
		echomsg '`'.s:fname."': No such file"
		finish
	endif

	let s:lines = str2nr($ASSIGN_PROFILE_LINE_COUNT)
	let s:times = str2nr($ASSIGN_PROFILE_ITERATIONS)
	let s:delay = str2nr($ASSIGN_PROFILE_MILLISEC_DELAY)
	let s:args = [s:fname,
		\ s:lines < 1 || s:lines > 4096 ? 1024 : s:lines,
		\ s:times < 1 || s:times > 1024 ? 1 : s:times,
		\ s:delay < 50 || s:delay > 300 ? '160m' : s:delay.'m']
	let s:dirs = split(&directory, ',')
	execute printf('profile start %s/assign-%s-%s.vim',
					\ empty(s:dirs) ? '.' : s:dirs[0],
					\ v:version,
					\ localtime())
	profile func *Eval[01]

	if !empty($ASSIGN_PROFILE_LR_THEN_TB)
		source left-right/assign.vim
		call call('Assign_Runner_LR_7_0', s:args)
		source top-bottom/assign.vim
		call call('Assign_Runner_TB_7_0', s:args)
	else
		source top-bottom/assign.vim
		call call('Assign_Runner_TB_7_0', s:args)
		source left-right/assign.vim
		call call('Assign_Runner_LR_7_0', s:args)
	endif
finally
	let &cpoptions = s:cpoptions
	unlet! s:dirs s:args s:delay s:times s:lines s:fname s:cpoptions
endtry

quitall

" vim:fdm=marker:sw=8:ts=8:noet:nolist:nosta:
