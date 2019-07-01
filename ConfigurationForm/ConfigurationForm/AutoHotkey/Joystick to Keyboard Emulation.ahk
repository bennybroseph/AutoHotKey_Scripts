#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Persistent  ; Keep this script running until the user explicitly exits it.
;#Warn  ; Enable warnings to assist with detecting common errors.

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directoTargety.

#Include XInput.ahk
#Include Gdip.ahk

XInput_Init() ; Initialize XInput
Gdip_Startup()

global PI := 3.141592653589793 ; Define PI for easier use

TThreshold := 64 ; for trigger deadzones

global ConfigurationPath = "config.ini"
global ProfilePath = "preferences.ini"

global DebugMode := false ;Is debug mode on?
global DebugLog := ""
global DebugLogLength := 0

global IsPaused := false ; Is the application paused?

global DefaultForceMoveKey := Array() ; This is the force move key set by the user in the .ini file
global ForceMoveKey := Array() ; This is the current force move key. When using keybindings which ignore the targeting reticule, this value is set to the new hotkey temporarily.
global Move := false ; This is true when space is pressed down so that it is not spam pressed over and over. It is set to false when a button is pressed, or the left analog stick is released
global ForceMove := false ; This is true whenever all buttons are released. I use this to force the analog stick to induce movement any time it otherwise may not press the space bar
global ForceTarget := false

global Target := false ; This is true when the Right analog stick is currently being used
global TargetX ; This is the red target on the screen's X value
global TargetY ; This is the red target on the screen's Y value
global MouseX ; The left stick's X value on the screen
global MouseY ; The right stick's Y value on the screen

global Pressed := 0 ; This value stores the amount of buttons currently pressed. It is used to stop the left ananlog stick from inducing movement
global IgnoreIt := false ; When this value is greater true, there is a button currently pressed that the user does not want to use the target cursor for
global IgnorePressed := 0

global IsInitializing := true ; This is true until the 'Startup' timer has completed. It is used to stop some functions from running until everything has been initialized.

global LThumbX ; The left analog stick's X value
global LThumbY ; The left analog stick's Y value
global RThumbX ; The right analog stick's X value
global RThumbY ; The right analog stick's Y value

global LMaxThreshold ; Analog movement is not in a circle, rather it is a square. A lumpy square. This is how I round out the square so it is easier to create a circle from it.
global RMaxThreshold ; See above, but for the right stick
            
global LThumbX0 ; The X value when the left stick is at rest
global LThumbY0 ; The Y value when the left stick is at rest
global RThumbX0 ; The X value when the left stick is at rest
global RThumbY0 ; The Y value when the left stick is at rest

global PrevMouseX ; The mouse X value before any buttons were pressed
global PrevMouseY ; The mouse Y value before any buttons were pressed

global ScreenCenterX ; Center X position of the current active window
global ScreenCenterY ; Center Y position of the current active window

global Width
global Height

global RStick := true ; When true the target is locked to an oval, when false it moves like a cursor
global LStick := true ; When true movement is normal, when false cursor mode is enabled

global LootDelay ; The delay in milliseconds defined by the user between spamming the loot command
global TargetingDelay ; The delay in milliseconds defined by the user before sending input at the targeting reticule's location

global VibeStrength ; The strength of the vibration
global VibeDuration ; The length of time in milliseconds that the controller vibrates
global Delay

global LMaxRadiusX ; The radius the cursor maxes out at on the left stick in the X direction 
global LMaxRadiusY ; The radius the cursor maxes out at on the left stick in the Y direction 

global LThreshold ; The deadzone of the left stick

global RMaxRadiusX ; The radius the cursor maxes out at on the left stick in the X direction 
global RMaxRadiusY ; The radius the cursor maxes out at on the left stick in the Y direction 

global RThreshold ; The deadzone of the right stick

global ApplicationName ; Name of the application the script is set to run on

; Offset from the center of the currently active window to consider to be the actual center
global CenterOffsetX
global CenterOffsetY

; Extra offset for the left stick to adhere to from the center of the currently active window
global LRadiusOffsetX
global LRadiusOffsetY

; Extra offset for the right stick to adhere to from the center of the currently active window
global RRadiusOffsetX 
global RRadiusOffsetY

; Sensitivity values for the left analog sticks
global LSensitivityX
global LSensitivityY

; Sensitivity values for the right analog sticks
global RSensitivityX
global RSensitivityY

global ShowCursorModeNotification ; Whether or not to show the cursor mode notification when in said mode
global ShowInventoryModeNotification ; Whether or not to show the cursor mode notification when in said mode
global ShowPausedNotification ; Whether or not to show the cursor mode notification when the application is paused
global ShowFreeTargetModeNotification ; Whether or not to show the free target notification when in free target mode

global Inventory := false ; This value is true when then Inventory hotkey is triggered, and is toggled by that button. While true, the D-Pad is used to navigate the inventory screen
global InventoryX := 1 ; The X value of the Inventory grid the user is currently on
global InventoryY := 6 ; The Y value of the Inventory grid the user is currently on

; Enum section
global ACTION_INDEX := 		1
global MODIFIER_INDEX := 	2

global PRESS_ACTION := 		1
global PRESS_MODIFIER := 	2
global HOLD_ACTION :=		3
global HOLD_MODIFIER := 	4
global HELD_DURATION := 	5

SetTimer, Startup, 750 ; The 'Init' function of my code essentially. It's at the very bottom.

; Toggles Debug Mode
$F3::
DebugMode := !DebugMode
if(DebugMode)
	Tooltip, Debug mode enabled `nPress F3 to disable, 0, 45, 5
else
{
	Tooltip, , , , 5
	Tooltip, , , , 6
}
return

; Reloades the config values when F5 is pressed
$F5::
Calibrate()
ReadConfig() 
return

; Pauses the script and displays a message indicating so whenever F10 is pressed. The '$' ensures the hotkey can't be triggered with a 'Send' command
$F10::
; Set the tooltip if it should be shown
if(!IsPaused and ShowPausedNotification)
	Tooltip, Paused `nPress F10 to resume, 0, 0, 4
; Remove the tooltip if it is currently shown
else if(ShowPausedNotification)
	Tooltip, , , , 4

IsPaused := !IsPaused	; Toggle the pause boolean
Pause,,1
return

; Closes the program. The '$' ensures the hotkey can't be triggered with a 'Send' command
$F12::
SelectObject(hdc, obm)
DeleteObject(hbm)
DeleteDC(hdc)
Gdip_DeleteGraphics(pGraphics)
Gdip_Shutdown(pToken)
ExitApp
return

