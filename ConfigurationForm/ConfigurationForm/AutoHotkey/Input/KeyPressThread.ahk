#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#SingleInstance Force
#Persistent  ; Keep this script running until the user explicitly exits it.

; #MaxHotkeysPerInterval 99000000
; #HotkeyInterval 99000000
; #MaxThreads 255

#KeyHistory 0

ListLines Off

Process, Priority, , A
SetBatchLines, -1

_critObj := CriticalObject(A_Args[1])

_boundFunction := Func("PressKeybind").Bind()
Hotkey, % _critObj.Hotkey, % _boundFunction

return

PressKeybind()
{
	global

	if (_critObj.State = True)
		Exit

	_critObj.PrevState := _critObj.State
	_critObj.State := True
}

~$F12::
	ExitApp
return