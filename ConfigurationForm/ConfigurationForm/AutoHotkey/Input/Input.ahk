; Stores classes for all types of input

class Control
{
    __New(p_Name, p_Nickname, p_Index, p_Key)
    {
        this.m_Name         := p_Name
        this.m_Nickname     := p_Nickname
        this.m_Index        := p_Index
        this.m_Key          := p_Key

        this.m_State        := False
        this.m_PrevState    := this.m_State

        this.m_PressTick    := -1

        this.m_Controlbind   := IniReader.ParseControlbind(this.m_Key)

		Debug.AddToLog(this.m_Name . " OnPress: "
			. this.m_Controlbind.OnPress.Action
			. (this.m_Controlbind.OnPress.Modifier ? " + " . this.m_Controlbind.OnPress.Modifier : ""))
		Debug.AddToLog(this.m_Name . " OnHold: "
			. this.m_Controlbind.OnHold.Action
			. (this.m_Controlbind.OnHold.Modifier ? " + " . this.m_Controlbind.OnHold.Modifier : ""))
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
    Key[]
    {
        get {
            return this.m_Key
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
		For i, _keybind in Controller.TargetedKeybinds
		{
			if (this.m_Controlbind.OnPress.Action = _keybind.Action
			and this.m_Controlbind.OnPress.Modifier = _keybind.Modifier)
				this.m_Controlbind.OnPress.IsTargeted := True

			if (this.m_Controlbind.OnHold.Action = _keybind.Action
			and this.m_Controlbind.OnHold.Modifier = _keybind.Modifier)
				this.m_Controlbind.OnHold.IsTargeted := True
		}

		For i, _keybind in Controller.IgnoreReticuleKeybinds
		{
			if (this.m_Controlbind.OnPress.Action = _keybind.Action
			and this.m_Controlbind.OnPress.Modifier = _keybind.Modifier)
				this.m_Controlbind.OnPress.IgnoreReticule := True

			if (this.m_Controlbind.OnHold.Action = _keybind.Action
			and this.m_Controlbind.OnHold.Modifier = _keybind.Modifier)
				this.m_Controlbind.OnHold.IgnoreReticule := True
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
	__New(p_Name, p_Nickname, p_Index, p_Key, p_Direction)
	{
		base.__New(p_Name, p_Nickname, p_Index, p_Key)

		this.m_Direction := p_Direction

		this.m_StickValue 		:= new Vector2()
		this.m_PrevStickValue 	:= new Vector2()

		this.m_StickDelta := new Vector2()

		this.m_StickAngleDeg := new Vector2()
		this.m_StickAngleRad := new Vector2()

		this.m_MaxValue
			:= new Vector2(IniReader.ReadConfigKey(ConfigSection.Calibration, this.m_Direction . "_Analog_Max")
						,IniReader.ReadConfigKey(ConfigSection.Calibration, this.m_Direction . "_Analog_Max"))
		this.m_MinValue
			:= new Vector2(IniReader.ReadConfigKey(ConfigSection.Calibration, this.m_Direction . "_Analog_XZero")
						,IniReader.ReadConfigKey(ConfigSection.Calibration, this.m_Direction . "_Analog_YZero"))

		this.m_Radius
			:= new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, this.m_Direction . "_Analog_XRadius")
						,IniReader.ReadProfileKey(ProfileSection.AnalogStick, this.m_Direction . "_Analog_YRadius"))
		this.m_Deadzone := IniReader.ReadProfileKey(ProfileSection.AnalogStick, this.m_Direction . "_Analog_Deadzone")

		this.m_Sensitivity
			:= new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, this.m_Direction . "_Analog_Cursor_XSensitivity")
						,IniReader.ReadProfileKey(ProfileSection.AnalogStick, this.m_Direction . "_Analog_Cursor_YSensitivity"))
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

	StickDelta[]
	{
		get {
			return this.m_StickDelta
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
	MinValue[]
	{
		get {
			return this.m_MinValue
		}
	}

	Radius[]
	{
		get {
			return this.m_Radius
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

	RefreshState(p_State)
	{
		base.RefreshState(p_State)

		this.m_PrevStickValue := new Vector2(this.m_StickValue.X, this.m_StickValue.Y)

		this.m_StickValue.X := (this.m_Direction = "Left" ? p_State.ThumbLX : p_State.ThumbRX) - this.m_MinValue.X
		this.m_StickValue.Y := (this.m_Direction = "Left" ? p_State.ThumbLY : p_State.ThumbRY) - this.m_MinValue.Y

		this.m_StickDelta.X := (this.m_StickValue.X - this.m_PrevStickValue.X) * this.m_Sensitivity.X
		this.m_StickDelta.Y := (this.m_StickValue.Y - this.m_PrevStickValue.Y) * this.m_Sensitivity.Y

		this.m_State := Abs(this.m_StickValue.X) > this.m_Deadzone or Abs(this.m_StickValue.Y) > this.m_Deadzone

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

        this.m_StickAngleRad := (this.m_Direction = "Left" ? -1 : 1) * this.m_StickAngleDeg * (PI / 180)
	}
}