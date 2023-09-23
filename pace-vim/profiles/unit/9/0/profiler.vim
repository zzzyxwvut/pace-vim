vim9script

# Description:	A profiling routine for the "unit" runners (Vim 9.0)
# Author:	Aliaksei Budavei (0x000c70 AT gmail DOT com)
# Version:	2.0
# Last Change:	2023-Sep-23
# Copyleft ())
#
# Dependencies:	eval and profile features.
#
# Usage:	Change the directory to this file's location and open the file
#		in Vim and source it to commence profiling that shall generate
#		a file unit-vim_version-localtime.vim populated with collected
#		data.  E.g. (8+ minutes for the 286-character /etc/motd):
#
#		time for i in {0..3}; do \
#			UNIT_PROFILE_PRF_THEN_RTS=1 \
#			UNIT_PROFILE_ITERATIONS=2 \
#			UNIT_PROFILE_LINE_COUNT=4 \
#			UNIT_PROFILE_FILENAME=/etc/motd \
#				vim --clean \
#					+set\ directory=/tmp \
#					+source\ % \
#					profiler.vim; \
#		done
#
# Notes:	Each runner can be stopped in the tracks by hitting Ctrl-c.

if !(has('profile') && filereadable('printf/unit.vim') &&
					filereadable('reltimestr/unit.vim'))
	finish
endif

const lines: number = str2nr($UNIT_PROFILE_LINE_COUNT)
const times: number = str2nr($UNIT_PROFILE_ITERATIONS)
const delay: number = str2nr($UNIT_PROFILE_MILLISEC_DELAY)

var fname: string = $UNIT_PROFILE_FILENAME
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
	execute printf('profile start %s/unit-%s-%s.vim',
					empty(dirs) ? '.' : dirs[0],
					v:version,
					localtime())
	profile func *Eval[01]

	if !empty($UNIT_PROFILE_PRF_THEN_RTS)
		source printf/unit.vim
		call('g:Unit_Runner_PRF_9_0', args)
		source reltimestr/unit.vim
		call('g:Unit_Runner_RTS_9_0', args)
	else
		source reltimestr/unit.vim
		call('g:Unit_Runner_RTS_9_0', args)
		source printf/unit.vim
		call('g:Unit_Runner_PRF_9_0', args)
	endif
finally
	dirs = null_list
	args = null_list
	fname = null_string
endtry

quitall

# vim:fdm=syntax:sw=8:ts=8:noet:nolist:nosta:
