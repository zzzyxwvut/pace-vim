vim9script

if v:errmsg !~ 'E492'
	finish
endif

# Go to the source line (offset + d) in the file (c) parsed from :messages (@m).
redir @m | silent mess | redir END
const a: list<string> = split(@m, "\n")
const b: list<string> = split(get(a, -2, ''), '\.\.')[-3 : -2]
const c: string = get(matchlist(get(b, 0, ''), 'script\s\+\(.\+\)\[\d\+\]'), 1, '')
const d: string = get(matchlist(get(b, 1, ''), 'function\s\+.\+\[\(\d\+\)\]'), 1, '0')
execute ':' .. bufwinnr(c) .. 'wincmd w'
cursor((search('^def s:Test_()', 'ew') + str2nr(d)), 1)

if winnr('$') > 1
	only
endif

@/ = '* Sample1'
normal N
