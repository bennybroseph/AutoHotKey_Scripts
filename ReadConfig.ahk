
global PI := 3.141592653589793 ; Define PI for easier use

Class ReadConfig
{
	Load(byRef Variable, ConfigFile, LabelName, ValueName){
		IniRead, Variable, %ConfigFile%, %LabelName%, %ValueName%
		
		if(Variable = ERROR || !Variable)
		{
			MsgBox, 4, Error in %ConfigFile%, %ValueName% was was not found in config.ini or was blank. Did you delete it?
			return ERROR
		}
		
		i := InStr(Variable, ";")
		
		if(i)
			Variable := SubStr(Variable ,1 ,i-1)
		;MsgBox,,, % Variable
	}
	
	Load_Ignore() {
		IgnoreTarget := Array()
		IniRead, temp, config.ini, Buttons, Ignore_Target
		IgnoreTarget[1] := temp
		
		EndLoop := false
		Loop
		{
			i := InStr(IgnoreTarget[A_Index],", ")
			
			if(i)
			{
				IgnoreTarget[A_Index+1] := SubStr(IgnoreTarget[A_Index], i+2)
				IgnoreTarget[A_Index] := SubStr(IgnoreTarget[A_Index], 1, i-1)			
			}
			else
				EndLoop := true
		}Until EndLoop
	
		return IgnoreTarget
	}
	
	Load_Button(ButtonName, byRef PressKey, byRef PressModifier, byRef HoldKey, byRef HoldModifier){
		IniRead, Key, config.ini, Buttons, %ButtonName%
		
		if(Key = ERROR || !Key)
		{
			MsgBox, 4, Error in config.ini, %ButtonName% was not found in config.ini or was blank. Did you delete it? `nEither way, that button will be non-functioning until it is resolved.
			return ERROR
		}
		
		i := InStr(Key,"+") 
		f := InStr(Key,", ")
		if(i > f) ; Hold Modifier with no Press Modifier
		{
			j := i
			i := 0
		}
		else
			j := InStr(Key,"+",,,2)
		
		if(j)
		{	
			HoldKey := SubStr(Key, j+1)
			HoldModifier := SubStr(Key, f+2, j-f-2)
			if(i)
			{	
				PressKey := SubStr(Key, i+1, f-i-1)
				PressModifier := SubStr(Key, 1, i-1)
			}
			else
				PressKey := SubStr(Key, 1, f-1)
		}
		else if(f)
		{
			HoldKey := SubStr(Key, f+2)
			if(i)
			{
				PressKey := SubStr(Key, i+1, f-i-1)
				PressModifier := SubStr(Key, 1, i-1)
			}
			else
				PressKey := SubStr(Key, 1, f-1)
		}
		else if(i)
		{
			PressKey := SubStr(Key, i+1)
			PressModifier := SubStr(Key, 1, i-1)
		}
		else
			PressKey := Key
		
		;MsgBox,,, % PressModifier "+" PressKey "`n" HoldModifier "+" HoldKey "`n`n" i ":" f ":" j "`n" Key
	}
}