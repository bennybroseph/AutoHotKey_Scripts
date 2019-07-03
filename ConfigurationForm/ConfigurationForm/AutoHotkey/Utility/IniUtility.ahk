#Include Input\Binding.ahk

class IniUtility
{
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
        local _inputbindString
        IniRead, _inputbindString, % ProfilePath, Buttons, % p_Key

        local _newInputBind := new Inputbind()

        ; Returns an error when the requested key is not in the current profile
        if _inputbindString = ERROR
            return ERROR

        local _commaPos := InStr(_inputbindString,",")

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
}