; This controls the left analog stick's values and behaviour
WatchAxisL()
{
	global ; All values are global unless stated otherwise
	local CenterX := ScreenCenterX + LRadiusOffsetX, CenterY := ScreenCenterY + LRadiusOffsetY ; Where the circle will originate when it is drawn
	local Angle, AngleDeg ; 'Angle' is the angle in radians that the stick is currently at. 'AngleDeg' is that angle but in degrees.
	local Radius ; The radius of the circle drawn when LStick is false
	
	local LThumbXCenter := LThumbX - LThumbX0 ; This takes the current value of the stick's X and subtracts the value when the stick is at rest to 'zero out' the value before calculations
	local LThumbYCenter := LThumbY - LThumbY0 ; This takes the current value of the stick's Y and subtracts the value when the stick is at rest to 'zero out' the value before calculations
	
	static FirstMovement ; Currently unused. Was for deleting the ToolTip that read "You man begin" once the user moved the stick.
	
	; Checks the deadzone of the stick 
	if (Abs(LThumbXCenter) > LThreshold || Abs(LThumbYCenter) > LThreshold)
	{
		; Pretty much: "If you aren't pressing space, the right stick isn't held or no buttons are pressed down, or I told you to press space specifically"
		if(!Move || ForceMove)
		{
			; "If no buttons are pressed right now"
			if((!Pressed && LStick) || IgnoreIt)
				PressKey(ForceMoveKey)
				
			Move := true ; Don't press space again
			ForceMove = false ; Don't tell me what to do
		}
		; Currently useless function
		if (!IsInitializing && FirstMovement)
		{
			FirstMovement := false
		}		
	}
	; If the stick is currently released
	else
	{
		; If space is held down right now
		if(Move)
		{
			if(!IgnoreIt && LStick)
				ReleaseKey(ForceMoveKey)

			Move := false ; Space can be pressed again
			ForceMove := false ;  Don't tell me what to do
		}
	}

	if(LThumbXCenter < 0 && LThumbYCenter < 0) ; 3rd Quadrant
	{
		AngleDeg := Abs(ATan(LThumbYCenter/LThumbXCenter)*(180/PI)) + 180
	}
	else if(LThumbXCenter < 0 && LThumbYCenter > 0) ; 2nd Quadrant
	{    
		AngleDeg := 180 - Abs(ATan(LThumbYCenter/LThumbXCenter)*(180/PI))
	}
	else if(LThumbXCenter > 0 && LThumbYCenter < 0) ; 4th Quadrant
	{
		AngleDeg := 360 - Abs(ATan(LThumbYCenter/LThumbXCenter)*(180/PI))
	}
	else if (LThumbXCenter = 0 && LThumbYCenter > 0) ; ATan Error would occur since angle is 90
	{
		AngleDeg := 90
	}
	else if (LThumbXCenter = 0 && LThumbYCenter < 0) ; ATan Error would occur since angle is 270
	{
		AngleDeg := 270
	}
	else if (LThumbXCenter < 0 && LThumbYCenter = 0) ; Differentiate between 0 and 180 degrees
	{
		AngleDeg := 180
	}                 
	else ; 1st Quadrant
	{
		AngleDeg := Abs(ATan(LThumbYCenter/LThumbXCenter)*(180/PI))
	}
		
	Angle := -AngleDeg * (PI/180) ; Convert the angle back into radians for calculation
	
	if(LStick)
	{
		; The analog stick returns a lumpy square as movement. With this, I cut a proper square out of it by limiting the furthest the stick is pressed before I stop registering it
		if(Abs(LThumbXCenter) > LMaxThreshold)
		{
			if(LThumbXCenter > 0)
				LThumbXCenter := LMaxThreshold
			else
				LThumbXCenter := -LMaxThreshold
		}
		if(Abs(LThumbYCenter) > LMaxThreshold)
		{
			if(LThumbYCenter > 0)
				LThumbYCenter := LMaxThreshold
			else	
				LThumbYCenter := -LMaxThreshold
		}
		
		; http://math.stackexchange.com/questions/22064/calculating-a-point-that-lies-on-an-ellipse-given-an-angle
		MouseX := (CenterX) + (LMaxRadiusX*LMaxRadiusY)/Sqrt((LMaxRadiusY**2)+(LMaxRadiusX**2)*(tan(Angle)**2))
		MouseY := (CenterY) + (LMaxRadiusX*LMaxRadiusY*tan(Angle))/Sqrt((LMaxRadiusY**2)+(LMaxRadiusX**2)*(tan(Angle)**2))
		
		; Because of the way the calculation goes, whenever the angle is in the 2nd and 3rd quadrant it needs to be translated
		if(AngleDeg > 90 && AngleDeg <= 270)
		{
			MouseX := (CenterX) - (MouseX - CenterX)
			MouseY := (CenterY) - (MouseY - CenterY)
		}
		
		; Pretty much: if no buttons are pressed or the right stick isn't pressed, and the inventory isn't open or space isn't being pressed
		if((!Pressed || (!Target && !ForceTarget)) && (!Inventory || Move))
		{
			if(Move)
				MouseMove, MouseX, MouseY
			else
				MouseMove, ScreenCenterX, ScreenCenterY
		}
		else if((Target || ForceTarget) && Pressed)
		{
			if(Move)
			{
				bufferx := MouseX - ImageW/2
				buffery := MouseY - ImageH/2
				Gui, 1:Show, x%bufferx% y%buffery% NoActivate
			}
			else
			{
				bufferx := ScreenCenterX - ImageW/2
				buffery := ScreenCenterY - ImageH/2
				Gui, 1:Show, x%bufferx% y%buffery% NoActivate
			}
		}
		; Pretty much: if 'ForceMoveKey' isn't being pressed, and the inventory is open
		else if(!Move && Inventory)
			MouseMove, InventoryGridX[InventoryX,InventoryY] * (Width / 1920), InventoryGridY[InventoryX,InventoryY] * (Height / 1080)
		;if(!FirstMovement)
			;ToolTip, %LThumbX% : %LThumbY% `n%LThumbX0% : %LThumbY0% `n%LThumbXCenter% : %LThumbYCenter% - %Radius% `n%AngleDeg% `n%CenterX% : %CenterY% `n%Title% - %ScreenCenterX% : %ScreenCenterY%, 1900, 425
	}
	else
	{
		if(Abs(LThumbXCenter) >= Abs(LThumbYCenter))
			Radius := 20 * ((Abs(LThumbXCenter)-LThreshold)/(LMaxThreshold-LThreshold))
		else
			Radius := 20 * ((Abs(LThumbYCenter)-LThreshold)/(LMaxThreshold-LThreshold))
		
		MouseX := Radius * cos(Angle) * LSensitivityX
		MouseY := Radius * sin(Angle) * LSensitivityY
		
		if(Move)
			MouseMove, MouseX, MouseY, , R
	}

	return  ; Do nothing.
}

WatchAxisR()
{
	global ; All values are global unless stated otherwise
	local CenterX := ScreenCenterX + RRadiusOffsetX, CenterY := ScreenCenterY + RRadiusOffsetY ; Where the circle will originate when it is drawn
	local Angle, AngleDeg ; 'Angle' is the angle in radians that the stick is currently at. 'AngleDeg' is that angle but in degrees.
	local Radius
	
	local RThumbXCenter := RThumbX - RThumbX0 ; This takes the current value of the stick's X and subtracts the value when the stick is at rest to 'zero out' the value before calculations
	local RThumbYCenter := RThumbY - RThumbY0 ; This takes the current value of the stick's Y and subtracts the value when the stick is at rest to 'zero out' the value before calculations
	
	static FirstMovement ; Currently unused. Was for deleting the ToolTip that read "You may begin" once the user moved the stick.
	
	; Checks the deadzone of the stick 
	if (Abs(RThumbXCenter) > RThreshold || Abs(RThumbYCenter) > RThreshold)
	{
		;Makes sure that the target on the screen being present is known to all who may question it
		Target = true
	}
	; If the stick is currently released
	else
	{		
		Target := false
		; Now all shall know that it is hidden, and it was good
		if(RStick)
			Gui, 1:Hide
	}
		
	if(RThumbXCenter < 0 && RThumbYCenter < 0) ; 3rd Quadrant
	{
		AngleDeg := Abs(ATan(RThumbYCenter/RThumbXCenter)*(180/PI)) + 180
	}
	else if(RThumbXCenter < 0 && RThumbYCenter > 0) ; 2nd Quadrant
	{
		AngleDeg := 180 - Abs(ATan(RThumbYCenter/RThumbXCenter)*(180/PI))
	}
	else if(RThumbXCenter > 0 && RThumbYCenter < 0) ; 4th Quadrant
	{
		AngleDeg := 360 - Abs(ATan(RThumbYCenter/RThumbXCenter)*(180/PI))
	}
	else if (RThumbXCenter = 0 && RThumbYCenter > 0) ; ATan Error would occur since angle is 90
	{
		AngleDeg := 90
	}
	else if (RThumbXCenter = 0 && RThumbYCenter < 0) ; ATan Error would occur since angle is 270
	{
		AngleDeg := 270
	}
	else if (RThumbXCenter < 0 && RThumbYCenter = 0) ; Differentiate between 0 and 180 degrees
	{
		AngleDeg := 180
	}
	else ; 1st Quadrant
	{
		AngleDeg := Abs(ATan(RThumbYCenter/RThumbXCenter)*(180/PI))
	}
		
	Angle := AngleDeg * (PI/180) ; Convert the angle back into radians for calculation
	
	if(RStick)
	{
		; The analog stick returns a lumpy square as movement. With this, I cut a proper square out of it by limiting the furthest the stick is pressed before I stop registering it		
		if(Abs(RThumbXCenter) > RMaxThreshold)
		{
			if(RThumbXCenter > 0)
				RThumbXCenter := RMaxThreshold
			else
				RThumbXCenter := -RMaxThreshold
		}
		if(Abs(RThumbYCenter) > RMaxThreshold)
		{
			if(RThumbYCenter > 0)
				RThumbYCenter := RMaxThreshold
			else	
				RThumbYCenter := -RMaxThreshold
		}
			
		; This is where I calculate the X and Y radius of the oval I'm about to draw
		
		;Which ever value is higher (either RThumbXCenter or RThumbYCenter), that value is used to calculate the radii
		if(Abs(RThumbXCenter) >= Abs(RThumbYCenter))
		{
			RadiusX := RMaxRadiusX * ((Abs(RThumbXCenter)-RThreshold)/(RMaxThreshold-RThreshold))
			RadiusY := RMaxRadiusY * ((Abs(RThumbXCenter)-RThreshold)/(RMaxThreshold-RThreshold))
		}
		else
		{
			RadiusX := RMaxRadiusX * ((Abs(RThumbYCenter)-RThreshold)/(RMaxThreshold-RThreshold))
			RadiusY := RMaxRadiusY * ((Abs(RThumbYCenter)-RThreshold)/(RMaxThreshold-RThreshold))
		}
		
		TargetX := (CenterX) + (RadiusX*RadiusY)/Sqrt((RadiusY**2)+(RadiusX**2)*(tan(Angle)**2))
		TargetY := (CenterY) +(RadiusX*RadiusY*tan(-Angle))/Sqrt((RadiusY**2)+(RadiusX**2)*(tan(-Angle)**2))
		
		; Because of the way the calculation goes, whenever the angle is in the 2nd and 3rd quadrant it needs to be translated
		if(AngleDeg > 90 && AngleDeg <= 270)
		{
			TargetX := (CenterX) - (TargetX - CenterX)
			TargetY := (CenterY) - (TargetY - CenterY)
		}
		
		; Pretty much: if the right stick is currently held, and a button is currently pressed
		if(Target && Pressed)
			MouseMove, TargetX, TargetY ; The right stick is now used for moving the cursor instead of the left one
		
		if(!FirstMovement)
		{
			;ToolTip, %RThumbX% : %RThumbY% `n%RThumbX0% : %RThumbY0% `n%RThumbXCenter% : %RThumbYCenter% `n%RadiusX% : %RadiusY% `n%AngleDeg% %Angle% `n%TargetX% %TargetY% `n%Title% - %ScreenCenterX% : %ScreenCenterY% `n%Pressed%, 1900, 510, 2
			; Pretty Much: if the right stick is currently held, and no buttons are being pressed
			if(Target && !Pressed)
			{
				CurrentTargetX := TargetX - ImageW/2
				CurrentTargetY := TargetY - ImageH/2

				Gui, 1:Show, x%CurrentTargetX% y%CurrentTargetY% NoActivate
			}
		}
	}
	else
	{
		if(Abs(RThumbXCenter) >= Abs(RThumbYCenter))
			Radius := 20 * ((Abs(RThumbXCenter)-RThreshold)/(RMaxThreshold-RThreshold))
		else
			Radius := 20 * ((Abs(RThumbYCenter)-RThreshold)/(RMaxThreshold-RThreshold))
		
		TargetDeltaX := Radius * cos(Angle) * RSensitivityX
		TargetDeltaY := Radius * sin(Angle) * RSensitivityY
		
		if(Target)
		{
			TargetX := TargetX + TargetDeltaX
			TargetY := TargetY - TargetDeltaY
		}

		bufferx := TargetX - ImageW/2
		buffery := TargetY - ImageH/2 

		if(Pressed)
			MouseMove, TargetX, TargetY
		else
			Gui, 1:Show, x%bufferx% y%buffery% NoActivate		
	}

	return  ; Do nothing.
}

