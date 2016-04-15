#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directoTargety.
#Include XInput.ahk
#Include Gdip.ahk

XInput_Init() ; Initialize XInput
Gdip_Startup()

global PI := 3.141592653589793 ; Define PI for easier use

TThreshold := 64 ; for trigger deadzones

global ForceMoveKey
global Move := false ; This is true when space is pressed down so that it is not spam pressed over and over. It is set to false when a button is pressed, or the left analog stick is released
global ForceMove := false ; This is true whenever all buttons are released. I use this to force the analog stick to induce movement any time it otherwise may not press the space bar

global Target := false ; This is true when the Right analog stick is currently being used
global TargetX ; This is the red target on the screen's X value
global TargetY ; This is the red target on the screen's Y value
global MouseX ; The left stick's X value on the screen
global MouseY ; The right stick's Y value on the screen

global Pressed := 0 ; This value stores the amount of buttons currently pressed. It is used to stop the left ananlog stick from inducing movement
global IgnoreIt := false ; When this value is greater true, there is a button currently pressed that the user does not want to use the target cursor for
global IgnorePressed := 0

global StartScript := true ; This is true until the 'Startup' timer has completed. It is used to stop some functions from running until everything has been initialized.

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

global Width ; The width of the current active window
global Height ; The height of the current active window

global RStick := true ; Currently unused
global LStick := true ; When true movement is normal, when false cursor mode is enabled

global VibeStrength ; The strength of the vibration
global VibeDuration ; The length of time in miliseconds that the controller vibrates
global Delay

global LMaxRadiusX ; The radius the cursor maxes out at on the left stick in the X direction 
global LMaxRadiusY ; The radius the cursor maxes out at on the left stick in the Y direction 

global LThreshold ; The deadzone of the left stick

global RMaxRadiusX ; The radius the cursor maxes out at on the left stick in the X direction 
global RMaxRadiusY ; The radius the cursor maxes out at on the left stick in the Y direction 

global RThreshold ; The deadzone of the right stick

; Offset from the center of the currently active window to consider to be the actual center
global CenterOffsetX
global CenterOffsetY

; Extra offset for the left stick to adhere to from the center of the currently active window
global LRadiusOffsetX
global LRadiusOffsetY

; Extra offset for the right stick to adhere to from the center of the currently active window
global RRadiusOffsetX 
global RRadiusOffsetY

global Inventory := false ; This value is true when then Inventory hotkey is triggered, and is toggled by that button. While true, the D-Pad is used to navigate the inventory screen
global InventoryX := 1 ; The X value of the Inventory grid the user is currently on
global InventoryY := 6 ; The Y value of the Inventory grid the user is currently on

#Persistent  ; Keep this script running until the user explicitly exits it.
SetTimer, Startup, 750 ; The 'Init' function of my code essentially. It's at the very bottom.

$F5::
ReadConfig() ; Reloades the config values when F5 is pressed
return

