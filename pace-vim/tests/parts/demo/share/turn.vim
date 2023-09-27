#############################|demo/share/turn.vim|############################
def Get_Tick(): list<number>
	return turn[0]
enddef

def Set_Tick(value: list<number>)
	turn[0] = value
enddef

def Get_Secs(): number
	return turn[1]
enddef

def Set_Secs(value: number)
	turn[1] = value
enddef

def Get_Parts(): number
	return turn[2]
enddef

def Set_Parts(value: number)
	turn[2] = value
enddef

def Get_Chars(): number
	return turn[3]
enddef

def Set_Chars(value: number)
	turn[3] = value
enddef

defcompile
#####################################|EOF|####################################
