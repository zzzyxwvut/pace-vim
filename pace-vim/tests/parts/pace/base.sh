#!/bin/sh -e
#
# Usage: ./tester.sh --help
#
#	mkdir parts/pace/scratch
#	TEST_PACE_PATH=/path/to/pace.vim parts/pace/base.sh parts/pace/scratch/ 1
#	vdir parts/pace/scratch/
#	rm -r parts/pace/scratch/

test -x tools/mockup_with_awk.sh	|| exit 64
test -x tools/comment_1_with_awk.sh	|| exit 65
test -x "`command -v awk`"		|| exit 66
test -d "${1:?No such directory}" && test -x "$1" || exit 67

case "${2:?No such number}" in
*[!0-9]*)
	exit 68
	;;
esac

## Generate an Awk filter templet for mocking up.
tools/mockup_with_awk.sh "$1"/mockup.awk \
		'mode\(
Mode('		'reltime\(
Reltime('	'reltimestr\(
ReltimeStr('	'v:insertmode
insertmode'	'g:Pace_Load\(
Pace_Load('	'g:Pace_Dump\(
Pace_Dump('	'g:Pace_Free\(
Pace_Free('	'^[\t ]*command[ \t]
command! '

## Generate an Awk filter templet for commenting.
tools/comment_1_with_awk.sh "$1"/comment.awk \
		'^vim9script
#'		'^[\t ]+silent! delcommand
#'		'^[\t ]+silent! delfunction
#'		'^lockvar 1 pace turn
#'

## Arrange filters before the empty pattern.
cat "$1"/mockup.awk "$1"/comment.awk - > "$1"/filter.awk <<'EOF'
{
	print
}
EOF

## (For a new candidate version of filter.awk, remove the checked out copy of
## parts/pace/.filter.awk.sha512; run this script once, run this script again,
## and, if all is well, commit the generated parts/pace/.filter.awk.sha512.)
cwd="`pwd`"
cd "$1"

if test -r ../.filter.awk.sha512
then
	ln -s ../.filter.awk.sha512 filter.awk.sha512
	sha512sum --check --status filter.awk.sha512 || exit 69
else
	sha512sum filter.awk > ../.filter.awk.sha512 || exit 70
fi

cd "${cwd}"

## Massage a copy of the original script so that testing it is feasible:
##	(1) Mock up mode(), reltime(), reltimestr(), and v:insertmode;
##		also, limit the scope of Pace_{Load,Dump,Free}();
##		also, permit command redefinition;
##	(2) Comment out '^vim9script', '^[\t ]+silent! delcommand',
##		'^[\t ]+silent! delfunction', and '^lockvar 1 pace turn'.
awk -f "$1"/filter.awk "${TEST_PACE_PATH:-../plugin/pace.vim}" > "$1"/pace.vim

## Calculate the first line location of a test file.
vim9script=2
stdin=4
cursor=$((`wc -l "$1"/pace.vim \
parts/share/mockup.vim \
parts/share/assert.vim \
parts/pace/share/turn.vim | \
{ t=0; while read -r a rest; do t="$a"; done; echo "$t"; }` + \
${stdin} + ${vim9script} + 1))

## Implement the --quiet option for ../../tools/assemble_tests.sh: whether
## further testing should be abandoned after the first failed assertion.
test "$2" -ne 0 && quiet='const assert_quiet: bool = true' || quiet=''

## Produce a common-base script file.
cat parts/share/mockup.vim \
"$1"/pace.vim \
- \
parts/share/assert.vim \
parts/pace/share/turn.vim > "$1"/base.vim <<EOF
####################################|STDIN|###################################
cursor((${cursor} + str2nr(\$TEST_PACE_CURSOR_OFFSET)), 1)
${quiet}
#####################################|EOF|####################################
EOF