; Pauses the script and displays a message indicating so whenever F10 is pressed. The '$' ensures the hotkey can't be triggered with a 'Send' command
$F10::
Tooltip, Paused `nPress F10 to resume, 0, 0, 4
if(A_IsPaused)
	Tooltip, , , , 4
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
	local CenterX := Width + LRadiusOffsetX, CenterY := Height + LRadiusOffsetY ; Where the circle will originate when it is drawn
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
				Send {%ForceMoveKey% Down}
			Move := true ; Don't press space again
			ForceMove = false ; Don't tell me what to do
		}
		; Currently useless function
		if (!StartScript && FirstMovement)
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
			if(!IgnoreIt)
				Send {%ForceMoveKey% Up}
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
		if((!Pressed || !Target) && (!Inventory || Move))
		{
			if(Move)
				MouseMove, MouseX, MouseY
			else
				MouseMove, Width, Height
		}
		else if(Target && Pressed)
		{
			if(Move)
			{
				bufferx := MouseX - ImageW/2
				buffery := MouseY - ImageH/2
				Gui, 1:Show, x%bufferx% y%buffery% NoActivate
			}
			else
			{
				bufferx := Width - ImageW/2
				buffery := Height - ImageH/2
				Gui, 1:Show, x%bufferx% y%buffery% NoActivate
			}
		}
		; Pretty much: if space isn't being pressed, and the inventory is open
		else if(!Move && Inventory)
			MouseMove, InventoryGridX[InventoryX,InventoryY], InventoryGridY[InventoryX,InventoryY]
		;if(!FirstMovement)
			;ToolTip, %LThumbX% : %LThumbY% `n%LThumbX0% : %LThumbY0% `n%LThumbXCenter% : %LThumbYCenter% - %Radius% `n%AngleDeg% `n%CenterX% : %CenterY% `n%Title% - %Width% : %Height%, 1900, 425
	}
	else
	{
		if(Abs(LThumbXCenter) >= Abs(LThumbYCenter))
			Radius := 20 * ((Abs(LThumbXCenter)-LThreshold)/(LMaxThreshold-LThreshold))
		else
			Radius := 20 * ((Abs(LThumbYCenter)-LThreshold)/(LMaxThreshold-LThreshold))
		
		MouseX := Radius * cos(Angle)
		MouseY := Radius * sin(Angle)
		
		if(Move)
			MouseMove, MouseX, MouseY, , R
	}
	return  ; Do nothing.
}

