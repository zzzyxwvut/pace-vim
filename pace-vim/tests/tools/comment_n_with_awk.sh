#!/bin/sh -e
#
# Usage: ./comment_n_with_awk.sh comment.awk \
#			'^try
# ^endtry
# \"'

stmnt()
{
	ifs="${IFS}"
	IFS='
'
	set -- $1
	test "$#" -gt 2 || return 49
	printf '%s' \
"/$1/, /$2/ {
	gsub(/.*/, \"$3 &\")
}"
	IFS="${ifs}"
}

s=''
n="${1:?}"
shift

for a
do
	s="$s`stmnt "$a"`
"
done

printf '%s' "$s" > "$n"
