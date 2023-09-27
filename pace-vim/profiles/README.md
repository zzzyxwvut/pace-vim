#### Profiling Support

The Vim build must have the `+profile` feature enabled:

	:echo has('profile')


#### Directory Hierarchies and File Naming

The directory hierarchies for profiling are organised as  
follows (e.g. `foo/7/0/{profiler.vim,{bar,baz}/foo.vim}`):

- the root directories bear names that summarise particular  
  matters under scrutiny, with the code exploring the matter  
  placed in the same-base-named Vim scripts as the leaves of  
  directory hierarchies (thus, `foo/` and `foo.vim`);

- the subdirectories of root directories bear names that  
  match major Vim version numbers, and their subdirectories  
  match minor Vim version numbers, and, so linked, spell out  
  minimum Vim versions against which the leafed scripts are  
  written (thus, `7/` and `0/` make Vim `7.0`);

- the minor-Vim-version-number subdirectories bear names  
  that establish profiling variants of the matter in hand  
  (thus, `bar/` and `baz/`); a single `profiler.vim` is a sibling  
  of these directories, whose sole purpose is to manage its  
  own leafed scripts;

- finally, a single Vim script that bears the-root-directory  
  base-name is placed under profiling-variant directories  
  (thus, `foo.vim`).

Note that the file list of these directory hierarchies (but  
not their structure) may vary among long-lived Git branches  
of this project.


#### Profiling Variants

A hands-on way to discern the heart of the profiling matter  
is to compare the variant files, e.g.:

	vimdiff -o foo/7/0/{bar,baz}/foo.vim


#### Profiling Routines

In order to generate and collect some profiling data, change  
the directory to the location of a chosen `profiler.vim` and  
open that file in Vim and source it, e.g.:

	cd foo/7/0/
	
	## Before Vim patch 8.0.0716:
	vim -i NONE -U NONE -u \$VIMRUNTIME/vimrc_example.vim \
		'+set directory=/tmp' '+source %' profiler.vim
	
	## With Vim patch 8.0.0716:
	vim --clean '+set directory=/tmp' '+source %' profiler.vim

Once the requested profiling is done and the Vim instance is  
quitted, a new report file shall be created in `&directory`.  
By default, profiling may take several minutes; for further  
instruction, seek the _Usage_ comment section in the header of  
`profiler.vim`.


