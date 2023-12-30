#!/bin/sh -e
#
# Usage: ./tester.sh --help
#
#	mkdir parts/demo/scratch
#	TEST_DEMO_PATH=/path/to/demo.vim parts/demo/base.sh parts/demo/scratch/ 1
#	vdir parts/demo/scratch/
#	rm -r parts/demo/scratch/

test -x tools/mockup_with_awk.sh	|| exit 64
test -x tools/comment_1_with_awk.sh	|| exit 65
test -x tools/comment_n_with_awk.sh	|| exit 66
test -x "`command -v awk`"		|| exit 67
test -d "${1:?No such directory}" && test -x "$1" || exit 68

case "${2:?No such number}" in
*[!0-9]*)
	exit 69
	;;
esac

## Generate an Awk filter templet for mocking up.
tools/mockup_with_awk.sh "$1"/mockup.awk \
		'reltime\(
Reltime('	'reltimestr\(
ReltimeStr('

## Generate Awk filter templets for commenting.
tools/comment_1_with_awk.sh "$1"/comment_1.awk \
		'^vim9script
#'		"^[\t ]+execute 'sleep '
#"		'^[\t ]+redrawstatus
#'
tools/comment_n_with_awk.sh "$1"/comment_n.awk \
		'^try
^endtry
#'

## Arrange filters before the empty pattern.
cat "$1"/mockup.awk "$1"/comment_1.awk "$1"/comment_n.awk - > \
						"$1"/filter.awk <<'EOF'
{
	print
}
EOF

## (For a new candidate version of filter.awk, remove the checked out copy of
## parts/demo/.filter.awk.sha512; run this script once, run this script again,
## and, if all is well, commit the generated parts/demo/.filter.awk.sha512.)
cwd="`pwd`"
cd "$1"

if test -r ../.filter.awk.sha512
then
	ln -s ../.filter.awk.sha512 filter.awk.sha512
	sha512sum --check --status filter.awk.sha512 || exit 70
else
	sha512sum filter.awk > ../.filter.awk.sha512 || exit 71
fi

cd "${cwd}"

## Massage a copy of the original script so that testing it is feasible:
##	(1) Mock up reltime() and reltimestr();
##	(2) Comment out '^vim9script', "^[\t ]+execute 'sleep '",
##		'^[\t ]+redrawstatus';
##		also, comment out '^try'-'^endtry' blocks.
awk -f "$1"/filter.awk "${TEST_DEMO_PATH:-../demo/demo.vim}" > "$1"/demo.vim

## Calculate the first line location of a test file.
vim9script=2
stdin=32
cursor=$((`wc -l "$1"/demo.vim \
parts/share/mockup.vim \
parts/share/assert.vim \
parts/demo/share/turn.vim | \
{ t=0; while read -r a rest; do t="$a"; done; echo "$t"; }` + \
${stdin} + ${vim9script} + 1))

## Implement the --quiet option for ../../tools/assemble_tests.sh: whether
## further testing should be abandoned after the first failed assertion.
test "$2" -ne 0 && quiet='const assert_quiet: bool = true' || quiet=''

## Produce a common-base script file.
cat parts/share/mockup.vim \
"$1"/demo.vim \
- \
parts/share/assert.vim \
parts/demo/share/turn.vim > "$1"/base.vim <<EOF
####################################|STDIN|###################################
demo = Demo.new([
		'',
		'‘A stanza of four lines, usually with alternate rimes;',
		'four lines of verse.’ (NED, VIII, I, 36.)',
		'‘A stanza of four lines, usually with alternate rimes;',
		'four lines of verse.’ (NED, VIII, I, 36.)',
		'‘A stanza of four lines, usually with alternate rimes;',
		'four lines of verse.’ (NED, VIII, I, 36.)',
		'‘A stanza of four lines, usually with alternate rimes;',
		'four lines of verse.’ (NED, VIII, I, 36.)',
		'‘A stanza of four lines, usually with alternate rimes;',
		'four lines of verse.’ (NED, VIII, I, 36.)',
		'‘A stanza of four lines, usually with alternate rimes;',
		'four lines of verse.’ (NED, VIII, I, 36.)',
		'‘A pair of successive lines of verse, _esp._ when riming',
		'together and of the same length.’ (NED, II, 1084.)',
	],
	[
		Linage.new('1st\ quatrain', '^‘A stanza', 3),
		Linage.new('2nd\ quatrain', '^‘A stanza', 3),
		Linage.new('3rd\ quatrain', '^‘A stanza', 3),
		Linage.new('the\ couplet', '^‘A pair', 1),
	])
turn = Turn.new()
setglobal maxfuncdepth& rulerformat& ruler
setglobal statusline=%<%f\ %h%m%r%=%-14.14(%l,%c%V%)\ %P
unlet! g:demo_info
g:demo_info = printf('%-9s %2i, %7i, %5i', '0.00,', 0, 0, 0)
cursor((${cursor} + str2nr(\$TEST_DEMO_CURSOR_OFFSET)), 1)
${quiet}
#####################################|EOF|####################################
EOF
