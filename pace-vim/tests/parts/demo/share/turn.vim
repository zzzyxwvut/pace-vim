#############################|demo/share/turn.vim|############################
def Get_Tick(): list<number>
	return turn.a
enddef

def Set_Tick(value: list<number>)
	turn.a = value
enddef

def Get_Secs(): number
	return turn.b
enddef

def Set_Secs(value: number)
	turn.b = value
enddef

def Get_Parts(): number
	return turn.c
enddef

def Set_Parts(value: number)
	turn.c = value
enddef

def Get_Chars(): number
	return turn.d
enddef

def Set_Chars(value: number)
	turn.d = value
enddef

defcompile
#####################################|EOF|####################################