WatchAxisR()
{
	global ; All values are global unless stated otherwise
	local CenterX := Width + RRadiusOffsetX, CenterY := Height + RRadiusOffsetY ; Where the circle will originate when it is drawn
	local Angle, AngleDeg ; 'Angle' is the angle in radians that the stick is currently at. 'AngleDeg' is that angle but in degrees.
	
	local RThumbXCenter := RThumbX - RThumbX0 ; This takes the current value of the stick's X and subtracts the value when the stick is at rest to 'zero out' the value before calculations
	local RThumbYCenter := RThumbY - RThumbY0 ; This takes the current value of the stick's Y and subtracts the value when the stick is at rest to 'zero out' the value before calculations
	
	static FirstMovement ; Currently unused. Was for deleting the ToolTip that read "You man begin" once the user moved the stick.
	
	; Checks the deadzone of the stick 
	if (Abs(RThumbXCenter) > RThreshold || Abs(RThumbYCenter) > RThreshold)
	{
		;Makes sure that the target on the screen being present is known to all who may question it
		Target = true
	}
	; If the stick is currently released
	else
	{
		; Now all shall know that it is hidden, and it was good
		Target := false
		Gui, 1:Hide
	}
	
	; Currently always true. Ignore for now
	if(RStick)
	{
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
			;ToolTip, %RThumbX% : %RThumbY% `n%RThumbX0% : %RThumbY0% `n%RThumbXCenter% : %RThumbYCenter% `n%RadiusX% : %RadiusY% `n%AngleDeg% %Angle% `n%TargetX% %TargetY% `n%Title% - %Width% : %Height% `n%Pressed%, 1900, 510, 2
			; Pretty Much: if the right stick is currently held, and no buttons are being pressed
			if(Target && !Pressed)
			{
				bufferx := TargetX - ImageW/2
				buffery := TargetY - ImageH/2
				Gui, 1:Show, x%bufferx% y%buffery% NoActivate
			}
		}
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

if(!StartScript) 
{
	WinGetActiveStats, Title, Width, Height, X, Y
	
	Width := Width/2
	Height := Height/2
	; if the Diablo window is active then the center of the screen is a lot higher than normal. This sets it to that value.
	IfWinActive,  Diablo III
	{
		Width := Width + CenterOffsetX
		Height := Height + CenterOffsetY
	}
	
	if(LThumbX != PrevLThumbX || LThumbY != PrevLThumbY || ForceMove)
		WatchAxisL()
	if(RThumbX != PrevRThumbX || RThumbY != PrevRThumbY)
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
return
; /TriggerState

WatchAxisT:
if(LTrigger != PrevLTrigger)
{ 
	if (LTrigger > TThreshold && PrevLTrigger <= TThreshold) ;Left trigger is held
		ActionDown(LTriggerKey[1],LTriggerKey[2],0)
	if (LTrigger <= TThreshold && PrevLTrigger > TThreshold) ;Left is released
		ActionUp(LTriggerKey[1],LTriggerKey[2],0,0)
}
if(RTrigger != PrevRTrigger)
{ 
	if (RTrigger > TThreshold && PrevRTrigger <= TThreshold) ;Right trigger is held
		ActionDown(RTriggerKey[1],RTriggerKey[2],0)
	if (RTrigger <= TThreshold && PrevRTrigger > TThreshold) ;Right is released
		ActionUp(RTriggerKey[1],RTriggerKey[2],0,0)
}
return ; Do nothing.

WatchButtons:

Loop, 14
{
	if(!StartScript)
	{
		if(Buttons[A_Index] != PrevButtons[A_Index])
		{
			if(Buttons[A_Index])
			{
				if(ButtonKey[A_Index][1] = "Loot")
					SetTimer, SpamLoot, 5
				else if(ButtonKey[A_Index][1] = "Freedom")
				{
					if(Inventory)
					{
						Inventory := false
						Loop, 4
						{
							temp := ButtonKey[A_Index+4][1]
							ButtonKey[A_Index+4][1] := ButtonKey[A_Index+4][3]
							ButtonKey[A_Index+4][3] := temp
						}	
					}	
					if(LStick)
					{
						buffer := ButtonKey[A_Index][1]
						ToolTip, Cursor Mode: Enabled `nPress %buffer% on the controller to disable, 0, 0
						LStick := false
					}
					else
					{
						ToolTip
						LStick := true
					}
				}
				else
					ButtonKey[A_Index][4] := ActionDown(ButtonKey[A_Index][1],ButtonKey[A_Index][2],ButtonKey[A_Index][3])
			}
			else if(ButtonKey[A_Index][3] && ButtonKey[A_Index][4] = 0)
			{
				if(ButtonKey[A_Index][3] != "Inventory")
					ActionUp(ButtonKey[A_Index][3],0,0,0)
			}
			else
			{
				if(Inventory &&(A_Index > 4 && A_Index < 9))
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
						MouseMove, InventoryGridX[InventoryX,InventoryY], InventoryGridY[InventoryX,InventoryY]
					else
					{
						InventoryX := PrevInventoryX
						InventoryY := PrevInventoryY
					}
				}
				else if(ButtonKey[A_Index][1] != "Loot" && ButtonKey[A_Index][1] != "Freedom")
					ActionUp(ButtonKey[A_Index][1],ButtonKey[A_Index][2],ButtonKey[A_Index][3],ButtonKey[A_Index][4])
				else if(ButtonKey[A_Index][1] = "Loot")
					SetTimer, SpamLoot, Off
			}	
		}
		else if(ButtonKey[A_Index][3] && Buttons[A_Index] && ButtonKey[A_Index][4] && A_TickCount >= ButtonKey[A_Index][4] + Delay)    
		{
			Loop, 4 
			{ 
				if XInput_GetState(A_Index-1)
					XInput_SetState(A_Index-1, VibeStrength, VibeStrength) ;MAX 65535
			}
			SetTimer, VibeOff, %VibeDuration%
			if(ButtonKey[A_Index][3] = "Inventory")
			{
				if(!Inventory)
				{
					Inventory := true
					LStick := true
					Loop, 4
					{
						temp := ButtonKey[A_Index+4][1]
						ButtonKey[A_Index+4][1] := ButtonKey[A_Index+4][3]
						ButtonKey[A_Index+4][3] := temp
					}	
					buffer := ButtonKey[A_Index][1]
					ToolTip, Inventory Mode: Enabled `nPress and hold %buffer% on the controller to disable, 0, 0
					MouseMove, InventoryGridX[InventoryX,InventoryY], InventoryGridY[InventoryX,InventoryY]
					Gui, 1:Hide
				}
				else
				{
					Inventory := false
					Loop, 4
					{
						temp := ButtonKey[A_Index+4][1]
						ButtonKey[A_Index+4][1] := ButtonKey[A_Index+4][3]
						ButtonKey[A_Index+4][3] := temp
					}	
					ToolTip					
				}
				ButtonKey[A_Index][4] := 0
			}
			else
			{
				if(Buttons[A_Index])
				{ 
					ActionDown(ButtonKey[A_Index][3],0,0)
					ButtonKey[A_Index][4] := 0
				}	
			}
		}
	}
	else
	{
		ButtonKey[A_Index][4] := 0
	}
}
return

ActionDown(Action, Modifier, Held)
{
	global
	if(!Held)
	{
		if(!Modifier && IgnoreTarget[1])
		{
			Loop
			{
				if(Action = IgnoreTarget[A_Index])
				{					
					Send {%ForceMoveKey% Up}
					ForceMoveKey := Action
					Send {%ForceMoveKey% Down}
					Move := false
					ForceMove := true
					IgnoreIt := true
					IgnorePressed += 1
					local skip := true
				}
			} Until !IgnoreTarget[A_Index+1]
			if(!skip)
				TargetActionDown(Action, Modifier)
		}
		else
			TargetActionDown(Action, Modifier)
	}
	else
		return A_TickCount
}
ActionUp(Action, Modifier, Held, byRef TimeHeld)
{
	global
	if(Held)
	{	
		Loop
		{
			if(Action = IgnoreTarget[A_Index])
			{
				local tempX, local tempY
				MouseGetPos, tempX, tempY
				MouseMove, MouseX, MouseY
				Send {%Action% Down}
				Send {%Action% Up}
				MouseMove, tempX, tempY
				local skip := true
			}
		} Until !IgnoreTarget[A_Index+1]
		if(!skip)
		{
			TargetActionDown(Action, Modifier)		
			TargetActionUp(Action, Modifier)
		}
	}
	else if(IgnoreTarget[1])
	{
		Loop
		{
			if(Action = IgnoreTarget[A_Index])
			{
				Send {%ForceMoveKey% Up}
				IgnorePressed -= 1
				IgnoreIt := false
				ForceMoveKey := "Space"
				local skip := true
			}
		} Until !IgnoreTarget[A_Index+1]
		if(!skip)
			TargetActionUp(Action, Modifier)
	}
	else TargetActionUp(Action, Modifier)
}

TargetActionDown(Action, Modifier)
{
	if(Pressed = 0)
	{
		MouseGetPos, PrevMouseX, PrevMouseY
		if(Target)
		{
			Gui, 1:Hide
		}
		;Move := false
		Send {%ForceMoveKey% Up}
	}
	
	Pressed += 1
	if(Target)
	{
		IgnoreIt := false
		MouseMove, TargetX, TargetY
	}
	
	if(Modifier)
		Send {%Modifier% Down}
	Send {%Action% Down}	
	return ; Do nothing
}
TargetActionUp(Action, Modifier)
{ 
	Pressed -= 1	
	if(Modifier)
		Send {%Modifier% Up}
	Send {%Action% Up} 	
	
	if(Pressed = 0)
	{
		Move := false
		ForceMove := true
		Send {%ForceMoveKey% Up}
		MouseMove, PrevMouseX, PrevMouseY
		
		if(Target)
		{
			bufferx := TargetX - ImageW/2
			buffery := TargetY - ImageH/2
			Gui, 1:Show, x%bufferx% y%buffery% NoActivate
		}
	}
	return ; Do nothing
}

InventoryInit()
{
	global
	Loop, 4
	{
		local temp := ButtonKey[A_Index+4][1]
		ButtonKey[A_Index+4][1] := ButtonKey[A_Index+4][3]
		ButtonKey[A_Index+4][3] := temp
	}	
}

Calibrate()
{
	global
	
	local MaxL := 32767, MaxR := 32767, Button, buffer
	
	IniRead, buffer, config.ini, Calibration, Calibrate
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
	
	MsgBox, , Calibration Complete, That concludes the calibration. `n`nIf for any reason you think these values  are incorrect, you can either edit them yourself (not recommended) or change the 'Calibrate = true' in the config file to 'true' to run this again.
	
	IniWrite, false, config.ini, Calibration, Calibrate
	
	IniWrite, %MaxL%, config.ini, Calibration, Left_Analog_Max
	IniWrite, %MaxR%, config.ini, Calibration, Right_Analog_Max
	
	IniWrite, %LThumbX0%, config.ini, Calibration, Left_Analog_XZero
	IniWrite, %LThumbY0%, config.ini, Calibration, Left_Analog_YZero
	
	IniWrite, %RThumbX0%, config.ini, Calibration, Right_Analog_XZero
	IniWrite, %RThumbY0%, config.ini, Calibration, Right_Analog_YZero
}

ReadConfig()
{
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
	
	IniRead, ForceMoveKey, config.ini, Buttons, Force_Move
	
	global IgnoreTarget := Array()
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
	
	IniRead, LMaxThreshold, config.ini, Calibration, Left_Analog_Max
	IniRead, RMaxThreshold, config.ini, Calibration, Right_Analog_Max
	
	IniRead, LThumbX0, config.ini, Calibration, Left_Analog_XZero
	IniRead, LThumbY0, config.ini, Calibration, Left_Analog_YZero
	
	IniRead, RThumbX0, config.ini, Calibration, Right_Analog_XZero
	IniRead, RThumbY0, config.ini, Calibration, Right_Analog_YZero
	
	IniRead, VibeStrength, config.ini, Preferences, Vibration_Strength
	IniRead, VibeDuration, config.ini, Preferences, Vibration_Duration
	IniRead, Delay, config.ini, Preferences, Hold_Delay
	
	IniRead, LMaxRadiusX, config.ini, Preferences, Left_Analog_XRadius
	IniRead, LMaxRadiusY, config.ini, Preferences, Left_Analog_YRadius
	
	IniRead, LThreshold, config.ini, Preferences, Left_Analog_Deadzone
	
	IniRead, RMaxRadiusX, config.ini, Preferences, Right_Analog_XRadius
	IniRead, RMaxRadiusY, config.ini, Preferences, Right_Analog_YRadius
	
	IniRead, RThreshold, config.ini, Preferences, Right_Analog_Deadzone
	
	IniRead, CenterOffsetX, config.ini, Preferences, Center_XOffset
	IniRead, CenterOffsetY, config.ini, Preferences, Center_YOffset
	
	IniRead, LRadiusOffsetX, config.ini, Preferences, Left_Analog_Center_XOffset
	IniRead, LRadiusOffsetY, config.ini, Preferences, Left_Analog_Center_YOffset
	
	IniRead, RRadiusOffsetX, config.ini, Preferences, Right_Analog_Center_XOffset
	IniRead, RRadiusOffsetY, config.ini, Preferences, Right_Analog_Center_YOffset
}
PassKeys(ButtonName)
{
	IniRead, Key, config.ini, Buttons, %ButtonName%
	KeyBinding := Array()
	
	if Key = ERROR
		return ERROR
	i := InStr(Key,"+") 
	f := InStr(Key,",")
	
	if(f)
	{
		KeyBinding[3] := SubStr(Key, f+2)
		if(i)
		{
			KeyBinding[1] := SubStr(Key, i+1, f-i-1)
			KeyBinding[2] := SubStr(Key, 1, i-1)
		}
		else
			KeyBinding[1] := SubStr(Key, 1, f-1)
	}
	else if(i)
	{
		KeyBinding[1] := SubStr(Key, i+1)
		KeyBinding[2] := SubStr(Key, 1, i-1)
	}
	else
		KeyBinding[1] := Key
	
	return KeyBinding
}

SpamLoot:
MouseGetPos, PrevX, PrevY
MouseMove, Width, Height
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
IfWinExist, Diablo III
	WinActivate ; Activate Diablo III Window
	
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
Gosub TriggerState
	
MouseGetPos, MouseX, MouseY
TargetX := MouseX
TargetY := MouseY

StartScript := false

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
