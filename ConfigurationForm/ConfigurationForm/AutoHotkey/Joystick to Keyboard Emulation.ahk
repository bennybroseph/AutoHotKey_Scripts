#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force
#Persistent  ; Keep this script running until the user explicitly exits it.
;#Warn  ; Enable warnings to assist with detecting common errors.

#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#MaxThreads 255
;#KeyHistory 0

;ListLines Off

Process, Priority, , A
SetBatchLines, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetKeyDelay, -1, -1
SetWinDelay, -1
SetControlDelay, -1

SetTitleMatchMode, Fast
SetTitleMatchMode, 3

CoordMode, Mouse, Screen
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Compile the library files
#Include Library\LoadDLL.ahk
#Include Library\XInput.ahk
#Include Library\Gdip.ahk
#Include Library\ToolTipOptions.ahk
#Include Library\Delegate.ahk
#include Library\Sleep.ahk

; Compile the utility classes
#Include Utility\DataStructures.ahk
#Include Utility\Debug.ahk
#Include Utility\FPS.ahk
#Include Utility\IniReader.ahk
#Include Utility\Calibrate.ahk
#Include Utility\Inventory.ahk

; Compile the graphics classes
#Include Graphics\Graphic.ahk
#Include Graphics\Graphics.ahk
#Include Graphics\ImageOverlay.ahk

; Compile the input classes
#Include Input\Binding.ahk
#Include Input\Input.ahk
#Include Input\InputHelper.ahk
#Include Input\InputManager.ahk
#Include Input\Controller.ahk
#Include Input\Intercept.ahk

global PI := 3.141592653589793 ; Define PI for easier use

XInput_Init() ; Initialize XInput

Debug.Init()
IniReader.Init()
FPS.Init()

global IsPaused := False
global ShowPausedNotification := IniReader.ReadProfileKey(ProfileSection.Preferences, "Show_Paused_Notification")

Graphics.Init()

Calibrate()
Inventory.Init()
InputManager.Init()
ImageOverlay.Init()

Debug.InitControllerOverlay()
ImageOverlay.DrawImageOverlay()

Loop
{
	FPS.Update()

	Graphics.SetActiveWinStats()
	ImageOverlay.DrawBatteryStatus()

	InputManager.Update()

	Debug.Update()
}

return

; Reloads the config values when F5 is pressed
$F5::
	Reload
return

; Pauses the script and displays a message indicating so whenever F10 is pressed.
; The '$' ensures the hotkey can't be triggered with a 'Send' command
$F10::
	; Set the tooltip if it should be shown
	if(!IsPaused and ShowPausedNotification)
		Graphics.DrawToolTip("Paused `nPress F10 to resume", 0, 0, 4)
	; Remove the tooltip if it is currently shown
	else if(ShowPausedNotification)
		Graphics.HideToolTip(4)

	IsPaused := !IsPaused	; Toggle the pause boolean
	Pause, , 1
return

; Closes the program. The '$' ensures the hotkey can't be triggered with a 'Send' command
$F12::
	Sleep(1, "Off")
	XInput_Term()
	ExitApp
return

VibeOff:
	Loop, 4
	{
		if XInput_GetState(A_Index-1)
			XInput_SetState(A_Index-1, 0, 0) ;MAX 65535
	}
return

SpamLoot:
	MouseGetPos, _prevX, _prevY
	MouseMove, % Graphics.ActiveWinStats.Center.X, % Graphics.ActiveWinStats.Center.Y
	Send {LButton Down}
	Send {LButton Up}
	MouseMove, % _prevX, % _prevY
return