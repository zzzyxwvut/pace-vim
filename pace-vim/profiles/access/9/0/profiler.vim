vim9script

# Description:	A profiling routine for the "access" runners (Vim 9.0)
# Author:	Aliaksei Budavei (0x000c70 AT gmail DOT com)
# Version:	2.0
# Last Change:	2023-Sep-23
# Copyleft ())
#
# Dependencies:	eval and profile features.
#
# Usage:	Change the directory to this file's location and open the file
#		in Vim and source it to commence profiling that shall generate
#		a file access-vim_version-localtime.vim populated with collected
#		data.  E.g. (12+ minutes for the 286-character /etc/motd):
#
#		time for i in {0..3}; do \
#			ACCESS_PROFILE_ORDER=blob,dict,list \
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

if !(has('profile') && filereadable('blob/access.vim') &&
					filereadable('dict/access.vim') &&
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
	profile func *Blob2Nr*
	profile func *Nr2Blob*

	var frequency: number = 0

	if !empty($ACCESS_PROFILE_ORDER)
		for kind in split($ACCESS_PROFILE_ORDER, ',')
			if kind =~? '\<blob\>' && and(frequency, 0x1) == 0
				frequency = or(frequency, 0x1)
				source blob/access.vim
				call('g:Access_Runner_BLOB_9_0', args)
			elseif kind =~? '\<dict\>' && and(frequency, 0x2) == 0
				frequency = or(frequency, 0x2)
				source dict/access.vim
				call('g:Access_Runner_DICT_9_0', args)
			elseif kind =~? '\<list\>' && and(frequency, 0x4) == 0
				frequency = or(frequency, 0x4)
				source list/access.vim
				call('g:Access_Runner_LIST_9_0', args)
			endif
		endfor
	endif

	if frequency == 0
		source list/access.vim
		call('g:Access_Runner_LIST_9_0', args)
		source dict/access.vim
		call('g:Access_Runner_DICT_9_0', args)
		source blob/access.vim
		call('g:Access_Runner_BLOB_9_0', args)
	endif
finally
	dirs = null_list
	args = null_list
	fname = null_string
endtry

quitall

# vim:fdm=syntax:sw=8:ts=8:noet:nolist:nosta:
