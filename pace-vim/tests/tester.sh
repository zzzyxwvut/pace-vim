#!/bin/sh -e

test -x parts/			|| exit 97
test -x tools/			|| exit 98
test -x "`command -v vim`"	|| exit 99
clean_up=0
quiet=0

for a
do
	case "$a" in
	-h | --help)
		printf '%s\n\t%s\n%s\n\t%s\n' >&2 \
			"Usage: [TEST_PACE_PATH=/path/to/pace.vim] \\" \
			"$0 [--clean-up] [--quiet] [parts/pace] [nameprefix ...]" \
			"[TEST_DEMO_PATH=/path/to/demo.vim] \\" \
			"$0 [--clean-up] [--quiet] parts/demo [nameprefix ...]"
		exit 96
		;;
	-c | --clean-up)
		clean_up=1
		;;
	-q | --quiet)
		quiet=1
		;;
	parts/demo | parts/demo/ | parts/pace | parts/pace/)
		parts="${a%/}"
		;;
	*)	break
		;;
	esac

	shift
done

case "${parts}" in
parts/demo | parts/pace)
	;;
*)	parts=parts/pace
	;;
esac

set +f
rm -f t[0-9][0-9].vim pace_[0-9][0-9]*
status="$?"
test "${clean_up}" -eq 0 || trap 'rm -f t[0-9][0-9].vim pace_[0-9][0-9]* || :
exit "${status}"' EXIT HUP INT QUIT TERM

if test "${quiet}" -ne 0
then
	tools/assemble_tests.sh --quiet "${parts}" "$@" || status="$?"
else
	tools/assemble_tests.sh "${parts}" "$@" || status="$?"
fi

test "${status}" -eq 0 || exit "${status}"
ff="`printf '%s\n' t[0-9][0-9].vim`"

case "${ff}" in
t\[0-9\]\[0-9\].vim)
	;;
*)	for f in ${ff}
	do
		sleep 1 || status="$?"
		vim --clean \
			+source\ % \
			"$f" || status="$?"
		test "${status}" -eq 0 || exit "${status}"
	done
	;;
esac

if test ! -r errors
then
	# For a _cleaned-up_ audit.
	touch errors || status="$?"
fi

test ! -s errors || status=$((32 + ${status}))
exit "${status}"