TriggerState:

Loop, 4 
{
    if State := XInput_GetState(A_Index-1) 
	{
		LTrigger := State.LeftTrigger
		RTrigger := State.RightTrigger 
		
		Buttons[AButton] := State.Buttons & XINPUT_GAMEPAD_A
		Buttons[BButton] := State.Buttons & XINPUT_GAMEPAD_B
		Buttons[XButton] := State.Buttons & XINPUT_GAMEPAD_X
		Buttons[YButton] := State.Buttons & XINPUT_GAMEPAD_Y
		
		Buttons[UpButton] := State.Buttons & XINPUT_GAMEPAD_DPAD_UP
		Buttons[DownButton] := State.Buttons & XINPUT_GAMEPAD_DPAD_DOWN
		Buttons[LeftButton] := State.Buttons & XINPUT_GAMEPAD_DPAD_LEFT
		Buttons[RightButton] := State.Buttons & XINPUT_GAMEPAD_DPAD_RIGHT
		
		Buttons[StartButton] := State.Buttons & XINPUT_GAMEPAD_START
		Buttons[BackButton] := State.Buttons & XINPUT_GAMEPAD_BACK
		
		Buttons[LShoulderButton] := State.Buttons & XINPUT_GAMEPAD_LEFT_SHOULDER
		Buttons[RShoulderButton] := State.Buttons & XINPUT_GAMEPAD_RIGHT_SHOULDER
		
		Buttons[LThumbButton] := State.Buttons & XINPUT_GAMEPAD_LEFT_THUMB
		Buttons[RThumbButton] := State.Buttons & XINPUT_GAMEPAD_RIGHT_THUMB
		
		LThumbX := State.ThumbLX
		LThumbY := State.ThumbLY
		
		RThumbX := State.ThumbRX
		RThumbY := State.ThumbRY
    }
}

