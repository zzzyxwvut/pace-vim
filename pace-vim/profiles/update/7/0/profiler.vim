" Description:	A profiling routine for the "update" runners (Vim 7.0)
" Author:	Aliaksei Budavei (0x000c70 AT gmail DOT com)
" Version:	1.0
" Last Change:	2023-Sep-17
" Copyleft ())
"
" Dependencies:	eval and profile features.
"
" Usage:	Change the directory to this file's location and open the file
"		in Vim and source it to commence profiling that shall generate
"		a file update-vim_version-localtime.vim populated with collected
"		data.  E.g. (8+ minutes for the 286-character /etc/motd):
"
"		time for i in {0..3}; do \
"			UPDATE_SAMPLE_RANGE=above \
"			UPDATE_PROFILE_MILLISEC_DELAY=160 \
"			UPDATE_PROFILE_C_THEN_S=1 \
"			UPDATE_PROFILE_ITERATIONS=2 \
"			UPDATE_PROFILE_LINE_COUNT=4 \
"			UPDATE_PROFILE_FILENAME=/etc/motd \
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

if !(has('profile') && filereadable('continue/update.vim') &&
					\ filereadable('sample/update.vim'))
	let &cpoptions = s:cpoptions
	unlet s:cpoptions
	finish
endif

try
	let s:fname = $UPDATE_PROFILE_FILENAME
	let s:fname = empty(s:fname) ? '../../../README.md' : s:fname

	if !filereadable(s:fname)
		echomsg '`'.s:fname."': No such file"
		finish
	endif

	let s:lines = str2nr($UPDATE_PROFILE_LINE_COUNT)
	let s:times = str2nr($UPDATE_PROFILE_ITERATIONS)
	let s:delay = str2nr($UPDATE_PROFILE_MILLISEC_DELAY)
	let s:args = [s:fname,
		\ s:lines < 1 || s:lines > 4096 ? 1024 : s:lines,
		\ s:times < 1 || s:times > 1024 ? 1 : s:times,
		\ s:delay < 50 || s:delay > 300 ? '160m' : s:delay.'m']
	let s:dirs = split(&directory, ',')
	execute printf('profile start %s/update-%s-%s.vim',
					\ empty(s:dirs) ? '.' : s:dirs[0],
					\ v:version,
					\ localtime())
	profile func *Eval[012]
	profile func *Record_*
	profile func *Sample[01]

	if !empty($UPDATE_PROFILE_C_THEN_S)
		source continue/update.vim
		call call('Update_Runner_C_7_0', s:args)
		source sample/update.vim
		call call('Update_Runner_S_7_0', s:args)
	else
		source sample/update.vim
		call call('Update_Runner_S_7_0', s:args)
		source continue/update.vim
		call call('Update_Runner_C_7_0', s:args)
	endif
finally
	let &cpoptions = s:cpoptions
	unlet! s:dirs s:args s:delay s:times s:lines s:fname s:cpoptions
endtry

quitall

" vim:fdm=marker:sw=8:ts=8:noet:nolist:nosta:
