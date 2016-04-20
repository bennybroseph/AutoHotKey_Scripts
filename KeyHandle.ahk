#include ReadConfig.ahk
#include Graphics.ahk
#include System.ahk

Class KeyHandle
{
	; Creates a static variable for ReadConfig and Graphics
	; Will be set later in the constructor
	static s_ReadConfig :=
	static s_Graphics 	:=
	
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
		;======== VARIABLE DECLARATIONS ========
		
		m_Timer := 0	; The timer used to determine if this button is being held down or not
		
		m_ButtonHexCode := 0x0000	; The hexidecimal value that represents this button in XInput.ahk
		
		m_PressKey 		:= ""	; The name of the key to be sent when this button is pressed
		m_PressModifier := ""	; The name of the modifier key to be sent in tandem with 'm_PressKey' when this button is pressed
		m_HoldKey 		:= ""	; The name of the key to be sent when this button has been held down
		m_HoldModifier 	:= ""	; The name of the modifier key to be sent in tandem with 'm_HoldKey' when this button has been held down
		
		m_HasIgnoreKey	:= false	; Whether or not this button contains a key which should ignore the targeting system
		m_IgnoreKey 	:= ""		; The name of the key that ignores the targeting system
		
		m_IsPressed := false	; Whether or not the button is pressed down currently
		
		;======== END VARIABLE DECLARATIONS ========
		
		/*
		 -------------------
		 *   Constructor   *
		 -------------------
				Creates a new instance of 'Button' which will hold all the related values for a single button. The 'Button' class contains
			functionality for checking it's pressed or non-pressed state as well as the ability to determine if it has been held down for the 
			required amount of time for a secondary action to take place. The 'Button' class sends input from within the class, and can determine
			which input should be sent internally. This is in contrast to the current version of 'AnalogStick' which requires an outside class
			to send input.
		 -------------------
		 *	 Parameters    *
		 -------------------
		 	a_ButtonHexCode 	: hexidecimal 	= the hex value that represents the button in XInput.ahk
			a_ButtonName 		: string		= the name of the button represented as a string
			a_IgnoreTargetKey	: Array; string = an array which holds each key as a string that should be ignored for targeting reasons
		*/
		__New(a_ButtonHexCode, a_ButtonName, a_IgnoreTargetKey) 
		{ 
			this.m_ButtonHexCode := a_ButtonHexCode
			
			KeyHandle.s_ReadConfig.Load_Button(a_ButtonName, this.m_PressKey, this.m_PressModifier, this.m_HoldKey, this.m_HoldModifier)
			
			this.m_HasIgnoreKey := false
			Loop
			{
				if(((this.m_PressKey = a_IgnoreTargetKey[A_Index] && !this.m_PressModifier)|| a_IgnoreTargetKey[A_Index] = this.m_PressKey "+" this.m_PressModifier) 
				|| ((this.m_HoldKey  = a_IgnoreTargetKey[A_Index] && !this.m_HoldModifier) || a_IgnoreTargetKey[A_Index] = this.m_HoldKey  "+" this.m_HoldModifier))
				{
					this.m_HasIgnoreKey := true
					this.m_IgnoreKey := a_IgnoreTargetKey[A_Index]
				}
			} Until !a_IgnoreTargetKey[A_Index + 1]
		}
		/*
		 -------------------
				Determines if this button is being pressed currently using the bitwise operator '&'. Returns whether the buttons is newly pressed, and
			not was not held down from the last check.
		 -------------------
		 *	 Parameters    *
		 -------------------
			a_State 	: Object = a complex object to represent the state of the controller. 'a_State.Buttons' is going to be the more relevant information
				as it holds the bitmask for the currently held buttons
			a_PrevState : Object = the previous state of the controller
			
			Returns: true if the button was pressed this check or false if it is not pressed or is being held down
		*/
		CheckState(a_State, a_PrevState) 
		{
			if(a_State.Buttons & this.m_ButtonHexCode)
				this.m_IsPressed := true
			else
				this.m_IsPressed := false
			
			if(a_State.Buttons & this.m_ButtonHexCode != a_PrevState.Buttons & this.m_ButtonHexCode)
				return true
			else
				return false
		}
		/*
		 -------------------
				Determines if the button has been held down for the required amount of time to be considered held down and then sends
			the proper action to match as a targeted action.
		 -------------------
		 *	 Parameters    *
		 -------------------
			a_Position	: System.Vector2	= the position to move the mouse before sending the button's keys
			a_Delay 	: integer			= the amount of delay in miliseconds between pressing a button and it being considered held down
			a_Pressed	: integer			= the amount of buttons currently being pressed passed by reference and modified here
			
			Returns: whichever
		*/
		TargetActionDown(a_Position, a_Delay, byRef a_Pressed) 
		{
			local key 		:= ""	; Will store the proper key to be sent as an action
			local modifier	:= ""	; Will store the proper modifier to be sent in tandem with 'key'
			
			; if 'm_HoldKey' has a value stored in it
			if(this.m_HoldKey != "")
			{
				; if this button has been held down for the required amount to be considered held 
				if(this.m_Timer && A_TickCount >= this.m_Timer + a_Delay)
				{
					; Store the held version of keys to be sent later
					key 		:= this.m_HoldKey
					modifier	:= this.m_HoldModifier
					
					this.m_Timer := 0	; Reset the timer
				}
				else
					return	; Continue waiting for the key to either be released or held down long enough before acting
			}
			; there is nothing in 'm_HoldKey'
			else
			{
				; Store the standard version of keys to be sent later
				key 		:= this.m_PressKey
				modifier	:= this.m_PressModifier				
			}
			
			MouseMove, a_Position.X, a_Position.Y	; Move the mouse to the requested position
			Send {%modifier% Down}					; Send the modifier key first
			Send {%key% Down}						; Send the proper key
			
			a_Pressed += 1	; if the function got this far, consider another button currrently pressed
			
			return modifier key
		}
		; Calls the 'TargetActionDown' function using all the same parameters, but also sets the passed 'a_ForceMove' to the return value of 'TargetActionDown'
		IgnoreActionDown(a_Position, a_Delay, byRef a_IgnorePressed, byRef a_ForceMove) 
		{
			local forcemove := this.TargetActionDown(a_Position, a_Delay, a_IgnorePressed)
		
			; if the return value of 'TargetActionDown' wasn't nothing
			if(forcemove)
				a_ForceMove := forcemove
		}
		
		TargetActionUp(a_Position, a_Delay, byRef a_Pressed) 
		{
			local key 		:= ""	; Will store the proper key to be sent as a release action
			local modifier	:= ""	; Will store the proper modifier to be sent in tandem with 'key'
			
			; if 'm_HoldKey' has a value stored in it
			if(this.m_HoldKey)
			{
				; if this button had been held down for the required amount to be considered held 
				if(!this.m_Timer && A_TickCount >= this.m_Timer + a_Delay)
				{
					; Store the held version of keys to be sent as released later
					modifier	:= this.m_HoldModifier
					key 		:= this.m_HoldKey
					
					this.m_Timer := 0	; Reset the timer
				}
				; Otherwise, we need to send the standard key once
				else
				{
					MouseMove, a_Position.X, a_Position.Y	; Move the mouse to the requested position		
					
					; Not particularly needed but does stay consistant with other functionality in this function
					modifier	:= this.m_PressModifier
					key 		:= this.m_PressKey
					
					; Send a down and up action so that the key is registered as pressed in game
					Send {%modifier% Down}		
					Send {%key% Down}
					Send {%modifier% Up}		
					Send {%key% Up}
					
					this.m_Timer := 0	; Reset the timer
					
					return	; Do not continue with the function
				}
			}
			else
			{
				; Store the standard version of keys to be sent later
				modifier	:= this.m_PressModifier				
				key 		:= this.m_PressKey
			}
			
			Send {%modifier% Up}	; Send the modifier key first as released
			Send {%key% Up}			; Send the proper key as released
			
			a_Pressed -= 1	; if the function got this far, consider that a button was released
		}
		; Just calls 'TargetActionUp'. Once completely refactored DELETE THIS FUNCTION
		IgnoreActionUp(a_Position, a_Delay, byRef a_IgnorePressed) 
		{
			this.TargetActionUp(a_Position, a_Delay, a_IgnorePressed)
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
				if(this.Button[A_Index].m_IsPressed)
				{
					if(!this.Button[A_Index].m_HoldKey)
					{
						if(this.Button[A_Index].m_PressKey != "Inventory" && this.Button[A_Index].m_PressKey != "Freedom" && this.Button[A_Index].m_PressKey != "Loot")
							this.ActionDown()
					}
					else
						this.Button[A_Index].m_Timer := A_TickCount
				}
				else
				{
					if(!this.Button[A_Index].m_HoldKey || A_TickCount < this.Button[A_Index].m_Timer + this.Delay)
					{
						if(this.Button[A_Index].m_PressKey != "Inventory" && this.Button[A_Index].m_PressKey != "Freedom" && this.Button[A_Index].m_PressKey != "Loot")
							this.ActionUp()
					}
					else if(this.Button[A_Index].m_HoldKey && A_TickCount >= this.Button[A_Index].m_Timer + this.Delay)
					{
						if(this.Button[A_Index].m_HoldKey != "Inventory" && this.Button[A_Index].m_HoldKey != "Freedom" && this.Button[A_Index].m_HoldKey != "Loot")
							this.ActionUp()
					}
				}				
			}
			else if(this.Button[A_Index].m_IsPressed)
			{
				if(this.Button[A_Index].m_HoldKey && A_TickCount >= this.Button[A_Index].m_Timer + this.Delay)
				{
					if(this.Button[A_Index].m_PressKey != "Inventory" && this.Button[A_Index].m_PressKey != "Freedom" && this.Button[A_Index].m_PressKey != "Loot")
						this.ActionDown()
				}
			}
		}
	}
	
	ActionDown() 
	{
		if(!this.Button[A_Index].m_HasIgnoreKey || this.Button[A_Index].m_PressKey != this.Button[A_Index].m_IgnoreKey)
		{
			Pressed := this.Pressed
			this.Button[A_Index].TargetActionDown(this.RStick.m_Position, this.Delay, Pressed)			
			this.Pressed := Pressed
			
			this.RStick.m_Mode := "Mouse"
			this.LStick.m_Mode := "Absolute Target"
		}
		else
		{
			IgnorePressed := this.IgnorePressed
			ForceMove := this.ForceMove
			this.PrevForceMove := this.ForceMove
			
			this.Button[A_Index].IgnoreActionDown(this.LStick.m_Position, this.Delay, IgnorePressed, ForceMove)
			
			this.IgnorePressed := IgnorePressed
			this.ForceMove := ForceMove
			
			this.RStick.m_Mode := "Target"
			this.LStick.m_Mode := "Absolute Mouse"
		}
	}
	
	ActionUp() 
	{
		if(!this.Button[A_Index].m_HasIgnoreKey || this.Button[A_Index].m_PressKey != this.Button[A_Index].m_IgnoreKey)
		{
			Pressed := this.Pressed
			this.Button[A_Index].TargetActionUp(this.RStick.m_Position, this.Delay, Pressed)
			
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
			this.Button[A_Index].IgnoreActionUp(this.LStick.m_Position, this.Delay, IgnorePressed)
			
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
	
	Load_AnalogStick(a_StickName, a_Mode) 
	{
		local maxRadius := new System.Vector2()
		local center 	:= new System.Vector2()
		local zero 		:= new System.Vector2()		
		local threshold := new System.Vector2()
		
		local deadzone := 0
		
		s_ReadConfig.Load(maxRadius.X, "config.ini", "Preferences", a_StickName "_Max_RadiusX")
		s_ReadConfig.Load(maxRadius.Y, "config.ini", "Preferences", a_StickName "_Max_RadiusY")
		
		s_ReadConfig.Load(center.X, "config.ini", "Preferences", a_StickName "_CenterX")
		s_ReadConfig.Load(center.Y, "config.ini", "Preferences", a_StickName "_CenterY")
		
		s_ReadConfig.Load(zero.X, "config.ini", "Calibration", a_StickName "_Analog_ZeroX")
		s_ReadConfig.Load(zero.Y, "config.ini", "Calibration", a_StickName "_Analog_ZeroY")
		
		s_ReadConfig.Load(threshold.X, "config.ini", "Calibration", a_StickName "_Analog_MaxX")
		s_ReadConfig.Load(threshold.Y, "config.ini", "Calibration", a_StickName "_Analog_MaxY")
		
		s_ReadConfig.Load(deadzone, "config.ini", "Preferences", a_StickName "_Deadzone")
		
		Stick := new this.AnalogStick(maxRadius, center, zero, threshold, deadzone)
		Stick.m_Mode := a_Mode
		
		this.CheckState()
		
		return Stick
	}
	
	Load_Buttons() 
	{
		global
		s_ReadConfig.Load(Delay, "config.ini", "Preferences", "Hold_Delay")
		this.Delay 		:= Delay
		ignoreTargetKey	:= s_ReadConfig.Load_Ignore()
		
		this.Button[this.A_BUTTON] := new this.Button(XINPUT_GAMEPAD_A, "A_Button", ignoreTargetKey)
		this.Button[this.B_BUTTON] := new this.Button(XINPUT_GAMEPAD_B, "B_Button", ignoreTargetKey)
		this.Button[this.X_BUTTON] := new this.Button(XINPUT_GAMEPAD_X, "X_Button", ignoreTargetKey)
		this.Button[this.Y_BUTTON] := new this.Button(XINPUT_GAMEPAD_Y, "Y_Button", ignoreTargetKey)
		
		this.Button[this.DPAD_UP] 		:= new this.Button(XINPUT_GAMEPAD_DPAD_UP, "DPad_Up", ignoreTargetKey)
		this.Button[this.DPAD_DOWN] 	:= new this.Button(XINPUT_GAMEPAD_DPAD_DOWN, "DPad_Down", ignoreTargetKey)
		this.Button[this.DPAD_LEFT] 	:= new this.Button(XINPUT_GAMEPAD_DPAD_LEFT, "DPad_Left", ignoreTargetKey)
		this.Button[this.DPAD_RIGHT] 	:= new this.Button(XINPUT_GAMEPAD_DPAD_RIGHT, "DPad_Right", ignoreTargetKey)
		
		this.Button[this.START_BUTTON] 	:= new this.Button(XINPUT_GAMEPAD_START, "Start_Button", ignoreTargetKey)
		this.Button[this.BACK_BUTTON] 	:= new this.Button(XINPUT_GAMEPAD_BACK, "Back_Button", ignoreTargetKey)
		
		this.Button[this.LEFT_SHOULDER] 	:= new this.Button(XINPUT_GAMEPAD_LEFT_SHOULDER, "Left_Shoulder", ignoreTargetKey)
		this.Button[this.RIGHT_SHOULDER]	:= new this.Button(XINPUT_GAMEPAD_RIGHT_SHOULDER, "Right_Shoulder", ignoreTargetKey)

		this.Button[this.LEFT_ANALOG_BUTTON] 	:= new this.Button(XINPUT_GAMEPAD_LEFT_THUMB, "Left_Analog_Button", ignoreTargetKey)
		this.Button[this.RIGHT_ANALOG_BUTTON] 	:= new this.Button(XINPUT_GAMEPAD_RIGHT_THUMB, "Right_Analog_Button", ignoreTargetKey)
		;Loop, 14
			;MsgBox,, Ok, % this.Button[A_Index].PressModifier " + " this.Button[A_Index].PressKey "`n" this.Button[A_Index].HoldModifier " + " this.Button[A_Index].HoldKey
	}

	Delete_Me() 
	{
		s_Graphics.Delete_Me()
	}
}
