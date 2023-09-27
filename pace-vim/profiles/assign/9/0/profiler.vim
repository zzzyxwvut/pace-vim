vim9script

# Description:	A profiling routine for the "assign" runners (Vim 9.0)
# Author:	Aliaksei Budavei (0x000c70 AT gmail DOT com)
# Version:	2.0
# Last Change:	2023-Sep-23
# Copyleft ())
#
# Dependencies:	eval and profile features.
#
# Usage:	Change the directory to this file's location and open the file
#		in Vim and source it to commence profiling that shall generate
#		a file assign-vim_version-localtime.vim populated with collected
#		data.  E.g. (8+ minutes for the 286-character /etc/motd):
#
#		time for i in {0..3}; do \
#			ASSIGN_PROFILE_LR_THEN_TB=1 \
#			ASSIGN_PROFILE_ITERATIONS=2 \
#			ASSIGN_PROFILE_LINE_COUNT=4 \
#			ASSIGN_PROFILE_FILENAME=/etc/motd \
#				vim --clean \
#					+set\ directory=/tmp \
#					+source\ % \
#					profiler.vim; \
#		done
#
# Notes:	Each runner can be stopped in the tracks by hitting Ctrl-c.

if !(has('profile') && filereadable('left-right/assign.vim') &&
					filereadable('top-bottom/assign.vim'))
	finish
endif

const lines: number = str2nr($ASSIGN_PROFILE_LINE_COUNT)
const times: number = str2nr($ASSIGN_PROFILE_ITERATIONS)
const delay: number = str2nr($ASSIGN_PROFILE_MILLISEC_DELAY)

var fname: string = $ASSIGN_PROFILE_FILENAME
var args: list<any> = []
var dirs: list<string> = []

try
	fname = empty(fname) ? '../../../README.md' : fname

	if !filereadable(fname)
		echomsg '`' .. fname .. "': No such file"
		finish
	endif

	args = [fname,
		lines < 1 || lines > 4096 ? 1024 : lines,
		times < 1 || times > 1024 ? 1 : times,
		delay < 50 || delay > 300 ? '160m' : delay .. 'm']
	dirs = split(&directory, ',')
	execute printf('profile start %s/assign-%s-%s.vim',
					empty(dirs) ? '.' : dirs[0],
					v:version,
					localtime())
	profile func *Eval[01]

	if !empty($ASSIGN_PROFILE_LR_THEN_TB)
		source left-right/assign.vim
		call('g:Assign_Runner_LR_9_0', args)
		source top-bottom/assign.vim
		call('g:Assign_Runner_TB_9_0', args)
	else
		source top-bottom/assign.vim
		call('g:Assign_Runner_TB_9_0', args)
		source left-right/assign.vim
		call('g:Assign_Runner_LR_9_0', args)
	endif
finally
	dirs = null_list
	args = null_list
	fname = null_string
endtry

quitall

# vim:fdm=syntax:sw=8:ts=8:noet:nolist:nosta:
