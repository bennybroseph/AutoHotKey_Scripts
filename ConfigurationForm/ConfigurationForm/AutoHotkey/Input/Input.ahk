; Stores classes for all types of input

class Key
{
	__New(p_KeybindString, p_KeybindType, p_Hotkey, p_Target, p_PressFuncString, p_ReleaseFuncString)
	{
		global

		this.m_State 	 	:= False
		this.m_PrevState	:= this.m_State

		this.m_Keybind := IniReader.ParseKeybind(p_KeybindString)
		this.m_Keybind.Type := p_KeybindType

		local _boundFunction := ObjBindMethod(p_Target, p_PressFuncString, this)
		Hotkey, % p_Hotkey, % _boundFunction

		_boundFunction := ObjBindMethod(p_Target, p_ReleaseFuncString, this)
		Hotkey, % p_Hotkey . " Up", % _boundFunction
	}

	State[] {
		get {
			return this.m_State
		}
		set {
			return this.m_State := value
		}
	}
	PrevState[] {
		get {
			return this.m_PrevState
		}
		set {
			return this.m_PrevState := value
		}
	}

	Keybind[] {
		get {
			return this.m_Keybind
		}
	}
}
class Control
{
    __New(p_Name, p_Nickname, p_Index, p_ControlString)
    {
        this.m_Name         	:= p_Name
        this.m_Nickname     	:= p_Nickname
        this.m_Index        	:= p_Index
        this.m_ControlString	:= p_ControlString

        this.m_State        := False
        this.m_PrevState    := this.m_State

        this.m_PressTick    := -1

        this.m_Controlbind   := IniReader.ParseControlbind(this.m_ControlString)
    }

    Name[]
    {
        get {
            return this.m_Name
        }
    }
    Nickname[]
    {
        get {
            return this.m_Nickname
        }
    }
    Index[]
    {
        get {
            return this.m_Index
        }
    }
    ControlString[]
    {
        get {
            return this.m_ControlString
        }
    }

    State[]
    {
        get {
            return this.m_State
        }
    }
    PrevState[]
    {
        get {
            return this.m_PrevState
        }
    }

    PressTick[]
    {
        get {
            return this.m_PressTick
        }
        set {
            return this.m_PressTick := value
        }
    }

    Controlbind[]
    {
        get {
            return this.m_Controlbind
        }
    }

	ParseTargeting()
	{
		global

		local i, _keybind
		For i, _keybind in Controller.TargetedKeybinds
		{
			if (this.m_Controlbind.OnPress.Action = _keybind.Action
			and this.m_Controlbind.OnPress.Modifier = _keybind.Modifier)
				this.m_Controlbind.OnPress.Type := KeybindType.Targeted

			if (this.m_Controlbind.OnHold.Action = _keybind.Action
			and this.m_Controlbind.OnHold.Modifier = _keybind.Modifier)
				this.m_Controlbind.OnHold.Type := KeybindType.Targeted
		}

		For i, _keybind in Controller.MovementKeybinds
		{
			if (this.m_Controlbind.OnPress.Action = _keybind.Action
			and this.m_Controlbind.OnPress.Modifier = _keybind.Modifier)
				this.m_Controlbind.OnPress.Type := KeybindType.Movement

			if (this.m_Controlbind.OnHold.Action = _keybind.Action
			and this.m_Controlbind.OnHold.Modifier = _keybind.Modifier)
				this.m_Controlbind.OnHold.Type := KeybindType.Movement
		}
	}

    RefreshState(p_State)
    {
        this.m_PrevState := this.m_State
    }
}
class Button extends Control
{
    __New(p_Name, p_Nickname, p_Index, p_Key, p_Bitmask)
    {
        base.__New(p_Name, p_Nickname, p_Index, p_Key)

        this.m_Bitmask := p_Bitmask
    }

    RefreshState(p_State)
    {
        base.RefreshState(p_State)

        this.m_State := p_State.Buttons & this.m_Bitmask != 0
    }
}
class DPadButton extends Button
{
	__New(p_Name, p_Nickname, p_Index, p_Key, p_Bitmask)
	{
		base.__New(p_Name, p_Nickname, p_Index, p_Key, p_Bitmask)

		this.m_HoldTick := -1
	}

	HoldTick[]
	{
		get {
		return this.m_HoldTick
		}
		set {
			return this.m_HoldTick := value
		}
	}

}
class Trigger extends Control
{
   __New(p_Name, p_Nickname, p_Index, p_Key, p_Direction)
    {
        base.__New(p_Name, p_Nickname, p_Index, p_Key)

        this.m_Direction := p_Direction

		this.m_TriggerValue := -1
    }

	TriggerValue[]
	{
		get {
			return this.m_TriggerValue
		}
	}
    RefreshState(p_State)
    {
        base.RefreshState(p_State)

        this.m_TriggerValue := this.m_Direction = "Left" ? p_State.LeftTrigger : p_State.RightTrigger
		this.m_State := this.m_TriggerValue > 64
    }
}
class Stick extends Control
{
	static s_MaxValue := 32768

