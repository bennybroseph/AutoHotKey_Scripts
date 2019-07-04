#Include Input\Binding.ahk

class ConfigSection
{
	static Calibration 	:= "Calibration"
	static Other 		:= "Other"
}
class ProfileSection
{
	static Keybindings 		:= "Keybindings"
	static Preferences 		:= "Preferences"
	static AnalogStick 		:= "Analog Stick"
	static TooltipOverlay	:= "Tooltip Overlay"
}

class IniUtility
{
    static __singleton :=
    static __init := False

    Init()
    {
        IniUtility.__singleton := new IniUtility()

        IniUtility.__init := True
    }

    __New()
    {
        this.m_ConfigPath := "config.ini"

        this.m_ProfilePath := A_WorkingDir . IniUtility.ReadKey(this.m_ConfigPath, ConfigSection.Other, "Profile_Location")
    }

    ReadKey(p_IniPath, p_Section, p_Key)
    {
        local _temp :=
        IniRead, _temp, % p_IniPath, % p_Section, % p_Key

        return _temp
    }
    ReadConfigKey(p_Section, p_Key)
    {
        return IniUtility.ReadKey(IniUtility.ConfigPath, p_Section, p_Key)
    }
    ReadProfileKey(p_Section, p_Key)
    {
        return IniUtility.ReadKey(IniUtility.ProfilePath, p_Section, p_Key)
    }

    ParseKeybind(p_KeybindString)
    {
        local _newKeybind := new Keybind()

        p_KeybindString := Trim(p_KeybindString)
        local _plusPos := InStr(p_KeybindString,"+")

        if(_plusPos)
        {
            _newKeybind.Action := SubStr(p_KeybindString, _plusPos+1)
            _newKeybind.Modifier := SubStr(p_KeybindString, 1, _plusPos-1)
        }
        else
            _newKeybind.Action := SubStr(p_KeybindString, 1)

        return _newKeybind
    }
    ParseInputbind(p_Key)
    {
        local _inputbindString := IniUtility.ReadProfileKey(ProfileSection.Keybindings, p_Key)

        ; Returns an error when the requested key is not in the current profile
        if _inputbindString = ERROR
            return ERROR

        local _commaPos := InStr(_inputbindString,",")

		local _newInputBind := new Inputbind()
        local _tempKeybind := new Keybind()
        if(_commaPos)
        {
            _tempKeybind := IniUtility.ParseKeybind(SubStr(_inputbindString, 1, _commaPos - 1))
            _newInputBind.Press.Action := _tempKeybind.Action
            _newInputBind.Press.Modifier := _tempKeybind.Modifier

            _tempKeybind := IniUtility.ParseKeybind(SubStr(_inputbindString, _commaPos + 1))
            _newInputBind.Hold.Action := _tempKeybind.Action
            _newInputBind.Hold.Modifier := _tempKeybind.Modifier
        }
        else
        {
            _tempKeybind := IniUtility.ParseKeybind(_inputbindString)
            _newInputBind.Press.Action := _tempKeybind.Action
            _newInputBind.Press.Modifier := _tempKeybind.Modifier
        }
        ;AddToDebugLog(
        ;    "p_Key " . _inputbindString . " parsed as [1]-" . _newInputBind[1] " [2]-"
        ;    . _newInputBind[2] " [3]-" . _newInputBind[3] " [4]-" . _newInputBind[4])

        return _newInputBind
    }
    ParseKeybindArray(p_Key)
    {
		local _keybindArrayString := IniUtility.ReadProfileKey(ProfileSection.Keybindings, p_Key)

		if _keybindArrayString = ERROR
			return ERROR

		local _newKeybindArray := Array()
		Loop
		{
			local _commaPos := InStr(_keybindArrayString, ",")
			if (_commaPos)
			{
				_newKeybindArray[A_Index] := IniUtility.ParseKeybind(SubStr(_keybindArrayString, 1, _commaPos - 1))
				_keybindArrayString := SubStr(_keybindArrayString, _commaPos + 1)
			}
			else
			{
				_newKeybindArray[A_Index] := IniUtility.ParseKeybind(_keybindArrayString)
				break
			}
		} Until False

		return _newKeybindArray
    }

    ConfigPath[]
    {
        get {
            return IniUtility.__singleton.m_ConfigPath
        }
    }
    ProfilePath[]
    {
        get {
            return IniUtility.__singleton.m_ProfilePath
        }
    }
}