#include ReadConfig.ahk
#include Graphics.ahk

Class KeyHandle
{
	; Creates a static variable for ReadConfig and Graphics
	; Will be set later in the constructor
	static ReadConfig :=
	static Graphics :=
	
	IgnoreTarget := Array()	; Creates an array to hold the ignore target keys
	Pressed := 0			; Number of buttons that are currently pressed down
	IgnorePressed := 0		; Number of buttons that are currently pressed down which are considered IgnoreTarget buttons
	
	;======== CONSTANTS ========
	
	; These are a way to reference an array index with a readable index rather than a number 
	A_Button := 1
	B_Button := 2
	X_Button := 3
	Y_Button := 4

	DPad_Up := 5
	DPad_Down := 6
	DPad_Left := 7
	DPad_Right := 8

	Start_Button := 9
	Back_Button := 10

	Left_Shoulder := 11
	Right_Shoulder := 12

	Left_Analog_Button := 13
	Right_Analog_Button := 14
	
	;=============== END CONSTANTS =================
	
	Class AnalogStick
	{		
		; Constructor
		/*  Parameters
		*	MaxRadiusX = the radius of the oval to calculate the position of the 
		*/
		__New(MaxRadiusX, MaxRadiusY, Cx, Cy, OffSetX, OffSetY, DeadZone, Threshold) 
		{
			this.MaxRadiusX := MaxRadiusX, this.MaxRadiusY := MaxRadiusY
			this.Cx := Cx, this.Cy := Cy
			this.OffSetX := OffSetX, this.OffSetY := OffSetY
			this.DeadZone := DeadZone
			this.Threshold := Threshold
		}
		
		Check_State(PassStickX, PassStickY) 
		{
			this.StickX := PassStickX
			this.StickY := PassStickY
			
			this.StickCenterX := this.StickX - this.OffSetX ; This takes the current value of the stick's X and subtracts the value when the stick is at rest to 'zero out' the value before calculations
			this.StickCenterY := this.StickY - this.OffSetY ; This takes the current value of the stick's Y and subtracts the value when the stick is at rest to 'zero out' the value before calculations
	
			if (Abs(this.StickCenterX) > this.DeadZone || Abs(this.StickCenterY) > this.DeadZone)
				this.IsPressed := true
			else
				this.IsPressed := false
				
			return this.IsPressed
		}
		
		Calc_Angle() 
		{
			if (this.StickCenterX < 0 && this.StickCenterY < 0) ; 3rd Quadrant
			{
				this.AngleDeg := Abs(ATan(this.StickCenterY/this.StickCenterX)*(180/PI)) + 180
			}
			else if (this.StickCenterX < 0 && this.StickCenterY > 0) ; 2nd Quadrant
			{    
				this.AngleDeg := 180 - Abs(ATan(this.StickCenterY/this.StickCenterX)*(180/PI))
			}
			else if(this.StickCenterX > 0 && this.StickCenterY < 0) ; 4th Quadrant
			{
				this.AngleDeg := 360 - Abs(ATan(this.StickCenterY/this.StickCenterX)*(180/PI))
			}
			else if (this.StickCenterX = 0 && this.StickCenterY > 0) ; ATan Error would occur since angle is 90
			{
				this.AngleDeg := 90
			}
			else if (this.StickCenterX = 0 && this.StickCenterY < 0) ; ATan Error would occur since angle is 270
			{
				this.AngleDeg := 270
			}
			else if (this.StickCenterX < 0 && this.StickCenterY = 0) ; Differentiate between 0 and 180 degrees
			{
				this.AngleDeg := 180
			}                 
			else ; 1st Quadrant
			{
				this.AngleDeg := Abs(ATan(this.StickCenterY/this.StickCenterX)*(180/PI))
			}
				
			this.Angle := -this.AngleDeg * (PI/180) ; Convert the angle back into radians for calculation
			
			return this.Angle
		}
		
		Calc_Radius(PassRadiusX := 0, PassRadiusY := 0) 
		{
			; The analog stick returns a lumpy square as movement. With this, I cut a proper square out of it by limiting the furthest the stick is pressed before I stop registering it		
			if(Abs(this.StickCenterX) > this.Threshold)
			{
				if(this.StickCenterX > 0)
					this.StickCenterX := this.Threshold
				else
					this.StickCenterX := -this.Threshold
			}
			if(Abs(this.StickCenterY) > this.Threshold)
			{
				if(this.StickCenterY > 0)
					this.StickCenterY := this.Threshold
				else	
					this.StickCenterY := -this.Threshold
			}
			
			; Which ever value is higher (either StickCenterX or StickCenterY), that value is used to calculate the radii
			if(Abs(this.StickCenterX) >= Abs(this.StickCenterY))
			{
				this.RadiusX := PassRadiusX * ((Abs(this.StickCenterX)-this.DeadZone)/(this.Threshold-this.DeadZone))
				this.RadiusY := PassRadiusY * ((Abs(this.StickCenterX)-this.DeadZone)/(this.Threshold-this.DeadZone))
			}
			else
			{
				this.RadiusX := PassRadiusX * ((Abs(this.StickCenterY)-this.DeadZone)/(this.Threshold-this.DeadZone))
				this.RadiusY := PassRadiusY * ((Abs(this.StickCenterY)-this.DeadZone)/(this.Threshold-this.DeadZone))
			}
		}
		
		Calc_Oval(PassRadiusX := 0, PassRadiusY := 0) 
		{
			if(PassRadiusX || PassRadiusY)
			{
				; http://math.stackexchange.com/questions/22064/calculating-a-point-that-lies-on-an-ellipse-given-an-angle
				this.X := (this.Cx) + (PassRadiusX*PassRadiusY)/Sqrt((PassRadiusY**2)+(PassRadiusX**2)*(tan(this.Angle)**2))
				this.Y := (this.Cy) + (PassRadiusX*PassRadiusY*tan(this.Angle))/Sqrt((PassRadiusY**2)+(PassRadiusX**2)*(tan(this.Angle)**2))
				
				; Because of the way the calculation goes, whenever the angle is in the 2nd and 3rd quadrant it needs to be translated
				if(this.AngleDeg > 90 && this.AngleDeg <= 270)
				{
					this.X := (this.Cx) - (this.X - this.Cx)
					this.Y := (this.Cy) - (this.Y - this.Cy)
				}
			}
			else
			{
				this.X := this.Cx
				this.Y := this.Cy
			}
		}
	}
	Class Button
	{		
		Timer := 0
		
		__New(XInput, ButtonName, ReadConfig, IgnoreTarget) 
		{ 
			this.XInput := XInput
			
			ReadConfig.Load_Button(ButtonName, PressKey, PressModifier, HoldKey, HoldModifier)
			this.PressKey := PressKey
			this.PressModifier := PressModifier
			this.HoldKey := HoldKey
			this.HoldModifier := HoldModifier
			
			this.IgnoreTarget := false
			Loop
			{
				if(((this.PressKey = IgnoreTarget[A_Index] && !this.PressModifier)|| IgnoreTarget[A_Index] = this.PressKey "+" this.PressModifier) || ((this.HoldKey = IgnoreTarget[A_Index] && !this.HoldModifier) || IgnoreTarget[A_Index] = this.HoldKey "+" this.HoldModifier))
				{
					this.IgnoreTarget := true
					this.IgnoreKey := IgnoreTarget[A_Index]
				}
			} Until !IgnoreTarget[A_Index+1]
		}
		
		Check_State(State, PrevState) 
		{
			if(State.Buttons & this.XInput)
				this.IsPressed := true
			else
				this.IsPressed := false
			
			if(State.Buttons & this.XInput != PrevState.Buttons & this.XInput)
				return true
			else
				return false
		}
		
		TargetActionDown(X, Y, Delay, byRef Pressed) 
		{
			if(this.HoldKey)
			{
				if(this.Timer && A_TickCount >= this.Timer + Delay)
				{
					Modifier := this.HoldModifier
					Key := this.HoldKey
					
					this.Timer := 0
				}
				else
					return
			}
			else
			{				
				Modifier := this.PressModifier				
				Key := this.PressKey
			}
			
			MouseMove, X, Y				
			Send {%Modifier% Down}		
			Send {%Key% Down}				
			Pressed += 1
		}
		IgnoreActionDown(X, Y, Delay, byRef IgnorePressed, byRef ForceMove) 
		{
			if(this.HoldKey)
			{
				if(this.Timer && A_TickCount >= this.Timer + Delay)
				{
					Modifier := this.HoldModifier
					Key := this.HoldKey
					
					this.Timer := 0
				}
				else
					return
			}
			else
			{				
				Modifier := this.PressModifier				
				Key := this.PressKey
			}
			
			MouseMove, X, Y				
			Send {%Modifier% Down}		
			Send {%Key% Down}
			
			ForceMove := Modifier Key
			IgnorePressed += 1
		}
		
		TargetActionUp(X, Y, Delay, byRef Pressed) 
		{
			if(this.HoldKey)
			{
				if(!this.Timer && A_TickCount >= this.Timer + Delay)
				{
					Modifier := this.HoldModifier
					Key := this.HoldKey
					
					this.timer := 0
				}
				else
				{
					MouseMove, X, Y				
			
					Modifier := this.PressModifier
					Key := this.PressKey
					
					Send {%Modifier% Down}		
					Send {%Key% Down}
					Send {%Modifier% Up}		
					Send {%Key% Up}
					
					this.Timer := 0
					
					return
				}
			}
			else
			{				
				Modifier := this.PressModifier				
				Key := this.PressKey
			}
			
			Send {%Modifier% Up}		
			Send {%Key% Up}				
			Pressed -= 1
		}
		IgnoreActionUp(X, Y, Delay, byRef IgnorePressed) 
		{
			if(this.HoldKey)
			{
				if(!this.Timer && A_TickCount >= this.Timer + Delay)
				{
					Modifier := this.HoldModifier
					Key := this.HoldKey
					
					this.timer := 0
				}
				else
				{
					MouseMove, X, Y				
			
					Modifier := this.PressModifier
					Key := this.PressKey
					
					Send {%Modifier% Down}		
					Send {%Key% Down}
					Send {%Modifier% Up}		
					Send {%Key% Up}
					
					this.Timer := 0
					
					return
				}
			}
			else
			{				
				Modifier := this.PressModifier				
				Key := this.PressKey
			}
			
			Send {%Modifier% Up}		
			Send {%Key% Up}	
			IgnorePressed -= 1
		}
	}
	__New() 
	{
		ReadConfig := new ReadConfig()
		Graphics := new Graphics()
		
		this.LStick := this.Load_AnalogStick("Left", "Absolute Mouse")
		this.RStick := this.Load_AnalogStick("Right", "Target")
		
		ReadConfig.Load(OGForceMove, "config.ini", "Buttons", "Force_Move")
		this.OGForceMove := OGForceMove
		this.ForceMove := OGForceMove
		
		this.Load_Buttons()
	}
	
	Handle() 
	{
		this.Check_State()
		
		this.Handle_Stick(this.LStick, "L")
		this.Handle_Stick(this.RStick, "R")
		
		this.Handle_Buttons()
	}
	
	Handle_Stick(byRef Stick , StickAbv)
	{ 
		Var1 := "Thumb" StickAbv "X"
		Var2 := "Thumb" StickAbv "Y"
		Var1 := this.State[Var1]
		Var2 := this.State[Var2]
		ForceMove := this.ForceMove
		
		Stick.Check_State(Var1, Var2)	
		Stick.Calc_Angle()
		Stick.Calc_Radius(Stick.MaxRadiusX, Stick.MaxRadiusY)		
		
		if(Stick.Mode = "Absolute Mouse")
		{
			if(Stick.IsPressed)
				Stick.Calc_Oval(Stick.MaxRadiusX, Stick.MaxRadiusY)
			else
				Stick.Calc_Oval()
			MouseMove, Stick.X, Stick.Y
			
			if(Stick.IsPressed)
				Send {%ForceMove% Down}
			else
				Send {%ForceMove% Up}
		}
		else if(Stick.Mode = "Absolute Target")
		{
			if(Stick.IsPressed)
				Stick.Calc_Oval(Stick.MaxRadiusX, Stick.MaxRadiusY)
			else 
				Stick.Calc_Oval()
			Graphics.Draw_Target(Stick.X, Stick.Y)
		}
		else if(Stick.Mode = "Mouse")
		{
			if(Stick.IsPressed)
				Stick.Calc_Oval(Stick.RadiusX, Stick.RadiusY)
			else
				Stick.Calc_Oval()
			MouseMove, Stick.X, Stick.Y
		}
		else if(Stick.Mode = "Target")
		{
			if(Stick.IsPressed)
			{
				Stick.Calc_Oval(Stick.RadiusX, Stick.RadiusY)
				Graphics.Draw_Target(Stick.X, Stick.Y)
			}
			else 
			{
				Stick.Calc_Oval()
				Graphics.Hide_Target()
			}
		}		
		
		;if(StickAbv = "L")
			;Tooltip , % StickAbv ":" Stick.Mode "`n" Stick.X ":" Stick.Y "`n" Stick.AngleDeg "`n" Stick.RadiusX ":" Stick.RadiusY "`n" Stick.MaxRadiusX ":" Stick.MaxRadiusY
	}
	
	Handle_Buttons()
	{
		Loop, 14
		{
			if(this.Button[A_Index].Check_State(this.State, this.PrevState))
			{
				if(this.Button[A_Index].IsPressed)
				{
					if(!this.Button[A_Index].HoldKey)
					{
						if(this.Button[A_Index].PressKey != "Inventory" && this.Button[A_Index].PressKey != "Freedom" && this.Button[A_Index].PressKey != "Loot")
							this.ActionDown()
					}
					else
						this.Button[A_Index].Timer := A_TickCount
				}
				else
				{
					if(!this.Button[A_Index].HoldKey || A_TickCount < this.Button[A_Index].Timer + this.Delay)
					{
						if(this.Button[A_Index].PressKey != "Inventory" && this.Button[A_Index].PressKey != "Freedom" && this.Button[A_Index].PressKey != "Loot")
							this.ActionUp()
					}
					else if(this.Button[A_Index].HoldKey && A_TickCount >= this.Button[A_Index].Timer + this.Delay)
					{
						if(this.Button[A_Index].HoldKey != "Inventory" && this.Button[A_Index].HoldKey != "Freedom" && this.Button[A_Index].HoldKey != "Loot")
							this.ActionUp()
					}
				}				
			}
			else if(this.Button[A_Index].IsPressed)
			{
				if(this.Button[A_Index].HoldKey && A_TickCount >= this.Button[A_Index].Timer + this.Delay)
				{
					if(this.Button[A_Index].PressKey != "Inventory" && this.Button[A_Index].PressKey != "Freedom" && this.Button[A_Index].PressKey != "Loot")
						this.ActionDown()
				}
			}
		}
	}
	
	ActionDown() 
	{
		if(!this.Button[A_Index].IgnoreTarget || this.Button[A_Index].PressKey != this.Button[A_Index].IgnoreKey)
		{
			Pressed := this.Pressed
			this.Button[A_Index].TargetActionDown(this.RStick.X, this.RStick.Y, this.Delay, Pressed)			
			this.Pressed := Pressed
			
			this.RStick.Mode := "Mouse"
			this.LStick.Mode := "Absolute Target"
		}
		else
		{
			IgnorePressed := this.IgnorePressed
			ForceMove := this.ForceMove
			this.PrevForceMove := this.ForceMove
			
			this.Button[A_Index].IgnoreActionDown(this.LStick.X, this.LStick.Y, this.Delay, IgnorePressed, ForceMove)
			
			this.IgnorePressed := IgnorePressed
			this.ForceMove := ForceMove
			
			this.RStick.Mode := "Target"
			this.LStick.Mode := "Absolute Mouse"
		}
	}
	
	ActionUp() 
	{
		if(!this.Button[A_Index].IgnoreTarget || this.Button[A_Index].PressKey != this.Button[A_Index].IgnoreKey)
		{
			Pressed := this.Pressed
			this.Button[A_Index].TargetActionUp(this.RStick.X, this.RStick.Y, this.Delay, Pressed)
			
			this.Pressed := Pressed
			if(!Pressed)
			{
				this.RStick.Mode := "Target"
				this.LStick.Mode := "Absolute Mouse"
			}
		}
		else
		{
			IgnorePressed := this.IgnorePressed
			this.Button[A_Index].IgnoreActionUp(this.LStick.X, this.LStick.Y, this.Delay, IgnorePressed)
			
			this.IgnorePressed := IgnorePressed
			this.ForceMove := this.PrevForceMove
			
			if(!this.IgnorePressed)
			{
				this.ForceMove := this.OGForceMove
				this.RStick.Mode := "Target"
				this.LStick.Mode := "Absolute Mouse"
			}
		}
	}
	Check_State() 
	{
		this.PrevState := this.State
		Loop, 4 
		{
			if TempState := XInput_GetState(A_Index-1) 
				this.State := TempState
		}
	}
	
	Load_AnalogStick(StickName, Mode) 
	{
		ReadConfig.Load(MaxRadiusX, "config.ini", "Preferences", StickName "_Max_RadiusX")
		ReadConfig.Load(MaxRadiusY, "config.ini", "Preferences", StickName "_Max_RadiusY")
		
		ReadConfig.Load(Cx, "config.ini", "Preferences", StickName "_CenterX")
		ReadConfig.Load(Cy, "config.ini", "Preferences", StickName "_CenterY")
		
		ReadConfig.Load(OffSetX, "config.ini", "Calibration", StickName "_Analog_OffsetX")
		ReadConfig.Load(OffSetY, "config.ini", "Calibration", StickName "_Analog_OffsetY")
		
		ReadConfig.Load(DeadZone, "config.ini", "Preferences", StickName "_Deadzone")
		
		ReadConfig.Load(Threshold, "config.ini", "Calibration", StickName "_Analog_Max")
		
		Stick := new this.AnalogStick(MaxRadiusX, MaxRadiusY, Cx, Cy, OffSetX, OffSetY, DeadZone, Threshold)
		Stick.Mode := Mode
		
		this.Check_State()
		
		return Stick
	}
	
	Load_Buttons() 
	{
		global
		ReadConfig.Load(Delay, "config.ini", "Preferences", "Hold_Delay")
		this.Delay := Delay
		IgnoreTarget := ReadConfig.Load_Ignore()
		
		this.Button[this.A_Button] := new this.Button(XINPUT_GAMEPAD_A, "A_Button", ReadConfig, IgnoreTarget)
		this.Button[this.B_Button] := new this.Button(XINPUT_GAMEPAD_B, "B_Button", ReadConfig, IgnoreTarget)
		this.Button[this.X_Button] := new this.Button(XINPUT_GAMEPAD_X, "X_Button", ReadConfig, IgnoreTarget)
		this.Button[this.Y_Button] := new this.Button(XINPUT_GAMEPAD_Y, "Y_Button", ReadConfig, IgnoreTarget)
		
		this.Button[this.DPad_Up] := new this.Button(XINPUT_GAMEPAD_DPAD_UP, "DPad_Up", ReadConfig, IgnoreTarget)
		this.Button[this.DPad_Down] := new this.Button(XINPUT_GAMEPAD_DPAD_DOWN, "DPad_Down", ReadConfig, IgnoreTarget)
		this.Button[this.DPad_Left] := new this.Button(XINPUT_GAMEPAD_DPAD_LEFT, "DPad_Left", ReadConfig, IgnoreTarget)
		this.Button[this.DPad_Right] := new this.Button(XINPUT_GAMEPAD_DPAD_RIGHT, "DPad_Right", ReadConfig, IgnoreTarget)
		
		this.Button[this.Start_Button] := new this.Button(XINPUT_GAMEPAD_START, "Start_Button", ReadConfig, IgnoreTarget)
		this.Button[this.Back_Button] := new this.Button(XINPUT_GAMEPAD_BACK, "Back_Button", ReadConfig, IgnoreTarget)
		
		this.Button[this.Left_Shoulder] := new this.Button(XINPUT_GAMEPAD_LEFT_SHOULDER, "Left_Shoulder", ReadConfig, IgnoreTarget)
		this.Button[this.Right_Shoulder] := new this.Button(XINPUT_GAMEPAD_RIGHT_SHOULDER, "Right_Shoulder", ReadConfig, IgnoreTarget)

		this.Button[this.Left_Analog_Button] := new this.Button(XINPUT_GAMEPAD_LEFT_THUMB, "Left_Analog_Button", ReadConfig, IgnoreTarget)
		this.Button[this.Right_Analog_Button] := new this.Button(XINPUT_GAMEPAD_RIGHT_THUMB, "Right_Analog_Button", ReadConfig, IgnoreTarget)
		;Loop, 14
			;MsgBox,, Ok, % this.Button[A_Index].PressModifier " + " this.Button[A_Index].PressKey "`n" this.Button[A_Index].HoldModifier " + " this.Button[A_Index].HoldKey
	}

	Delete_Me() 
	{
		Graphics.Delete_Me()
	}
}