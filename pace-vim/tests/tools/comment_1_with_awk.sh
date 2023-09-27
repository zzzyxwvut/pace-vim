#!/bin/sh -e
#
# Usage: ./comment_1_with_awk.sh comment.awk \
#			'^[\t ]+silent! delcommand
# \"'			'^[\t ]+silent! delfunction
# \"'

stmnt()
{
	ifs="${IFS}"
	IFS='
'
	set -- $1
	test "$#" -gt 1 || return 48
	printf '%s' \
"/$1/ {
	gsub(/$1/, \"$2 &\")
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
