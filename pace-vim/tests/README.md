#### Testing Facilities

All _disassembled_ test files are maintained under the `parts`  
subdirectory of this directory; whereas `tester.sh` serves as  
an entry point for their arranging and sourcing for testing.  
With each invocation of `tester.sh`, the selected test files  
shall be supplied with claimed dependencies and written as  
the `t[0-9][0-9].vim` files in this directory; after, these  
files shall be sourced, one at a time, and failed assertions  
for them shall be appended to a rotatable `errors` file.  By  
default, failed assertions obstruct progress by trying to  
move cursor to the offending line of a failed assertion and  
throwing an exception.  Alternatively, only the first failed  
assertion can be recorded without stopping for examination,  
and further testing, if any, abandoned for that file, with  
the `--quiet` option passed to `tester.sh`.


#### Execution Examples

For example, run all tests (in alphabetical order applied to  
`parts/pace`-filenames):

	./tester.sh

Alternate the testing of only `foo`- and `bar`-nameprefix files  
with:

	./tester.sh foo bar foo bar

where `bar` denotes `parts/pace/bar-{head,tail}-{a,b}.vim` and  
`foo` denotes `parts/pace/foo.vim`; seeking five disassembled  
files that shall be written as three files, repeated:

- `t01.vim` (`foo`),
- `t02.vim` (`bar-head+tail-a`),
- `t03.vim` (`bar-head+tail-b`),
- `t04.vim` (`foo`),
- `t05.vim` (`bar-head+tail-a`),
- `t06.vim` (`bar-head+tail-b`).


