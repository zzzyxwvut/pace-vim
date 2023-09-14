#!/bin/sh -e
#
# Usage: ./mockup_with_awk.sh mockup.awk \
#			'mode\(
# s:Mode('		'reltime\(
# s:Reltime('		'reltimestr\(
# s:ReltimeStr('	'v:insertmode
# s:insertmode'

stmnt()
{
	ifs="${IFS}"
	IFS='
'
	set -- $1
	test "$#" -gt 1 || return 50
	printf '%s' \
"/$1/ {
	gsub(/$1/, \"$2\")
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
