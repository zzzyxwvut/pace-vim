""""""""""""""""""""""""""""""""""|demo.vim|""""""""""""""""""""""""""""""""""
if exists(':PaceDemo') != 2
	quit
endif

try
	" Source own part initially, changing the directory to parts/*/; but
	" fail on the second iteration, owing to the dupe of parts/*/parts/*/.
	PaceDemo parts/pace/demo.vim
	throw 'Oh!  I do so wish I could see _that_ bit!'
catch	/E344/
	lcd ../..
	quit
endtry
"""""""""""""""""""""""""""""""""""""|EOF|""""""""""""""""""""""""""""""""""""
