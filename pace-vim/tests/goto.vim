vim9script

if v:errmsg !~ 'E492'
	finish
endif

# Go to the source line (c[2]) in the file (c[1]) parsed from :messages (@m).
redir @m | silent mess | redir END
const a: list<string> = split(@m, "\n")
const b: string = get(split(get(a, -2, ''), '\.\.'), -2, '')
const c: list<string> = matchlist(b, 'script\s\+\(.\+\)\[\(\d\+\)\]')
execute ':' .. bufwinnr(get(c, 1, '')) .. 'wincmd w'
cursor(str2nr(get(c, 2, '1')), 1)

if winnr('$') > 1
	only
endif

@/ = '* Eval1'
normal N
