#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force
#Persistent  ; Keep this script running until the user explicitly exits it.

#MaxThreads 255
#KeyHistory 0

ListLines Off

Process, Priority, , A
SetBatchLines, -1

#Include Library\MouseDelta.ahk
#Include Library\Delegate.ahk

_critObj := CriticalObject(A_Args[1])

_function := new MouseDelta(new Delegate("MouseEvent"))
_function.SetState(1)

return

MouseEvent(p_MouseID, p_X := 0, p_Y := 0)
{
	global

	static _carryX := 0, _carryY := 0, _mainMouse

	if (p_MouseID = 0 or (_mainMouse and p_MouseID != _mainMouse))
		Exit

	_mainMouse := p_MouseID

	_critObj.X += p_X
	_critObj.Y += p_Y
}

~$F12::
	ExitApp
return