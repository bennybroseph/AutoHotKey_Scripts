; Helps with reading from '.ini' files
; Contains functions to quickly parse keybind information

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

class IniReader
{
    static __singleton :=
    static __init := False

    Init()
    {
        IniReader.__singleton := new IniReader()

        IniReader.__init := True
    }

    __New()
    {
        this.m_ConfigPath := "config.ini"

        this.m_ProfilePath := A_WorkingDir . IniReader.ReadKey(this.m_ConfigPath, ConfigSection.Other, "Profile_Location")
    }

	ConfigPath[]
    {
        get {
            return IniReader.__singleton.m_ConfigPath
        }
    }
    ProfilePath[]
    {
        get {
            return IniReader.__singleton.m_ProfilePath
        }
    }

    ReadKey(p_IniPath, p_Section, p_Key)
    {
        local _temp :=
        IniRead, _temp, % p_IniPath, % p_Section, % p_Key

        return _temp
    }
    ReadConfigKey(p_Section, p_Key)
    {
        return IniReader.ReadKey(IniReader.ConfigPath, p_Section, p_Key)
    }
    ReadProfileKey(p_Section, p_Key)
    {
        return IniReader.ReadKey(IniReader.ProfilePath, p_Section, p_Key)
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
    ParseControlbind(p_Key)
    {
        local _controlbindString := IniReader.ReadProfileKey(ProfileSection.Keybindings, p_Key)

        ; Returns an error when the requested key is not in the current profile
        if _controlbindString = ERROR
            return ERROR

        local _commaPos := InStr(_controlbindString,",")

		local _newControlbind := new Controlbind()
        local _tempKeybind := new Keybind()
        if(_commaPos)
        {
            _tempKeybind := IniReader.ParseKeybind(SubStr(_controlbindString, 1, _commaPos - 1))
            _newControlbind.OnPress.Action := _tempKeybind.Action
            _newControlbind.OnPress.Modifier := _tempKeybind.Modifier

            _tempKeybind := IniReader.ParseKeybind(SubStr(_controlbindString, _commaPos + 1))
            _newControlbind.OnHold.Action := _tempKeybind.Action
            _newControlbind.OnHold.Modifier := _tempKeybind.Modifier
        }
        else
        {
            _tempKeybind := IniReader.ParseKeybind(_controlbindString)
            _newControlbind.OnPress.Action := _tempKeybind.Action
            _newControlbind.OnPress.Modifier := _tempKeybind.Modifier
        }
        ;AddToDebugLog(
        ;    "p_Key " . _controlbindString . " parsed as [1]-" . _newControlbind[1] " [2]-"
        ;    . _newControlbind[2] " [3]-" . _newControlbind[3] " [4]-" . _newControlbind[4])

        return _newControlbind
    }
    ParseKeybindArray(p_Key)
    {
		local _keybindArrayString := IniReader.ReadProfileKey(ProfileSection.Keybindings, p_Key)

		if _keybindArrayString = ERROR
			return ERROR

		local _newKeybindArray := Array()
		Loop
		{
			local _commaPos := InStr(_keybindArrayString, ",")
			if (_commaPos)
			{
				_newKeybindArray[A_Index] := IniReader.ParseKeybind(SubStr(_keybindArrayString, 1, _commaPos - 1))
				_keybindArrayString := SubStr(_keybindArrayString, _commaPos + 1)
			}
			else
			{
				_newKeybindArray[A_Index] := IniReader.ParseKeybind(_keybindArrayString)
				break
			}
		} Until False

		return _newKeybindArray
    }
}