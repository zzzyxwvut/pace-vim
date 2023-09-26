#!/bin/sh -e
#
# Usage: ./tester.sh --help
#
#	[TEST_DEMO_PATH=/path/to/demo.vim] tools/assemble_tests.sh parts/demo
#	[TEST_PACE_PATH=/path/to/pace.vim] tools/assemble_tests.sh parts/pace

parts=''
quiet=0

for a
do
	case "$a" in
	-h | --help)
		printf '%s\n\t%s\n%s\n\t%s\n' >&2 \
			"Usage: [TEST_PACE_PATH=/path/to/pace.vim] \\" \
			"$0 [--quiet] parts/pace [nameprefix ...]" \
			"[TEST_DEMO_PATH=/path/to/demo.vim] \\" \
			"$0 [--quiet] parts/demo [nameprefix ...]"
		exit 80
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

test -n "${parts}"		|| exit 81
test -x "${parts}"/base.sh	|| exit 82
dir="${parts}"/scratch
trap 'test -d "${dir}" && rm -fr "${dir}"' EXIT HUP INT QUIT TERM
test -d "${dir}" || mkdir "${dir}"

## Rotate error logs.
test ! -f errors.9 || rm -f errors.9

for e in 8 7 6 5 4 3 2 1
do
	test ! -f "errors.$e" || mv "errors.$e" "errors.$(($e + 1))"
done

test ! -f errors || mv errors errors.1

## Assemble base.vim.
"${parts}"/base.sh "${dir}" "${quiet}"
set +f

if test "$#" -lt 1
then
	bb=''
	e=''
	ff="`printf '%s\n' "${parts}"/*.vim`"

	case "${ff}" in
	"${parts}"/\*.vim)
		;;
	*)	for f in ${ff}
		do
			f="${f#"${parts}"/}"

			case "$f" in
			*-head-*)
				f="${f%-head*}"
				;;
			*-tail-*)
				f="${f%-tail*}"
				;;
			*)	f="${f%.vim}"
				;;
			esac

			case "$f" in
			"$e")	;;
			*)	bb="${bb} $f"
				e="$f"
				;;
			esac
		done
		;;
	esac

	set -- ${bb# }
fi

i=1

for a
do
	hh="`printf '%s\n' "${parts}/$a"-head-*.vim`"

	case "${hh}" in
	"${parts}"/share/*)
		;;
	"${parts}/$a"-head-\*.vim)
		cat "${dir}"/base.vim \
			"${parts}/$a".vim > "`printf 't%02i.vim' "$i"`"
		i=$(($i + 1))
		;;
	*)	for h in ${hh}
		do
			cat "$h" \
				"${dir}"/base.vim \
				"${h%-head-*}"-tail-"${h#*-head-}" > \
					"`printf 't%02i.vim' "$i"`"
			i=$(($i + 1))
		done
		;;
	esac
done
