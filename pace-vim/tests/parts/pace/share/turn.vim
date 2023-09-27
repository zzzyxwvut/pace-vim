#############################|pace/share/turn.vim|############################
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

def Get_Chars_Sum(): number
	return turn[4]
enddef

def Set_Chars_Sum(value: number)
	turn[4] = value
enddef

def Get_Secs_Sum(): number
	return turn[5]
enddef

def Set_Secs_Sum(value: number)
	turn[5] = value
enddef

defcompile
#####################################|EOF|####################################