if(!IsInitializing) 
{
	WinGetActiveStats, Title, Width, Height, X, Y
	
	ScreenCenterX := Width / 2
	ScreenCenterY := Height / 2
	; if the Diablo window is active then the center of the screen is a lot higher than normal. This sets it to that value.
	IfWinActive, %ApplicationName%
	{
		ScreenCenterX := ScreenCenterX + CenterOffsetX
		ScreenCenterY := ScreenCenterY + CenterOffsetY
	}
	
	if(LThumbX != PrevLThumbX || LThumbY != PrevLThumbY || ForceMove)
		WatchAxisL()
	if(RThumbX != PrevRThumbX || RThumbY != PrevRThumbY || ForceTarget)
		WatchAxisR()
	Gosub WatchAxisT
	GoSub WatchButtons
	;ToolTip, ForceMove = %ForceMove% Move = %Move% `nPressed = %Pressed% `nIgnoreIt = %IgnoreIt% IgnorePress = %IgnorePress% `nForceMoveKey = %ForceMoveKey%, 0, 0
}
  
PrevLTrigger := LTrigger
PrevRTrigger := RTrigger 

PrevButtons[AButton] := Buttons[AButton]
PrevButtons[BButton] := Buttons[BButton]
PrevButtons[XButton] := Buttons[XButton]
PrevButtons[YButton] := Buttons[YButton]

PrevButtons[UpButton] := Buttons[UpButton]
PrevButtons[DownButton] := Buttons[DownButton]
PrevButtons[LeftButton] := Buttons[LeftButton]
PrevButtons[RightButton] := Buttons[RightButton]

PrevButtons[StartButton] := Buttons[StartButton]
PrevButtons[BackButton] := Buttons[BackButton]

PrevButtons[LShoulderButton] := Buttons[LShoulderButton]
PrevButtons[RShoulderButton] := Buttons[RShoulderButton]

PrevButtons[LThumbButton] := Buttons[LThumbButton]
PrevButtons[RThumbButton] := Buttons[RThumbButton]

PrevLThumbX := LThumbX
PrevLThumbY := LThumbY

PrevRThumbX := RThumbX
PrevRThumbY := RThumbY

if(DebugMode)
	ToolTip, Debug Log: `n%DebugLog%, 0, 90, 6

return
; /TriggerState

WatchAxisT:

if(LTrigger != PrevLTrigger)
{ 
	if (LTrigger > TThreshold && PrevLTrigger <= TThreshold) ;Left trigger is held
		ActionDown(LTriggerKey[ACTION_INDEX], LTriggerKey[MODIFIER_INDEX])
	if (LTrigger <= TThreshold && PrevLTrigger > TThreshold) ;Left is released
		ActionUp(LTriggerKey[ACTION_INDEX], LTriggerKey[MODIFIER_INDEX], false)
}
if(RTrigger != PrevRTrigger)
{ 
	if (RTrigger > TThreshold && PrevRTrigger <= TThreshold) ;Right trigger is held
		ActionDown(RTriggerKey[ACTION_INDEX],RTriggerKey[MODIFIER_INDEX])
	if (RTrigger <= TThreshold && PrevRTrigger > TThreshold) ;Right is released
		ActionUp(RTriggerKey[ACTION_INDEX], RTriggerKey[MODIFIER_INDEX], false)
}

return ; Do nothing.

WatchButtons:

Loop, 14
{
	if(!IsInitializing)
	{
		isPressSpecialKey := (ButtonKey[A_Index][PRESS_ACTION] = "Loot" or ButtonKey[A_Index][PRESS_ACTION] = "Freedom" or ButtonKey[A_Index][PRESS_ACTION] = "FreeTarget" or ButtonKey[A_Index][PRESS_ACTION] = "Inventory")
		isHoldSpecialKey := (ButtonKey[A_Index][HOLD_ACTION] = "Loot" or ButtonKey[A_Index][HOLD_ACTION] = "Freedom" or ButtonKey[A_Index][HOLD_ACTION] = "FreeTarget" or ButtonKey[A_Index][HOLD_ACTION] = "Inventory")

		if(Buttons[A_Index] != PrevButtons[A_Index])
		{
			; The first frame a button is pressed
			if(Buttons[A_Index])
			{
				; If the button has a 'HOLD_ACTION'
				if(ButtonKey[A_Index][HOLD_ACTION])				
					ButtonKey[A_Index][HELD_DURATION] := A_TickCount
				else if(isPressSpecialKey)
				{				
					if(ButtonKey[A_Index][PRESS_ACTION] = "Loot")
						SetTimer, SpamLoot, %LootDelay%
					else if(ButtonKey[A_Index][PRESS_ACTION] = "Freedom")
						ToggleCursorMode()
					else if(ButtonKey[A_Index][PRESS_ACTION] = "FreeTarget")
						ToggleFreeTargetMode()
					else if(ButtonKey[A_Index][PRESS_ACTION] = "Inventory")
						ToggleInventoryMode()

					if(ButtonKey[A_Index][PRESS_MODIFIER])
						ActionDown(ButtonKey[A_Index][PRESS_MODIFIER], "")
				}
				else
					ActionDown(ButtonKey[A_Index][PRESS_ACTION], ButtonKey[A_Index][PRESS_MODIFIER])
			}
			; The first frame after a button was held long enough to trigger the 'HOLD_ACTION' and then released
			else if(ButtonKey[A_Index][HOLD_ACTION] && ButtonKey[A_Index][HELD_DURATION] = 0)
			{
				if(isHoldSpecialKey && ButtonKey[A_Index][HOLD_MODIFIER])
					ActionUp(ButtonKey[A_Index][HOLD_MODIFIER], "", false)
				else if(ButtonKey[A_Index][HOLD_ACTION] = "Loot")
					SetTimer, SpamLoot, Off
				else
					ActionUp(ButtonKey[A_Index][HOLD_ACTION], ButtonKey[A_Index][HOLD_MODIFIER], false)
			}
			; The frame a button is released but did not trigger the 'HOLD_ACTION'
			else
			{
				if(Inventory &&(A_Index >= UpButton && A_Index <= RightButton))
				{
					ForceInventory := false
					Button_Index := A_Index
					Loop
					{
						PrevInventoryX := InventoryX
						PrevInventoryY := InventoryY
					
						if(Button_Index = 5)
						{
							if((InventoryX > 4 || InventoryY > 2) && InventoryY != 1)
							{
								InventoryY -= 1
								if(InventoryGridX[PrevInventoryX,PrevInventoryY] != InventoryGridX[InventoryX,InventoryY] || InventoryGridY[PrevInventoryX,PrevInventoryY] != InventoryGridY[InventoryX,InventoryY])
									ForceInventory := true
							}
							else 
								ForceInventory := true
						}
						if(Button_Index = 6)
						{
							if(InventoryY != 11)
							{
								InventoryY += 1
								if(InventoryGridX[PrevInventoryX,PrevInventoryY] != InventoryGridX[InventoryX,InventoryY] || InventoryGridY[PrevInventoryX,PrevInventoryY] != InventoryGridY[InventoryX,InventoryY])
									ForceInventory := true
							}
							else
								ForceInventory := true
						}
						if(Button_Index = 7)
						{
							if((InventoryX > 4 || InventoryY > 5) && InventoryX != 1)
							{
								InventoryX -= 1
								if(InventoryGridX[PrevInventoryX,PrevInventoryY] != InventoryGridX[InventoryX,InventoryY] || InventoryGridY[PrevInventoryX,PrevInventoryY] != InventoryGridY[InventoryX,InventoryY])
									ForceInventory := true
							}
							else 
								ForceInventory := true
						}	
						if(Button_Index = 8)
						{
							if(InventoryX != 10)
							{
								InventoryX += 1
								if(InventoryGridX[PrevInventoryX,PrevInventoryY] != InventoryGridX[InventoryX,InventoryY] || InventoryGridY[PrevInventoryX,PrevInventoryY] != InventoryGridY[InventoryX,InventoryY])
									ForceInventory := true
							}
							else
								ForceInventory := true
						}
					}Until ForceInventory
					
					if(InventoryGridX[PrevInventoryX,PrevInventoryY] != InventoryGridX[InventoryX,InventoryY] || InventoryGridY[PrevInventoryX,PrevInventoryY] != InventoryGridY[InventoryX,InventoryY])
						MouseMove, InventoryGridX[InventoryX,InventoryY] * (Width / 1920), InventoryGridY[InventoryX,InventoryY] * (Height / 1080)
					else
					{
						InventoryX := PrevInventoryX
						InventoryY := PrevInventoryY
					}
				}
				else if(ButtonKey[A_Index][PRESS_ACTION] = "Loot")
					SetTimer, SpamLoot, Off
				else if(isPressSpecialKey)
				{
					if(ButtonKey[A_Index][HOLD_ACTION])
					{
						if(ButtonKey[A_Index][PRESS_ACTION] = "Freedom")
							ToggleCursorMode()
						else if(ButtonKey[A_Index][PRESS_ACTION] = "FreeTarget")
							ToggleFreeTargetMode()
						else if(ButtonKey[A_Index][PRESS_ACTION] = "Inventory")
							ToggleInventoryMode()
					}
					
					if(ButtonKey[A_Index][PRESS_MODIFIER])
						ActionUp(ButtonKey[A_Index][PRESS_MODIFIER], "", ButtonKey[A_Index][HOLD_ACTION])
				}
				else
					ActionUp(ButtonKey[A_Index][PRESS_ACTION], ButtonKey[A_Index][PRESS_MODIFIER], ButtonKey[A_Index][HOLD_ACTION])
			}	
		}
		else if(ButtonKey[A_Index][HOLD_ACTION] && Buttons[A_Index] && ButtonKey[A_Index][HELD_DURATION] && A_TickCount >= ButtonKey[A_Index][HELD_DURATION] + Delay)    
		{
			Loop, 4 
			{ 
				if XInput_GetState(A_Index-1)
					XInput_SetState(A_Index-1, VibeStrength, VibeStrength) ;MAX 65535
			}
			SetTimer, VibeOff, %VibeDuration%

			if(ButtonKey[A_Index][HOLD_ACTION] = "Loot")
				SetTimer, SpamLoot, %LootDelay%
			else if(ButtonKey[A_Index][HOLD_ACTION] = "Freedom")
				ToggleCursorMode()
			else if(ButtonKey[A_Index][HOLD_ACTION] = "FreeTarget")
				ToggleFreeTargetMode()
			else if(ButtonKey[A_Index][HOLD_ACTION] = "Inventory")
				ToggleInventoryMode()
			else
				ActionDown(ButtonKey[A_Index][HOLD_ACTION], ButtonKey[A_Index][HOLD_MODIFIER])

			if(ButtonKey[A_Index][PRESS_MODIFIER])
				ActionDown(ButtonKey[A_Index][HOLD_MODIFIER], "")

			ButtonKey[A_Index][HELD_DURATION] := 0
		}
	}
	else
		ButtonKey[A_Index][HELD_DURATION] := 0
}

return
; /WatchButtons

ActionDown(Action, Modifier)
{
	local skip := false

	if (UsesMouse[1])
	{
		local found := false

		Loop
		{
			if(Action = UsesMouse[A_Index][ACTION_INDEX] && Modifier = UsesMouse[A_Index][MODIFIER_INDEX])
			{
				found := true
				break					
			}
		} Until !UsesMouse[A_Index+1]

		if (found && IgnoreTarget[1])
		{
			Loop
			{
				if(Action = IgnoreTarget[A_Index][ACTION_INDEX] && Modifier = IgnoreTarget[A_Index][MODIFIER_INDEX])
				{
					ReleaseKey(ForceMoveKey)
					ForceMoveKey := Array(Action, Modifier)
					
					local tempX, local tempY
					if(Pressed > 0)
					{						
						MouseGetPos, tempX, tempY
						MouseMove, MouseX, MouseY

						if(TargetingDelay > 0)
							Sleep, %TargetingDelay%
					}

					PressKey(ForceMoveKey)

					if(Pressed > 0)
						MouseMove, tempX, tempY

					Move := false
					ForceMove := true
					IgnoreIt := true
					IgnorePressed += 1

					skip := true
					break
				}
			} Until !IgnoreTarget[A_Index+1]			
		}

		if(!found)
		{
			PressKey(Array(Action, Modifier))

			skip := true
		}
	}

	if(!skip)
			TargetActionDown(Action, Modifier)
}
ActionUp(Action, Modifier, HasHoldAction)
{
	local skip := false
	
	if (UsesMouse[1])
	{
		local found := false

		Loop
		{
			if(Action = UsesMouse[A_Index][ACTION_INDEX] && Modifier = UsesMouse[A_Index][MODIFIER_INDEX])
			{
				found := true
				break
			}
		} Until !UsesMouse[A_Index+1]

		if (found && IgnoreTarget[1])
		{
			Loop
			{
				if(Action = IgnoreTarget[A_Index][ACTION_INDEX] && Modifier = IgnoreTarget[A_Index][MODIFIER_INDEX])
				{
					if (HasHoldAction)
					{
						local tempX, local tempY
						MouseGetPos, tempX, tempY
						MouseMove, MouseX, MouseY

						if(TargetingDelay > 0)
							Sleep, %TargetingDelay%

						PressKey(Array(Action, Modifier))
						ReleaseKey(Array(Action, Modifier))

						MouseMove, tempX, tempY
					}
					else
					{
						ReleaseKey(Array(Action, Modifier))

						IgnorePressed -= 1
						IgnoreIt := false
						ForceMoveKey := DefaultForceMoveKey ; Set force move back to the default key
					}

					skip := true
					break
				}
			} Until !IgnoreTarget[A_Index+1]
		}

		if(!found)
		{
			if(HasHoldAction)
				PressKey(Array(Action, Modifier))

			ReleaseKey(Array(Action, Modifier))	

			skip := true
		}
	}

	if (!skip)
	{
		if(HasHoldAction)
			TargetActionDown(Action, Modifier)		

		TargetActionUp(Action, Modifier)
	}
}

TargetActionDown(Action, Modifier)
{
	if(Pressed = 0)
	{
		MouseGetPos, PrevMouseX, PrevMouseY
		if(Target || ForceTarget)
			Gui, 1:Hide

		;Move := false
		ReleaseKey(ForceMoveKey)
	}
	
	Pressed += 1
	if(Target || ForceTarget)
	{
		IgnoreIt := false
		MouseMove, TargetX, TargetY

		if(TargetingDelay > 0)
			Sleep, %TargetingDelay%
	}
	
	PressKey(Array(Action, Modifier))	
	return ; Do nothing
}
TargetActionUp(Action, Modifier)
{ 
	Pressed -= 1	
	ReleaseKey(Array(Action, Modifier))
	
	if(Pressed = 0)
	{
		Move := false
		ForceMove := true
		ReleaseKey(ForceMove)
		MouseMove, PrevMouseX, PrevMouseY
		
		if(Target || ForceTarget)
		{
			bufferx := TargetX - ImageW/2
			buffery := TargetY - ImageH/2
			Gui, 1:Show, x%bufferx% y%buffery% NoActivate
		}
	}
	return ; Do nothing
}

PressKey(Key)
{
	local Action := Key[ACTION_INDEX]
	local Modifier := Key[MODIFIER_INDEX]

	;AddToDebugLog("Pressing " . Action " + " . Modifier)

	if(Modifier)
		Send {%Modifier% Down}
	Send {%Action% Down}
}
ReleaseKey(Key)
{
	local Action := Key[ACTION_INDEX]
	local Modifier := Key[MODIFIER_INDEX]

	;AddToDebugLog("Pressing " . Action " + " . Modifier)
	
	Send {%Action% Up}
	if(Modifier)
		Send {%Modifier% Up}
}

ToggleCursorMode()
{
	if(LStick)
		EnableCursorMode()
	else
		DisableCursorMode()
}
EnableCursorMode()
{		
	global
	DisableInventoryMode()

	if(ShowCursorModeNotification)
	{
		local newButtonInfo := FindButtonString(Array("Freedom"))
		local buffer := newButtonInfo[1] . " " . newButtonInfo[2]

		ToolTip, Cursor Mode: Enabled `n%buffer% on the controller to disable, 0, 0
	}

	LStick := false
}
DisableCursorMode()
{
	if(ShowCursorModeNotification)
		ToolTip

	LStick := true
}

ToggleFreeTargetMode()
{
	if(RStick)
		EnableFreeTargetMode()
	else
		DisableFreeTargetMode()
}
EnableFreeTargetMode()
{
	global
	if(ShowFreeTargetModeNotification)
	{
		local newButtonInfo := FindButtonString(Array("FreeTarget"))
		local buffer := newButtonInfo[1] . " " . newButtonInfo[2]

		Tooltip, Free Target Mode: Enabled `n%buffer% on the controller to disable, 0, 40, 2
	}

	ForceTarget := true
	RStick := false
}
DisableFreeTargetMode()
{
	if(ShowFreeTargetModeNotification)
		ToolTip, , , , 2

	ForceTarget := false
	RStick := true
}

ToggleInventoryMode()
{
	if(!Inventory)
		EnableInventoryMode()
	else
		DisableInventoryMode()
}
EnableInventoryMode()
{
	global 
	DisableCursorMode()

	Inventory := true

	Loop, 4
	{
		local temp := ButtonKey[A_Index+4][PRESS_ACTION]
		ButtonKey[A_Index+4][PRESS_ACTION] := ButtonKey[A_Index+4][HOLD_ACTION]
		ButtonKey[A_Index+4][HOLD_ACTION] := temp
	}

	if(ShowInventoryModeNotification)
	{
		local newButtonInfo := FindButtonString(Array("Inventory"))
		local buffer := newButtonInfo[1] . " " . newButtonInfo[2]

		ToolTip, Inventory Mode: Enabled `n%buffer% on the controller to disable, 0, 0
	}

	MouseMove, InventoryGridX[InventoryX,InventoryY], InventoryGridY[InventoryX,InventoryY]
	Gui, 1:Hide
}
DisableInventoryMode()
{
	global
	Inventory := false

	Loop, 4
	{
		local temp := ButtonKey[A_Index+4][PRESS_ACTION]
		ButtonKey[A_Index+4][PRESS_ACTION] := ButtonKey[A_Index+4][HOLD_ACTION]
		ButtonKey[A_Index+4][HOLD_ACTION] := temp
	}

	if(ShowInventoryModeNotification)	
		ToolTip
}

AddToDebugLog(NewText)
{
	DebugLog := DebugLog . "`n" . NewText
}

FindButtonString(Key)
{
	local newButtonInfo := Array()
	Loop, 14
	{
		
		if(ButtonKey[A_Index][PRESS_ACTION] = Key[ACTION_INDEX] && ButtonKey[A_Index][PRESS_MODIFIER] = Key[MODIFIER_INDEX])
		{
			newButtonInfo[1] := "Press"
			newButtonInfo[2] := ButtonString[A_Index]
			break
		}

		if(ButtonKey[A_Index][HOLD_ACTION] = Key[ACTION_INDEX] && ButtonKey[A_Index][HOLD_MODIFIER] = Key[MODIFIER_INDEX])
		{
			newButtonInfo[1] := "Hold"
			newButtonInfo[2] := ButtonString[A_Index]
			break
		}
	}

	if(!newButtonInfo[1])
	{
		AddToDebugLog("Couldn't find a matching button. Attempting again but with no modifier.")

		Loop, 14
		{
			
			if(ButtonKey[A_Index][PRESS_ACTION] = Key[ACTION_INDEX])
			{
				newButtonInfo[1] := "Press"
				newButtonInfo[2] := ButtonString[A_Index]
				break
			}

			if(ButtonKey[A_Index][HOLD_ACTION] = Key[ACTION_INDEX])
			{
				newButtonInfo[1] := "Hold"
				newButtonInfo[2] := ButtonString[A_Index]
				break
			}
		}
	}

	return newButtonInfo
}

InventoryInit()
{
	global
	Loop, 4
	{
		local temp := ButtonKey[A_Index+4][PRESS_ACTION]
		ButtonKey[A_Index+4][PRESS_ACTION] := ButtonKey[A_Index+4][HOLD_ACTION]
		ButtonKey[A_Index+4][HOLD_ACTION] := temp
	}	
}

Calibrate()
{
	global
	
	local MaxL := 32767, MaxR := 32767, Button, buffer
	
	IniRead, buffer, %ConfigurationPath%, Calibration, Calibrate
	if(!%buffer%)
		return ; Calibrate is false	
	
	MsgBox, , Calibration, Since this appears to be your first time using my program, I will be calibrating your controller for use with it.
	MsgBox, , Instructions, To begin, I need to determine the range that your controller is able to move at.`n`nMove both the Left *and* Right analog stick straight up at the same time. Then move them both in a circle (whatever direction you feel comfortable) multiple times. Then press any button while STILL HOLDING THEM UPWARDS.
	
	Loop
	{
		Loop, 4 
		{
			if State := XInput_GetState(A_Index-1) 
			{					
				LThumbX := State.ThumbLX
				LThumbY := State.ThumbLY
		
				RThumbX := State.ThumbRX
				RThumbY := State.ThumbRY
			}
		}
	}Until LThumbY = 32767 && RThumbY = 32767 
	
	Loop
	{
		Loop, 4 
		{
			if State := XInput_GetState(A_Index-1) 
			{
				Button := State.Buttons
				
				LThumbX := State.ThumbLX
				LThumbY := State.ThumbLY
		
				RThumbX := State.ThumbRX
				RThumbY := State.ThumbRY
			}
		} 
		if(Abs(LThumbX) < MaxL && Abs(LThumbX) >= Abs(LThumbY))
			MaxL := Abs(LThumbX)
		if(Abs(LThumbY) < MaxL && Abs(LThumbY) > Abs(LThumbX))
			MaxL := Abs(LThumbY)
		if(Abs(RThumbX) < MaxR && Abs(RThumbX) >= Abs(RThumbY))
			MaxR := Abs(RThumbX)
		if(Abs(RThumbY) < MaxR && Abs(RThumbY) > Abs(RThumbX))
			MaxR := Abs(RThumbY)
	}Until Button
	
	LMaxThreshold := MaxL - 1000
	RMaxThreshold := MaxR - 1000
	
	MsgBox, , Instructions, Now I need to determine where the sticks rest when you aren't pressing them.`n`nMove both sticks around a bunch in random directions, then do not touch them at all. Once they are completely still, press any button on the controller.
	
	Button := 0
	Loop
	{
		Loop, 4 
		{
			if State := XInput_GetState(A_Index-1) 
			{
				Button := State.Buttons
			}
		}
	}Until Button
	
	Loop, 4 
	{
		if State := XInput_GetState(A_Index-1) 
		{					
			LThumbX := State.ThumbLX
			LThumbY := State.ThumbLY
	
			RThumbX := State.ThumbRX
			RThumbY := State.ThumbRY
		}
	}
	LThumbX0 := LThumbX
	LThumbY0 := LThumbY
	
	RThumbX0 := RThumbX
	RThumbY0 := RThumbY
	
	MsgBox, , Calibration Complete, That concludes the calibration. `n`nIf for any reason you think these values  are incorrect, you can either edit them yourself (not recommended) or set 'Calibrate = true' in %ConfigurationPath% to 'true' to run this again.
	
	IniWrite, false, %ConfigurationPath%, Calibration, Calibrate
	
	IniWrite, %MaxL%, %ConfigurationPath%, Calibration, Left_Analog_Max
	IniWrite, %MaxR%, %ConfigurationPath%, Calibration, Right_Analog_Max
	
	IniWrite, %LThumbX0%, %ConfigurationPath%, Calibration, Left_Analog_XZero
	IniWrite, %LThumbY0%, %ConfigurationPath%, Calibration, Left_Analog_YZero
	
	IniWrite, %RThumbX0%, %ConfigurationPath%, Calibration, Right_Analog_XZero
	IniWrite, %RThumbY0%, %ConfigurationPath%, Calibration, Right_Analog_YZero
}

ReadConfig()
{
	; Set Profile Path
	IniRead, ProfilePath, %ConfigurationPath%, Other, Profile_Location
	ProfilePath = %A_WorkingDir% %ProfilePath%
	
	global ButtonKey := Array()
	
	global LTriggerKey := PassKeys("Left_Trigger")
	global RTriggerKey := PassKeys("Right_Trigger")
	
	ButtonKey[AButton] := PassKeys("A_Button")
	ButtonKey[BButton] := PassKeys("B_Button")
	ButtonKey[XButton] := PassKeys("X_Button")
	ButtonKey[YButton] := PassKeys("Y_Button")
	
	ButtonKey[UpButton] := PassKeys("D-Pad_Up")
	ButtonKey[DownButton] := PassKeys("D-Pad_Down")
	ButtonKey[LeftButton] := PassKeys("D-Pad_Left")
	ButtonKey[RightButton] := PassKeys("D-Pad_Right")
	
	ButtonKey[StartButton] := PassKeys("Start_Button")
	ButtonKey[BackButton] := PassKeys("Back_Button")
	
	ButtonKey[LShoulderButton] := PassKeys("Left_Shoulder")
	ButtonKey[RShoulderButton] := PassKeys("Right_Shoulder")
	
	ButtonKey[LThumbButton] := PassKeys("Left_Analog_Button")
	ButtonKey[RThumbButton] := PassKeys("Right_Analog_Button")

	IniRead, temp, %ProfilePath%, Buttons, Force_Move
	DefaultForceMoveKey := ParseKeyBinding(temp)
	ForceMoveKey := DefaultForceMoveKey

	global UsesMouse := Array()
	IniRead, temp, %ProfilePath%, Buttons, Uses_Mouse
	
	Loop
	{
		;AddToDebugLog("temp = " . temp)

		; 'i' will be the position in the string that a comma was found
		; if there is no comma, 'i' will be 0
		i := InStr(temp,", ")
		
		; If a comma was found in the string
		if(i)
		{
			UsesMouse[A_Index] := ParseKeyBinding(SubStr(temp, 1, i - 1))
			temp := SubStr(temp, i + 1)			
		}
		else
		{
			UsesMouse[A_Index] := ParseKeyBinding(temp)
			break
		}

		;AddToDebugLog("UsesMouse[" . A_Index . "] is: " . UsesMouse[A_Index][ACTION_INDEX] . " " . UsesMouse[A_Index][MODIFIER_INDEX])
		
	}Until false

	global IgnoreTarget := Array()	
	IniRead, temp, %ProfilePath%, Buttons, Ignore_Target
	
	Loop
	{
		; 'i' will be the position in the string that a comma was found
		; if there is no comma, 'i' will be 0
		i := InStr(temp,", ")
		
		; If a comma was found in the string
		if(i)
		{
			IgnoreTarget[A_Index] := ParseKeyBinding(SubStr(temp, 1, i - 1))
			temp := SubStr(temp, i + 1)			
		}
		else
		{
			IgnoreTarget[A_Index] := ParseKeyBinding(temp)
			break
		}
		
		;AddToDebugLog("IgnoreTarget[" . A_Index . "] is: " . IgnoreTarget[A_Index][ACTION_INDEX] . " " . IgnoreTarget[A_Index][MODIFIER_INDEX])
		
	}Until false
	
	IniRead, LMaxThreshold, %ConfigurationPath%, Calibration, Left_Analog_Max
	IniRead, RMaxThreshold, %ConfigurationPath%, Calibration, Right_Analog_Max
	
	IniRead, LThumbX0, %ConfigurationPath%, Calibration, Left_Analog_XZero
	IniRead, LThumbY0, %ConfigurationPath%, Calibration, Left_Analog_YZero
	
	IniRead, RThumbX0, %ConfigurationPath%, Calibration, Right_Analog_XZero
	IniRead, RThumbY0, %ConfigurationPath%, Calibration, Right_Analog_YZero
	
	IniRead, ApplicationName, %ProfilePath%, Preferences, Application_Name

	IniRead, ShowCursorModeNotification, %ProfilePath%, Preferences, Show_Cursor_Mode_Notification
	ShowCursorModeNotification := %ShowCursorModeNotification%

	IniRead, ShowFreeTargetModeNotification, %ProfilePath%, Preferences, Show_FreeTarget_Mode_Notification
	ShowFreeTargetModeNotification := %ShowFreeTargetModeNotification%

	IniRead, ShowInventoryModeNotification, %ProfilePath%, Preferences, Show_Inventory_Mode_Notification
	ShowInventoryModeNotification := %ShowInventoryModeNotification%

	IniRead, ShowPausedNotification, %ProfilePath%, Preferences, Show_Paused_Notification
	ShowPausedNotification := %ShowPausedNotification%

	IniRead, LootDelay, %ProfilePath%, Preferences, Loot_Delay
	IniRead, TargetingDelay, %ProfilePath%, Preferences, Targeting_Delay	

	IniRead, VibeStrength, %ProfilePath%, Preferences, Vibration_Strength
	IniRead, VibeDuration, %ProfilePath%, Preferences, Vibration_Duration
	IniRead, Delay, %ProfilePath%, Preferences, Hold_Delay

	IniRead, temp, %ProfilePath%, Preferences, Cursor_Mode_At_Start
	temp := %temp%
	if(temp)
		EnableCursorMode()

	IniRead, temp, %ProfilePath%, Preferences, FreeTarget_Mode_At_Start
	temp := %temp%
	if(temp)
		EnableFreeTargetMode()
	
	IniRead, LMaxRadiusX, %ProfilePath%, Analog Stick, Left_Analog_XRadius
	IniRead, LMaxRadiusY, %ProfilePath%, Analog Stick, Left_Analog_YRadius
	
	IniRead, LThreshold, %ProfilePath%, Analog Stick, Left_Analog_Deadzone
	
	IniRead, RMaxRadiusX, %ProfilePath%, Analog Stick, Right_Analog_XRadius
	IniRead, RMaxRadiusY, %ProfilePath%, Analog Stick, Right_Analog_YRadius
	
	IniRead, RThreshold, %ProfilePath%, Analog Stick, Right_Analog_Deadzone
	
	IniRead, CenterOffsetX, %ProfilePath%, Analog Stick, Center_XOffset
	IniRead, CenterOffsetY, %ProfilePath%, Analog Stick, Center_YOffset
	
	IniRead, LRadiusOffsetX, %ProfilePath%, Analog Stick, Left_Analog_Center_XOffset
	IniRead, LRadiusOffsetY, %ProfilePath%, Analog Stick, Left_Analog_Center_YOffset
	
	IniRead, RRadiusOffsetX, %ProfilePath%, Analog Stick, Right_Analog_Center_XOffset
	IniRead, RRadiusOffsetY, %ProfilePath%, Analog Stick, Right_Analog_Center_YOffset	

	IniRead, LSensitivityX, %ProfilePath%, Analog Stick, Left_Analog_Cursor_XSensitivity
	IniRead, LSensitivityY, %ProfilePath%, Analog Stick, Left_Analog_Cursor_YSensitivity

	IniRead, RSensitivityX, %ProfilePath%, Analog Stick, Right_Analog_Cursor_XSensitivity
	IniRead, RSensitivityY, %ProfilePath%, Analog Stick, Right_Analog_Cursor_YSensitivity
}
PassKeys(ButtonName)
{	
	local key
	IniRead, key, %ProfilePath%, Buttons, %ButtonName%

	local newKeyBinding := Array()
	
	; Returns an error when the requested button is not in the current profile
	if key = ERROR
		return ERROR

	commaPos := InStr(key,",")
	
	local tempKeyBinding := Array()
	if(commaPos)
	{	
		tempKeyBinding := ParseKeyBinding(SubStr(key, 1, commaPos - 1))
		newKeyBinding[1] := tempKeyBinding[1]
		newKeyBinding[2] := tempKeyBinding[2]

		tempKeyBinding := ParseKeyBinding(SubStr(key, commaPos + 1))
		newKeyBinding[3] := tempKeyBinding[1]
		newKeyBinding[4] := tempKeyBinding[2]	
	}
	else 
	{
		tempKeyBinding := ParseKeyBinding(key)
		newKeyBinding[1] := tempKeyBinding[1]
		newKeyBinding[2] := tempKeyBinding[2]
	}
	
	;AddToDebugLog("Key " . key . " parsed as [1]-" . newKeyBinding[1] " [2]-" . newKeyBinding[2] " [3]-" . newKeyBinding[3] " [4]-" . newKeyBinding[4])

	return newKeyBinding
}

ParseKeyBinding(Key)
{
	local newKeyBinding := Array()

	Key := Trim(Key)
	plusPos := InStr(Key,"+") 

	if(plusPos)
	{
		newKeyBinding[ACTION_INDEX] := SubStr(Key, plusPos+1)
		newKeyBinding[MODIFIER_INDEX] := SubStr(Key, 1, plusPos-1)
	}
	else
		newKeyBinding[ACTION_INDEX] := SubStr(Key, 1)

	return newKeyBinding
}

SpamLoot:
MouseGetPos, PrevX, PrevY
MouseMove, ScreenCenterX, ScreenCenterY
Send {LButton Down}
Send {LButton Up}
MouseMove, PrevX, PrevY
return

VibeOff:
Loop, 4 
{ 
	if XInput_GetState(A_Index-1)
		XInput_SetState(A_Index-1, 0, 0) ;MAX 65535
}
SetTimer, VibeOff, Off
return

Startup:
global AButton := 1
global BButton := 2
global XButton := 3
global YButton := 4

global UpButton := 5
global DownButton := 6
global LeftButton := 7
global RightButton := 8

global StartButton := 9
global BackButton := 10

global LShoulderButton := 11
global RShoulderButton := 12

global LThumbButton := 13
global RThumbButton := 14

global LTriggerIndex := 15
global RTriggerIndex := 16

global ButtonString := Array()

ButtonString[AButton] := "A"
ButtonString[BButton] := "B"
ButtonString[XButton] := "X"
ButtonString[YButton] := "Y"

ButtonString[UpButton] := "D-pad Up"
ButtonString[DownButton] := "D-pad Down"
ButtonString[LeftButton] := "D-pad Left"
ButtonString[RightButton] := "D-pad Right"

ButtonString[StartButton] := "Start"
ButtonString[BackButton] := "Back"

ButtonString[LShoulderButton] := "Left Bumper"
ButtonString[RShoulderButton] := "Right Bumper"

ButtonString[LThumbButton] := "Left Stick"
ButtonString[RThumbButton] := "Right Stick"

ButtonString[LTriggerIndex] := "Left Trigger"
ButtonString[RTriggerIndex] := "Right Trigger"

global Buttons := Array()
global PrevButtons := Array()

global InventoryGridX := Array()
global InventoryGridY := Array()

Loop, 10
{
	temp := A_Index
	Loop, 6
	{
		InventoryGridX[temp,A_Index+5] := 1428.5 + 50*(temp-1)
		InventoryGridY[temp,A_Index+5] := 583.5 + 50*(A_Index-1)
	}
}

Loop, 4
{
	temp := A_Index
	Loop, 5
	{
		if(A_Index > 2)
		{
			InventoryGridX[temp,A_Index] := 1524.5
			InventoryGridY[temp,A_Index] := 511
		}	
		else
		{
			InventoryGridX[temp,A_Index] := 1524.5
			InventoryGridY[temp,A_Index] := 223
		}
	}
}
; Weapon
InventoryGridX[5,5] := 1641.5
InventoryGridY[5,5] := 476
InventoryGridX[6,5] := 1641.5
InventoryGridY[6,5] := 476
InventoryGridX[5,4] := 1641.5
InventoryGridY[5,4] := 476
InventoryGridX[6,4] := 1641.5
InventoryGridY[6,4] := 476

; Left Ring
InventoryGridX[5,4] := 1641.5
InventoryGridY[5,4] := 387.5
InventoryGridX[6,4] := 1641.5
InventoryGridY[6,4] := 387.5

; Hands
InventoryGridX[5,3] := 1641.5
InventoryGridY[5,3] := 318
InventoryGridX[6,3] := 1641.5
InventoryGridY[6,3] := 318

; Shoulders
InventoryGridX[5,2] := 1665
InventoryGridY[5,2] := 229
InventoryGridX[6,2] := 1665
InventoryGridY[6,2] := 229
InventoryGridX[5,1] := 1665
InventoryGridY[5,1] := 229
InventoryGridX[6,1] := 1665
InventoryGridY[6,1] := 229

; Feet
InventoryGridX[7,5] := 1739
InventoryGridY[7,5] := 494.5
InventoryGridX[8,5] := 1739
InventoryGridY[8,5] := 494.5

; Legs
InventoryGridX[7,4] := 1739
InventoryGridY[7,4] := 412
InventoryGridX[8,4] := 1739
InventoryGridY[8,4] := 412

; Waist
InventoryGridX[7,3] := 1739
InventoryGridY[7,3] := 353
InventoryGridX[8,3] := 1739
InventoryGridY[8,3] := 353

; Chest
InventoryGridX[7,2] := 1739
InventoryGridY[7,2] := 282
InventoryGridX[8,2] := 1739
InventoryGridY[8,2] := 282

; Head
InventoryGridX[7,1] := 1739
InventoryGridY[7,1] := 199
InventoryGridX[8,1] := 1739
InventoryGridY[8,1] := 199

; Off-Hand
InventoryGridX[9,5] := 1836
InventoryGridY[9,5] := 476
InventoryGridX[10,5] := 1836
InventoryGridY[10,5] := 476
InventoryGridX[9,4] := 1836
InventoryGridY[9,4] := 476
InventoryGridX[10,4] := 1836
InventoryGridY[10,4] := 476

; Right Ring
InventoryGridX[9,4] := 1836.5
InventoryGridY[9,4] := 387.5
InventoryGridX[10,4] := 1836.5
InventoryGridY[10,4] := 387.5

; Wrists
InventoryGridX[9,3] := 1836
InventoryGridY[9,3] := 318
InventoryGridX[10,3] := 1836
InventoryGridY[10,3] := 318

; Amulet
InventoryGridX[9,2] := 1808.5
InventoryGridY[9,2] := 232.5
InventoryGridX[10,2] := 1808.5
InventoryGridY[10,2] := 232.5
InventoryGridX[9,1] := 1808.5
InventoryGridY[9,1] := 232.5
InventoryGridX[10,1] := 1808.5
InventoryGridY[10,1] := 232.5

;1785 209 47 47 
Calibrate()
ReadConfig()

if WinExist(ApplicationName)
	WinActivate ; Activate Application Window if it exists

Gosub TriggerState
	
MouseGetPos, MouseX, MouseY
TargetX := MouseX
TargetY := MouseY

IsInitializing := false

Gui, +LastFound -Caption +E0x80000 +Owner +AlwaysOnTop +ToolWindow
WinSet, ExStyle, +0x20
hGui := WinExist()

pToken    := Gdip_Startup()

hbm := CreateDIBSection(300,300)
hdc := CreateCompatibleDC()
obm := SelectObject(hdc, hbm)
pGraphics := Gdip_GraphicsFromHDC(hdc)
Gui, Show, NoActivate

UpdateLayeredWindow(hGui, hdc,0,0,300,300)
sFile   := "Target.png"

Gdip_SetCompositingMode(pGraphics,1)
pBrush:=Gdip_BrushCreateSolid(0x0000000)
Gdip_FillRectangle(pGraphics, pBrush, 0, 0, 300, 300)

pImage    := Gdip_CreateBitmapFromFile(sFile)
global ImageW        := Gdip_GetImageWidth(pImage)
global ImageH        := Gdip_GetImageHeight(pImage)

Gdip_DrawImage(pGraphics, pImage, 0, 0, ImageW, ImageH)
UpdateLayeredWindow(hGui, hdc)

Gdip_DeleteBrush(pBrush)
Gdip_DisposeImage(pImage)

SetTimer, TriggerState, 1
SetTimer, Startup, off
return
