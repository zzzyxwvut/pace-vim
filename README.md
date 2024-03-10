The `pace.vim` script offers a means to measure the pace of  
typing (in `Insert`, `Replace`, & `Virtual Replace` modes) in  
a preselected manner: cumulative, buffer-total, or instance  
(dumpable on demand).  It provides a tunable policy tool to  
inhibit any mode tracing and to control borderline cases  
(`Ctrl-c` exiting, no input).  All data collected in a session  
may be carried over and re-used.

The bundled `demo.vim` script parades a specialised variant  
of `pace.vim` in mock-action with a touch of rhyming.

In order to install the project files into a writable user's  
Vim directory, either clone this repository and copy all  
`pace-vim/pace-vim` files _or_ fetch the most recent zipped  
[archive](https://www.vim.org/scripts/script.php?script_id=5472) and extract its files.

Since Vim 8, consider assembling a Vim package for either  
cloning, copying, or extracting:
```vim
:help packages
```

Having the files installed, launch Vim and list all `doc/`  
locations:
```vim
:echo finddir('doc', &runtimepath, -1)
```

Now generate the help tags:
```vim
:helptags /path/to/doc
```

Then read the documentation:
```vim
:help pace.txt
```