	__New(p_Name, p_Nickname, p_Index, p_Key, p_Direction)
	{
		base.__New(p_Name, p_Nickname, p_Index, p_Key)

		this.m_Direction := p_Direction

		this.m_RawStickValue 		:= new Vector2()
		this.m_RawStickValue 		:= new Vector2()

		this.m_AdjustedStickValue 	:= new Vector2()
		this.m_ClampedStickValue 	:= new Vector2()

		this.m_StickValue 			:= new Vector2()
		this.m_PrevStickValue 		:= new Vector2()

		this.m_StickAngleDeg := new Vector2()
		this.m_StickAngleRad := new Vector2()

		this.m_MaxValue	:= IniReader.ReadConfigKey(ConfigSection.Calibration, this.m_Direction . "_Analog_Max_Value")
		this.m_Deadzone := IniReader.ReadConfigKey(ConfigSection.Calibration, this.m_Direction . "_Analog_Deadzone")

		this.m_Zero
			:= new Vector2(IniReader.ReadConfigKey(ConfigSection.Calibration, this.m_Direction . "_Analog_Zero_Average_X")
						, IniReader.ReadConfigKey(ConfigSection.Calibration, this.m_Direction . "_Analog_Zero_Average_Y"))

		this.m_Sensitivity
			:= new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, this.m_Direction . "_Analog_Cursor_Sensitivity_X")
						,IniReader.ReadProfileKey(ProfileSection.AnalogStick, this.m_Direction . "_Analog_Cursor_Sensitivity_Y"))
	}

	RawStickValue[]
	{
		get {
			return this.m_RawStickValue
		}
	}
	PrevRawStickValue[]
	{
		get {
			return this.m_PrevRawStickValue
		}
	}

	AdjustedStickValue[]
	{
		get {
			return this.m_AdjustedStickValue
		}
	}
	ClampedStickValue[]
	{
		get {
			return this.m_ClampedStickValue
		}
	}

	StickValue[]
	{
		get {
			return this.m_StickValue
		}
	}
	PrevStickValue[]
	{
		get {
			return this.m_PrevStickValue
		}
	}

	StickAngleDeg[]
	{
		get {
			return this.m_StickAngleDeg
		}
	}
	StickAngleRad[]
	{
		get {
			return this.m_StickAngleRad
		}
	}

	MaxValue[]
	{
		get {
			return this.m_MaxValue
		}
	}

	Deadzone[]
	{
		get {
			return this.m_Deadzone
		}
	}

	Sensitivity[]
	{
		get {
			return this.m_Sensitivity
		}
	}

	; http://blog.hypersect.com/interpreting-analog-sticks/
	RefreshState(p_State)
	{
		global

		base.RefreshState(p_State)

		this.m_PrevRawStickValue 	:= this.m_RawStickValue.Clone()
		this.m_PrevStickValue 		:= this.m_StickValue.Clone()

		this.m_RawStickValue.X := (this.m_Direction = "Left" ? p_State.ThumbLX : p_State.ThumbRX) / this.s_MaxValue
		this.m_RawStickValue.Y := (this.m_Direction = "Left" ? p_State.ThumbLY : p_State.ThumbRY) / this.s_MaxValue

		if (Vector2.IsEqual(this.m_RawStickValue, this.m_PrevRawStickValue))
			return

		this.m_AdjustedStickValue := Vector2.Sub(this.m_RawStickValue, this.m_Zero)

		local _scale := 0
		if (this.m_RawStickValue.Magnitude > this.m_Deadzone)
		{
			local _legalRange := this.m_MaxValue - this.m_Deadzone
			local _normalizedMag := Min(1, (this.m_RawStickValue.Magnitude - this.m_Deadzone) / _legalRange)
			_scale := _normalizedMag / this.m_RawStickValue.Magnitude
		}

		this.m_ClampedStickValue := Vector2.Mul(this.m_RawStickValue, _scale)

		this.m_StickValue := this.m_ClampedStickValue.Clone()

		this.m_State := this.m_StickValue.Magnitude > 0

		if (this.m_StickValue.X < 0 and this.m_StickValue.Y < 0)		; 3rd Quadrant
            this.m_StickAngleDeg := Abs(ATan(this.m_StickValue.Y / this.m_StickValue.X) * (180 / PI)) + 180
        else if (this.m_StickValue.X < 0 and this.m_StickValue.Y > 0)	; 2nd Quadrant
            this.m_StickAngleDeg := 180 - Abs(ATan(this.m_StickValue.Y / this.m_StickValue.X) * (180 / PI))
        else if (this.m_StickValue.X > 0 and this.m_StickValue.Y < 0)	; 4th Quadrant
            this.m_StickAngleDeg := 360 - Abs(ATan(this.m_StickValue.Y / this.m_StickValue.X) * (180 / PI))
        else if (this.m_StickValue.X = 0 and this.m_StickValue.Y > 0)
            this.m_StickAngleDeg := 90
        else if (this.m_StickValue.X = 0 and this.m_StickValue.Y < 0)
            this.m_StickAngleDeg := 270
        else if (this.m_StickValue.X < 0 and this.m_StickValue.Y = 0)
            this.m_StickAngleDeg := 180
        else															; 1st Quadrant
            this.m_StickAngleDeg := Abs(ATan(this.m_StickValue.Y / this.m_StickValue.X) * (180 / PI))

        this.m_StickAngleRad := this.m_StickAngleDeg * (PI / 180)
	}
}