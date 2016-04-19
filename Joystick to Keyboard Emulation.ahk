#NoEnv
;#Warn
#include XInput.ahk
#include Gdip.ahk
#include KeyHandle.ahk

SetBatchLines, -1
SetMouseDelay, -1
SetWinDelay, -1

XInput_Init() ; Initialize XInput
OnExit, ExitSub

KeyHandler := new KeyHandle()
;FPS := new FPS(120)

WinActivate Diablo III

Loop
{	
	KeyHandler.Handle()
	;FPS.Get_FPS()
	;Sleep, % FPS.Get_Sleep()
}

ExitSub:
$F12::
KeyHandler.Delete_Me()
ExitApp, 0
return

; Pauses the script and displays a message indicating so whenever F10 is pressed. The '$' ensures the hotkey can't be triggered with a 'Send' command
$F10::
Tooltip, Paused `nPress F10 to resume, 0, 0, 4
if(A_IsPaused)
	Tooltip, , , , 4
Pause,,1
return
