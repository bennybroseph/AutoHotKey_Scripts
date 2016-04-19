#include ReadConfig.ahk
#include Graphics.ahk
#include System.ahk

Class KeyHandle
{
	; Creates a static variable for ReadConfig and Graphics
	; Will be set later in the constructor
	static s_ReadConfig :=
	static s_Graphics 	:=
	
	IgnoreTarget 	:= Array()	; Creates an array to hold the ignore target keys
	Pressed 		:= 0		; Number of buttons that are currently pressed down
	IgnorePressed 	:= 0		; Number of buttons that are currently pressed down which are considered IgnoreTarget buttons
	
	;======== CONSTANTS ========
	
	; These are a way to reference an array index with a readable index rather than a number 
	A_BUTTON := 1
	B_BUTTON := 2
	X_BUTTON := 3
	Y_BUTTON := 4

	DPAD_UP 	:= 5
	DPAD_DOWN 	:= 6
	DPAD_LEFT 	:= 7
	DPAD_RIGHT 	:= 8

	START_BUTTON 	:= 9
	BACK_BUTTON 	:= 10

	LEFT_SHOULDER 	:= 11
	RIGHT_SHOULDER 	:= 12

	LEFT_ANALOG_BUTTON := 13
	RIGHT_ANALOG_BUTTON := 14
	
	;=============== END CONSTANTS =================
	
	Class AnalogStick
	{	
		;======== VARIABLE DECLARATIONS ========
		
		m_IsInUse := false	; Whether or not the stick is in use/moving according to the 'm_Deadzone' and 'm_Zero'
		
		m_MaxRadius := new System.Vector2()	; The radius of the oval to calculate the position of the target
		m_Center 	:= new System.Vector2()	; The center position of the oval used to calculate the position of the target
		m_Zero 		:= new System.Vector2()	; The position to consider the stick at rest		
		m_Threshold := new System.Vector2()	; The largest value the analog sticks should be allowed to read. Anything above this value is clamped down
		m_Deadzone 	:= 0					; The value used to define the threshold to determine if the stick is currently being pushed in a direction
		
		m_StickPosition := new System.Vector2()	; The stick's actual position
		m_StickValue 	:= new System.Vector2()	; The stick's current position after calculating the 'm_Zero' offset
		
		m_Angle 	:= 0	; The angle in radians that the stick has been calculated to be at
		m_AngleDeg  := 0	; The angle in degrees that the stick has been calculated to be at
		
		m_Radius := new System.Vector2()	; The radius of the oval that will be used to determine the 'm_Position' vector2
		
		m_Position := new System.Vector2()	; The calculated position where the cursor/target should be drawn depending on the mode
		
		m_Mode := ""	; The mode used for this stick represented as a string
		
		;======== END VARIABLE DECLARATIONS ========
		
		/*
		 -------------------
		 *   Constructor   *
		 -------------------
				Creates a new instance of 'AnalogStick' which will hold values related to one of the analog sticks on
			the controller. Which stick this instance represents is handled by the KeyHandle. This class just calculates
			values based on input, the KeyHandle determines how they are displayed to the user how it affects the game
		 -------------------
		 *	 Parameters    *
		 -------------------
		 	a_MaxRadius : System.Vector2 = the radius of the oval to calculate the position of the target
			a_Center 	: System.Vector2 = the center position of the oval used to calculate the position of the target
			a_Zero 		: System.Vector2 = the position to consider the stick at rest			
			a_Threshold : System.Vector2 = the largest value the analog sticks should be allowed to read. Anything above this value is clamped down			
			a_Deadzone 	: integer 		 = the value used to define the threshold to determine if the stick is currently being pushed in a direction
		*/
		__New(a_MaxRadius, a_Center, a_Zero, a_Threshold, a_Deadzone) 
		{
			this.m_MaxRadius	:= a_MaxRadius
			this.m_Center 		:= a_Center
			this.m_Zero 		:= a_Zero			
			this.m_Threshold 	:= a_Threshold			
			this.m_Deadzone 	:= a_Deadzone
		}
		/*
		 -------------------
			Updates the 'm_StickValue' variable and calculates whether the stick is in use or not
		 -------------------
		 *	 Parameters    *
		 -------------------
			a_Position : System.Vector2 = the vector2 position to use for calculating whether the stick is in use or not
			
			Returns: true is the stick is in use; false otherwise
		*/
		CheckState(a_Position) 
		{
			this.m_StickPosition := a_Position
			
			; This takes the current value of the stick's axii and subtracts the value when the stick is at rest to 'zero out' the value before calculations
			this.m_StickValue.X := this.m_StickPosition.X - this.m_Zero.X 
			this.m_StickValue.Y := this.m_StickPosition.Y - this.m_Zero.Y 
			
			if (Abs(this.m_StickValue.X) > this.m_Deadzone || Abs(this.m_StickValue.Y) > this.m_Deadzone)
				this.m_IsInUse := true
			else
				this.m_IsInUse := false
				
			return this.m_IsInUse
		}
		/*
		 -------------------
				Calculates the angle the stick is currently at based on 'm_StickValue' in degrees for readability/debugging 
			and then converts it back to radians for further calculations.
		 -------------------
			Returns: the calculated angle in radians
		*/
		CalcAngle() 
		{
			if (this.m_StickValue.X < 0 && this.m_StickValue.Y < 0) ; 3rd Quadrant
			{
				this.m_AngleDeg := Abs(ATan(this.m_StickValue.Y / this.m_StickValue.X) * (180 /PI )) + 180
			}
			else if (this.m_StickValue.X < 0 && this.m_StickValue.Y > 0) ; 2nd Quadrant
			{    
				this.m_AngleDeg := 180 - Abs(ATan(this.m_m_StickValue.Y / this.m_StickValue.X) * (180 / PI))
			}
			else if(this.m_StickValue.X > 0 && this.m_StickValue.Y < 0) ; 4th Quadrant
			{
				this.m_AngleDeg := 360 - Abs(ATan(this.m_StickValue.Y / this.m_StickValue.X) * (180 / PI))
			}
			else if (this.m_StickValue.X = 0 && this.m_StickValue.Y > 0) ; ATan Error would occur since angle is 90
			{
				this.m_AngleDeg := 90
			}
			else if (this.m_StickValue.X = 0 && this.m_StickValue.Y < 0) ; ATan Error would occur since angle is 270
			{
				this.m_AngleDeg := 270
			}
			else if (this.m_StickValue.X < 0 && this.m_StickValue.Y = 0) ; Differentiate between 0 and 180 degrees
			{
				this.m_AngleDeg := 180
			}                 
			else ; 1st Quadrant
			{
				this.m_AngleDeg := Abs(ATan(this.m_StickValue.Y / this.m_StickValue.X) * (180 / PI))
			}
				
			this.m_Angle := -this.m_AngleDeg * (PI / 180) ; Convert the angle back into radians for calculation
			
			return this.m_Angle
		}
		/*
		 -------------------
			Calculates the oval's radii used to eventually determine the 'm_Position'
		 -------------------
		 *	 Parameters    *
		 -------------------
			a_Radius : System.Vector2 = the radius that the new oval should be based off of depending on how much the user is pushing the stick
		*/
		CalcRadius(a_Radius) 
		{
			; The analog stick returns a lumpy square as movement. With this, I cut a proper square out of it by limiting the furthest the stick is pressed before I stop registering it		
			if(Abs(this.m_StickValue.X) > this.m_Threshold.X)
			{
				if(this.m_StickValue.X > 0)
					this.m_StickValue.X := this.m_Threshold.X
				else
					this.m_StickValue.X := -this.m_Threshold.X
			}
			if(Abs(this.m_StickValue.Y) > this.m_Threshold.Y)
			{
				if(this.m_StickValue.Y > 0)
					this.m_StickValue.Y := this.m_Threshold.Y
				else	
					this.m_StickValue.Y := -this.m_Threshold.Y
			}
			
			; Which ever value is higher (either m_StickValue.X or m_StickValue.Y), that value is used to calculate the radii
			if(Abs(this.m_StickValue.X) >= Abs(this.m_StickValue.Y))
			{
				this.m_Radius.X := a_Radius.X * ((Abs(this.m_StickValue.X) - this.m_Deadzone) / (this.m_Threshold.X - this.m_Deadzone))
				this.m_Radius.Y := a_Radius.Y * ((Abs(this.m_StickValue.X) - this.m_Deadzone) / (this.m_Threshold.X - this.m_Deadzone))
			}
			else
			{
				this.m_Radius.X := a_Radius.X * ((Abs(this.m_StickValue.Y) - this.m_Deadzone) / (this.m_Threshold.Y - this.m_Deadzone))
				this.m_Radius.Y := a_Radius.Y * ((Abs(this.m_StickValue.Y) - this.m_Deadzone) / (this.m_Threshold.Y - this.m_Deadzone))
			}
		}
		/*
		 -------------------
			Calculates cursor/target's position based on the radii passed
		 -------------------
		 *	 Parameters    *
		 -------------------
			a_Radius : System.Vector2 = the radius that the position should be based on
				DEFAULT: string = set to "NULL" as a place holder to determine when no value was passed and act accordingly
		*/
		CalcPosition(a_Radius := "NULL") 
		{
			if(a_Radius != "NULL")
			{
				; http://math.stackexchange.com/questions/22064/calculating-a-point-that-lies-on-an-ellipse-given-an-angle
				this.m_Position.X := (this.m_Center.X) + (a_Radius.X * a_Radius.Y) / Sqrt((a_Radius.Y ** 2) + (a_Radius.X ** 2) * (tan(this.m_Angle) ** 2))
				this.m_Position.Y := (this.m_Center.Y) + (a_Radius.X * a_Radius.Y * tan(this.m_Angle)) / Sqrt((a_Radius.Y **2 ) + (a_Radius.X ** 2) * (tan(this.m_Angle) ** 2))
				
				; Because of the way the calculation goes, whenever the angle is in the 2nd and 3rd quadrant it needs to be translated
				if(this.AngleDeg > 90 && this.AngleDeg <= 270)
				{
					this.m_Position.X := (this.m_Center.X) - (this.X - this.m_Center.X)
					this.m_Position.Y := (this.m_Center.Y) - (this.Y - this.m_Center.Y)
				}
			}
			else
			{
				this.m_Position.X := this.m_Center.X
				this.m_Position.Y := this.m_Center.Y
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
		
		CheckState(State, PrevState) 
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
		s_ReadConfig := new ReadConfig()
		s_Graphics := new Graphics()
		
		this.LStick := this.Load_AnalogStick("Left", "Absolute Mouse")
		this.RStick := this.Load_AnalogStick("Right", "Target")
		
		ReadConfig.Load(OGForceMove, "config.ini", "Buttons", "Force_Move")
		this.OGForceMove := OGForceMove
		this.ForceMove := OGForceMove
		
		this.Load_Buttons()
	}
	
	Handle() 
	{
		this.CheckState()
		
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
		
		Stick.CheckState(Var1, Var2)	
		Stick.CalcAngle()
		Stick.CalcRadius(Stick.m_MaxRadius)		
		
		if(Stick.m_Mode = "Absolute Mouse")
		{
			if(Stick.m_IsInUse)
				Stick.CalcPosition(Stick.m_MaxRadius)
			else
				Stick.CalcPosition()
			MouseMove, Stick.m_Position.X, Stick.m_Position.Y
			
			if(Stick.m_IsInUse)
				Send {%ForceMove% Down}
			else
				Send {%ForceMove% Up}
		}
		else if(Stick.m_Mode = "Absolute Target")
		{
			if(Stick.m_IsInUse)
				Stick.CalcPosition(Stick.m_MaxRadius)
			else 
				Stick.CalcPosition()
			s_Graphics.Draw_Target(Stick.m_Position.X, Stick.m_Position.Y)
		}
		else if(Stick.m_Mode = "Mouse")
		{
			if(Stick.m_IsInUse)
				Stick.CalcPosition(Stick.m_Radius)
			else
				Stick.CalcPosition()
			MouseMove, Stick.m_Position.X, Stick.m_Position.Y
		}
		else if(Stick.m_Mode = "Target")
		{
			if(Stick.m_IsInUse)
			{
				Stick.CalcPosition(Stick.m_Radius)
				s_Graphics.Draw_Target(Stick.m_Position.X, Stick.m_Position.Y)
			}
			else 
			{
				Stick.CalcPosition()
				s_Graphics.Hide_Target()
			}
		}		
		
		;if(StickAbv = "L")
			;Tooltip , % StickAbv ":" Stick.m_Mode "`n" Stick.X ":" Stick.Y "`n" Stick.AngleDeg "`n" Stick.RadiusX ":" Stick.RadiusY "`n" Stick.MaxRadiusX ":" Stick.MaxRadiusY
	}
	
	Handle_Buttons()
	{
		Loop, 14
		{
			if(this.Button[A_Index].CheckState(this.State, this.PrevState))
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
			
			this.RStick.m_Mode := "Mouse"
			this.LStick.m_Mode := "Absolute Target"
		}
		else
		{
			IgnorePressed := this.IgnorePressed
			ForceMove := this.ForceMove
			this.PrevForceMove := this.ForceMove
			
			this.Button[A_Index].IgnoreActionDown(this.LStick.X, this.LStick.Y, this.Delay, IgnorePressed, ForceMove)
			
			this.IgnorePressed := IgnorePressed
			this.ForceMove := ForceMove
			
			this.RStick.m_Mode := "Target"
			this.LStick.m_Mode := "Absolute Mouse"
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
				this.RStick.m_Mode := "Target"
				this.LStick.m_Mode := "Absolute Mouse"
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
				this.RStick.m_Mode := "Target"
				this.LStick.m_Mode := "Absolute Mouse"
			}
		}
	}
	CheckState() 
	{
		this.PrevState := this.State
		Loop, 4 
		{
			if TempState := XInput_GetState(A_Index-1) 
				this.State := TempState
		}
	}
	
	Load_AnalogStick(a_StickName, a_m_Mode) 
	{
		local maxRadius := new System.Vector2()
		local center 	:= new System.Vector2()
		local zero 		:= new System.Vector2()		
		local threshold := new System.Vector2()
		
		local deadzone := 0
		
		s_ReadConfig.Load(MaxRadius.X, "config.ini", "Preferences", a_StickName "_Max_RadiusX")
		s_ReadConfig.Load(MaxRadius.Y, "config.ini", "Preferences", StickName "_Max_RadiusY")
		
		s_ReadConfig.Load(center.X, "config.ini", "Preferences", a_StickName "_CenterX")
		s_ReadConfig.Load(center.Y, "config.ini", "Preferences", a_StickName "_CenterY")
		
		s_ReadConfig.Load(zero.X, "config.ini", "Calibration", a_StickName "_Analog_ZeroX")
		s_ReadConfig.Load(zero.Y, "config.ini", "Calibration", a_StickName "_Analog_ZeroY")
		
		s_ReadConfig.Load(threshold.X, "config.ini", "Calibration", a_StickName "_Analog_MaxX")
		s_ReadConfig.Load(threshold.Y, "config.ini", "Calibration", a_StickName "_Analog_MaxY")
		
		s_ReadConfig.Load(deadzone, "config.ini", "Preferences", a_StickName "_Deadzone")
		
		Stick := new this.AnalogStick(maxRadius, center, zero, threshold, deadzone)
		Stick.m_Mode := a_m_Mode
		
		this.CheckState()
		
		return Stick
	}
	
	Load_Buttons() 
	{
		global
		s_ReadConfig.Load(Delay, "config.ini", "Preferences", "Hold_Delay")
		this.Delay 		:= Delay
		IgnoreTarget 	:= s_ReadConfig.Load_Ignore()
		
		this.Button[this.A_BUTTON] := new this.Button(XINPUT_GAMEPAD_A, "A_Button", s_ReadConfig, IgnoreTarget)
		this.Button[this.B_BUTTON] := new this.Button(XINPUT_GAMEPAD_B, "B_Button", s_ReadConfig, IgnoreTarget)
		this.Button[this.X_BUTTON] := new this.Button(XINPUT_GAMEPAD_X, "X_Button", s_ReadConfig, IgnoreTarget)
		this.Button[this.Y_BUTTON] := new this.Button(XINPUT_GAMEPAD_Y, "Y_Button", s_ReadConfig, IgnoreTarget)
		
		this.Button[this.DPAD_UP] 		:= new this.Button(XINPUT_GAMEPAD_DPAD_UP, "DPad_Up", s_ReadConfig, IgnoreTarget)
		this.Button[this.DPAD_DOWN] 	:= new this.Button(XINPUT_GAMEPAD_DPAD_DOWN, "DPad_Down", s_ReadConfig, IgnoreTarget)
		this.Button[this.DPAD_LEFT] 	:= new this.Button(XINPUT_GAMEPAD_DPAD_LEFT, "DPad_Left", s_ReadConfig, IgnoreTarget)
		this.Button[this.DPAD_RIGHT] 	:= new this.Button(XINPUT_GAMEPAD_DPAD_RIGHT, "DPad_Right", s_ReadConfig, IgnoreTarget)
		
		this.Button[this.START_BUTTON] 	:= new this.Button(XINPUT_GAMEPAD_START, "Start_Button", s_ReadConfig, IgnoreTarget)
		this.Button[this.BACK_BUTTON] 	:= new this.Button(XINPUT_GAMEPAD_BACK, "Back_Button", s_ReadConfig, IgnoreTarget)
		
		this.Button[this.LEFT_SHOULDER] 	:= new this.Button(XINPUT_GAMEPAD_LEFT_SHOULDER, "Left_Shoulder", s_ReadConfig, IgnoreTarget)
		this.Button[this.RIGHT_SHOULDER]	:= new this.Button(XINPUT_GAMEPAD_RIGHT_SHOULDER, "Right_Shoulder", s_ReadConfig, IgnoreTarget)

		this.Button[this.LEFT_ANALOG_BUTTON] 	:= new this.Button(XINPUT_GAMEPAD_LEFT_THUMB, "Left_Analog_Button", s_ReadConfig, IgnoreTarget)
		this.Button[this.RIGHT_ANALOG_BUTTON] 	:= new this.Button(XINPUT_GAMEPAD_RIGHT_THUMB, "Right_Analog_Button", s_ReadConfig, IgnoreTarget)
		;Loop, 14
			;MsgBox,, Ok, % this.Button[A_Index].PressModifier " + " this.Button[A_Index].PressKey "`n" this.Button[A_Index].HoldModifier " + " this.Button[A_Index].HoldKey
	}

	Delete_Me() 
	{
		s_Graphics.Delete_Me()
	}
}
