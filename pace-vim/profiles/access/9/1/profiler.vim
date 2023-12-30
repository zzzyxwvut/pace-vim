vim9script

# Description:	A profiling routine for the "access" runners (Vim 9.1)
# Author:	Aliaksei Budavei (0x000c70 AT gmail DOT com)
# Version:	3.0
# Last Change:	2023-Dec-30
# Copyleft ())
#
# Dependencies:	eval and profile features.
#
# Usage:	Change the directory to this file's location and open the file
#		in Vim and source it to commence profiling that shall generate
#		a file access-vim_version-localtime.vim populated with collected
#		data.  E.g. (8+ minutes for the 286-character /etc/motd):
#
#		time for i in {0..3}; do \
#			ACCESS_PROFILE_CLASS_THEN_LIST=1 \
#			ACCESS_PROFILE_ITERATIONS=2 \
#			ACCESS_PROFILE_LINE_COUNT=4 \
#			ACCESS_PROFILE_FILENAME=/etc/motd \
#				vim --clean \
#					+set\ directory=/tmp \
#					+source\ % \
#					profiler.vim; \
#		done
#
# Notes:	Each runner can be stopped in the tracks by hitting Ctrl-c.

if !(has('profile') && filereadable('class/access.vim') &&
					filereadable('list/access.vim'))
	finish
endif

const lines: number = str2nr($ACCESS_PROFILE_LINE_COUNT)
const times: number = str2nr($ACCESS_PROFILE_ITERATIONS)
const delay: number = str2nr($ACCESS_PROFILE_MILLISEC_DELAY)

var fname: string = $ACCESS_PROFILE_FILENAME
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
	execute printf('profile start %s/access-%s-%s.vim',
					empty(dirs) ? '.' : dirs[0],
					v:version,
					localtime())
	profile func *Eval[01]

	if !empty($ACCESS_PROFILE_CLASS_THEN_LIST)
		source class/access.vim
		call('g:Access_Runner_CLASS_9_1', args)
		source list/access.vim
		call('g:Access_Runner_LIST_9_1', args)
	else
		source list/access.vim
		call('g:Access_Runner_LIST_9_1', args)
		source class/access.vim
		call('g:Access_Runner_CLASS_9_1', args)
	endif
finally
	dirs = null_list
	args = null_list
	fname = null_string
endtry

quitall

# vim:fdm=syntax:sw=8:ts=8:noet:nolist:nosta:
