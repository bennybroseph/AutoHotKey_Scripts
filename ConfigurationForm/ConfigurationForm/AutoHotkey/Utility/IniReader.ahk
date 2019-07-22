; Helps with reading from '.ini' files
; Contains functions to quickly parse keybind information

class ConfigSection
{
	static Calibration 	:= "Calibration"
	static Other 		:= "Other"
}
class ProfileSection
{
	static Preferences 	:= "Preferences"
	static AnalogStick 	:= "Analog Stick"
	static Inventory 	:= "Inventory"
	static ImageOverlay	:= "Image Overlay"
}
class KeybindingSection
{
	static Keybindings := "Keybindings"
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
        this.m_ConfigPath := A_WorkingDir . "\" . "config.ini"

        this.m_ProfilePath := A_WorkingDir . "\" . this.ReadKey(this.m_ConfigPath, ConfigSection.Other, "Profile_Path")
		this.m_KeybindingPath := A_WorkingDir . "\" . this.ReadKey(this.m_ConfigPath, ConfigSection.Other, "Keybinding_Path")
    }

	ConfigPath[]
    {
        get {
            return this.__singleton.m_ConfigPath
        }
    }
    ProfilePath[]
    {
        get {
            return this.__singleton.m_ProfilePath
        }
    }
	KeybindingPath[]
	{
		get {
			return this.__singleton.m_KeybindingPath
		}
	}

    ReadKey(p_IniPath, p_Section, p_Key)
    {
        local _temp :=
        IniRead, _temp, % p_IniPath, % p_Section, % p_Key

		if (_temp = "ERROR")
		{
			Debug.Log("Could not find key '" . p_Key . "' in '" . p_IniPath . "' in section '" . p_Section . "'")
			return ERROR
		}

		local _toTitle
		StringLower, _toTitle, _temp, T
		if (_toTitle  = "True")
			_temp := True
		else if (_toTitle = "False")
			_temp := False

        return _temp
    }
    ReadConfigKey(p_Section, p_Key)
    {
        return this.ReadKey(this.ConfigPath, p_Section, p_Key)
    }
    ReadProfileKey(p_Section, p_Key)
    {
        return this.ReadKey(this.ProfilePath, p_Section, p_Key)
    }
	ReadKeybindingKey(p_Section, p_Key)
	{
		return this.ReadKey(this.KeybindingPath, p_Section, p_Key)
	}

	WriteKey(p_Value, p_IniPath, p_Section, p_Key)
	{
		IniWrite, % p_Value, % p_IniPath, % p_Section, % p_Key
	}
	WriteConfigKey(p_Value, p_Section, p_Key)
	{
		this.WriteKey(p_Value, this.ConfigPath, p_Section, p_Key)
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
        local _controlbindString := this.ReadKeybindingKey(KeybindingSection.Keybindings, p_Key)

        ; Returns an error when the requested key is not in the current profile
        if (_controlbindString = "ERROR")
		{
			Debug.Log("Could not find key '" . p_Key . "' in the profile ini's keybindings")
            return ERROR
		}

        local _commaPos := InStr(_controlbindString,",")

		local _newControlbind := new Controlbind()
        local _tempKeybind := new Keybind()
        if(_commaPos)
        {
            _tempKeybind := this.ParseKeybind(SubStr(_controlbindString, 1, _commaPos - 1))
            _newControlbind.OnPress.Action := _tempKeybind.Action
            _newControlbind.OnPress.Modifier := _tempKeybind.Modifier

            _tempKeybind := this.ParseKeybind(SubStr(_controlbindString, _commaPos + 1))
            _newControlbind.OnHold.Action := _tempKeybind.Action
            _newControlbind.OnHold.Modifier := _tempKeybind.Modifier
        }
        else
        {
            _tempKeybind := this.ParseKeybind(_controlbindString)
            _newControlbind.OnPress.Action := _tempKeybind.Action
            _newControlbind.OnPress.Modifier := _tempKeybind.Modifier
        }

        return _newControlbind
    }
    ParseKeybindArray(p_Key)
    {
		local _keybindArrayString := this.ReadKeybindingKey(KeybindingSection.Keybindings, p_Key)

		if (_keybindArrayString = "ERROR")
		{
			Debug.Log("Could not find key '" . p_Key . "' in the profile ini's keybindings")
			return ERROR
		}

		local _newKeybindArray := Array()
		Loop
		{
			local _commaPos := InStr(_keybindArrayString, ",")
			if (_commaPos)
			{
				_newKeybindArray[A_Index] := this.ParseKeybind(SubStr(_keybindArrayString, 1, _commaPos - 1))
				_keybindArrayString := SubStr(_keybindArrayString, _commaPos + 1)
			}
			else
			{
				_newKeybindArray[A_Index] := this.ParseKeybind(_keybindArrayString)
				break
			}
		}

		return _newKeybindArray
    }

	ParseColor(p_ColorString)
	{
		global

		p_ColorString := Trim(p_ColorString)
		p_ColorString := StrReplace(p_ColorString, "(")
		p_ColorString := StrReplace(p_ColorString, ")")

		local _newColor := Array()
		Loop, 4
		{
			local _commaPos := InStr(p_ColorString, ",")
			if _commaPos
				_newColor.Push(SubStr(p_ColorString, 1, _commaPos - 1))
			else
				_newColor.Push(p_ColorString)

			p_ColorString := SubStr(p_ColorString, _commaPos + 1)
		}

		return new Color(_newColor[1], _newColor[2], _newColor[3], _newColor[4])
	}
}