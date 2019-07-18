; Stores Keybinds

class ControlIndex
{
    static A			:= 1
    static B			:= 2
    static X 			:= 3
    static Y			:= 4

    static DPadUp		:= 5
    static DPadDown		:= 6
    static DPadLeft		:= 7
    static DPadRight	:= 8

    static LShoulder	:= 9
    static RShoulder	:= 10

    static LTrigger		:= 11
    static RTrigger		:= 12

	static Start		:= 13
    static Back         := 14

	static LThumb		:= 15
    static RThumb		:= 16

    static Guide        := 17
}
class StickIndex
{
	static Left 	:= 1
	static Right 	:= 2
}

class ControlInfo
{
	__New(p_Control, p_Act)
	{
		this.m_Control := p_Control
		this.m_Act := p_Act
	}

	Control[]
	{
		get {
			return this.m_Control
		}
	}
	Act[]
	{
		get {
			return this.m_Act
		}
	}
}

class PressCounter
{
    __New()
    {
        this.m_Targeted	:= 0
        this.m_Movement	:= 0
    }

    Targeted[]
    {
        get {
            return this.m_Targeted
        }
        set {
            return this.m_Targeted := value
        }
    }
    Movement[]
    {
        get {
            return this.m_Movement
        }
        set {
            return this.m_Movement := value
        }
    }
}

class Controller
{
    static __singleton :=
    static __init := False

    Init()
    {
		global

        this.__singleton := new Controller()

		local i, _control
		For i, _control in this.Controls
			_control.ParseTargeting()

		Debug.AddToOnToolTip(new Delegate(Controller, "OnToolTip"))

		local _cursorModeAtStart 		:= IniReader.ReadProfileKey(ProfileSection.Preferences, "Cursor_Mode_At_Start")
		if (_cursorModeAtStart)
			this.EnableCursorMode()

		local _freeTargetModeAtStart 	:= IniReader.ReadProfileKey(ProfileSection.Preferences, "FreeTarget_Mode_At_Start")
		if (_freeTargetModeAtStart)
			this.EnableFreeTargetMode()

		local _swapSticksAtStart		:= IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Swap_Sticks_At_Start")
		if (_swapSticksAtStart)
			this.SwapSticks()

        this.__init := True
    }

    __New()
    {
		global

        this.m_CursorMode       := False
        this.m_FreeTargetMode   := False

        this.m_ShowCursorModeNotification
			:= IniReader.ReadProfileKey(ProfileSection.Preferences, "Show_Cursor_Mode_Notification")
		this.m_ShowFreeTargetModeNotification
			:= IniReader.ReadProfileKey(ProfileSection.Preferences, "Show_FreeTarget_Mode_Notification")

        this.m_MoveOnlyKey := IniReader.ParseKeybind(IniReader.ReadKeybindingKey(KeybindingSection.Keybindings, "Force_Move"))
        this.m_Moving 			:= False
        this.m_ForceMouseUpdate := True

        this.m_UsingReticule 		:= False
        this.m_ForceReticuleUpdate 	:= True

        this.m_MouseOffset
            := new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Movement_Center_Offset_X")
                        , IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Movement_Center_Offset_Y"))
        this.m_TargetOffset
            := new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Targeting_Center_Offset_X")
                        , IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Targeting_Center_Offset_Y"))

        this.m_TargetedKeybinds	:= IniReader.ParseKeybindArray("Targeted_Actions")
        this.m_MovementKeybinds	:= IniReader.ParseKeybindArray("Movement_Actions")

		this.m_PressStack := new LooseStack()
        this.m_PressCount := new PressCounter()

		this.m_LootDelay 		:= IniReader.ReadProfileKey(ProfileSection.Preferences, "Loot_Delay")
		this.m_TargetingDelay	:= IniReader.ReadProfileKey(ProfileSection.Preferences, "Targeting_Delay")
		this.m_HoldDelay 		:= IniReader.ReadProfileKey(ProfileSection.Preferences, "Hold_Delay")

		this.m_VibeStrength := IniReader.ReadProfileKey(ProfileSection.Preferences, "Vibration_Strength")
		this.m_VibeDuration := IniReader.ReadProfileKey(ProfileSection.Preferences, "Vibration_Duration")

		this.m_MovementRadius
			:= new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Movement_Radius_Width")
						,IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Movement_Radius_Height"))
		this.m_TargetRadius
			:= new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Targeting_Radius_Width")
						,IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Targeting_Radius_Height"))

		this.m_Controls := Array()

        this.m_Controls[ControlIndex.A] := new Button("A Button", "A", ControlIndex.A, "A_Button", XINPUT_GAMEPAD_A)
        this.m_Controls[ControlIndex.B] := new Button("B Button", "B", ControlIndex.B, "B_Button", XINPUT_GAMEPAD_B)
        this.m_Controls[ControlIndex.X] := new Button("X Button", "X", ControlIndex.X, "X_Button", XINPUT_GAMEPAD_X)
        this.m_Controls[ControlIndex.Y] := new Button("Y Button", "Y", ControlIndex.Y, "Y_Button", XINPUT_GAMEPAD_Y)

        this.m_Controls[ControlIndex.DPadUp]
			:= new DPadButton("D-pad Up", "Up", ControlIndex.DPadUp, "D-Pad_Up", XINPUT_GAMEPAD_DPAD_UP)
        this.m_Controls[ControlIndex.DPadDown]
			:= new DPadButton("D-pad Down", "Down", ControlIndex.DPadDown, "D-Pad_Down", XINPUT_GAMEPAD_DPAD_DOWN)
        this.m_Controls[ControlIndex.DPadLeft]
			:= new DPadButton("D-pad Left", "Left", ControlIndex.DPadLeft, "D-Pad_Left", XINPUT_GAMEPAD_DPAD_LEFT)
        this.m_Controls[ControlIndex.DPadRight]
			:= new DPadButton("D-pad Right", "Right", ControlIndex.DPadRight, "D-Pad_Right", XINPUT_GAMEPAD_DPAD_RIGHT)

		this.m_Controls[ControlIndex.LShoulder]
            := new Button("Left Bumper", "LB", ControlIndex.LShoulder, "Left_Bumper", XINPUT_GAMEPAD_LEFT_SHOULDER)
        this.m_Controls[ControlIndex.RShoulder]
            := new Button("Right Bumper", "RB", ControlIndex.RShoulder, "Right_Bumper", XINPUT_GAMEPAD_RIGHT_SHOULDER)

		this.m_Controls[ControlIndex.LTrigger] := new Trigger("Left Trigger", "LT", ControlIndex.LTrigger, "Left_Trigger", "Left")
        this.m_Controls[ControlIndex.RTrigger] := new Trigger("Right Trigger", "RT", ControlIndex.RTrigger, "Right_Trigger", "Right")

        this.m_Controls[ControlIndex.Start]
			:= new Button("Start Button", "Start", ControlIndex.Start, "Start_Button", XINPUT_GAMEPAD_START)
        this.m_Controls[ControlIndex.Back]
			:= new Button("Back Button", "Back", ControlIndex.Back, "Back_Button", XINPUT_GAMEPAD_BACK)

        this.m_Controls[ControlIndex.LThumb]
            := new Button("Left Stick Button", "LS", ControlIndex.LThumb, "Left_Stick_Button", XINPUT_GAMEPAD_LEFT_THUMB)
        this.m_Controls[ControlIndex.RThumb]
            := new Button("Right Stick Button", "RS", ControlIndex.RThumb, "Right_Stick_Button", XINPUT_GAMEPAD_RIGHT_THUMB)

		this.m_Controls[ControlIndex.Guide]
			:= new Button("Guide Button", "Guide", ControlIndex.Guide, "Guide_Button", XINPUT_GAMEPAD_GUIDE)

		this.m_LeftStick := new Stick("Left Analog Stick", "Left Stick", StickIndex.Left, "Force_Move", "Left")
		this.m_RightStick := new Stick("Right Analog Stick", "Right Stick", StickIndex.Right, "Right_Stick_Button", "Right")

        this.m_MovementStick    := this.m_LeftStick
        this.m_TargetStick      := this.m_RightStick

        this.m_MousePos		:= InputHelper.GetMousePos()
        this.m_TargetPos	:= new Vector2(this.m_MousePos.X, this.m_MousePos.Y)

		this.m_BatteryStatus := -1
		this.m_BatteryImages
			:= Array(new Image("Images\Battery_Low.png", 0.25)
					, new Image("Images\Battery_Medium.png", 0.25)
					, new Image("Images\Battery_High.png", 0.25))

		local i, _batteryImage
		For i, _batteryImage in this.m_BatteryImages
			Graphics.HideImage(_batteryImage)
    }

    CursorMode[]
    {
        get {
            return this.__singleton.m_CursorMode
        }
    }
    FreeTargetMode[]
    {
        get {
            return this.__singleton.m_FreeTargetMode
        }
    }

	ShowCursorModeNotification[]
	{
		get {
			return this.__singleton.m_ShowCursorModeNotification
		}
	}
	ShowFreeTargetModeNotification[]
	{
		get {
			return this.__singleton.m_ShowFreeTargetModeNotification
		}
	}
	ShowInventoryModeNotification[]
	{
		get {
			return this.__singleton.m_ShowInventoryModeNotification
		}
	}

    MoveOnlyKey[]
    {
        get {
            return this.__singleton.m_MoveOnlyKey
        }
    }
    Moving[]
    {
        get {
            return this.__singleton.m_Moving
        }
    }
    ForceMouseUpdate[]
    {
        get {
            return this.__singleton.m_ForceMouseUpdate
        }
		set {
			return this.__singleton.m_ForceMouseUpdate := value
		}
    }

    UsingReticule[]
    {
        get {
            return this.__singleton.m_UsingReticule
        }
    }
    ForceReticuleUpdate[]
    {
        get {
            return this.__singleton.m_ForceReticuleUpdate
        }
		set {
			return this.__singleton.m_ForceReticuleUpdate := value
		}
    }

    MouseOffset[]
    {
        get {
            return this.__singleton.m_MouseOffset
        }
    }
    TargetOffset[]
    {
        get {
            return this.__singleton.m_TargetOffset
        }
    }

	TargetedKeybinds[]
	{
		get {
			return this.__singleton.m_TargetedKeybinds
		}
	}
	MovementKeybinds[]
	{
		get {
			return this.__singleton.m_MovementKeybinds
		}
	}

	PressStack[]
	{
		get {
			return this.__singleton.m_PressStack
		}
	}
    PressCount[]
    {
        get {
            return this.__singleton.m_PressCount
        }
    }

	VibeStrength[]
	{
		get {
			return this.__singleton.m_VibeStrength
		}
	}
	VibeDuration[]
	{
		get {
			return this.__singleton.m_VibeDuration
		}
	}

	LootDelay[]
	{
		get {
			return this.__singleton.m_LootDelay
		}
	}
	TargetingDelay[]
	{
		get {
			return this.__singleton.m_TargetingDelay
		}
	}
	HoldDelay[]
	{
		get {
			return this.__singleton.m_HoldDelay
		}
	}

	MovementRadius[]
	{
		get {
			return this.__singleton.m_MovementRadius
		}
	}
	TargetRadius[]
	{
		get {
			return this.__singleton.m_TargetRadius
		}
	}

    Controls[]
    {
        get {
            return this.__singleton.m_Controls
        }
    }

	LeftStick[]
	{
		get {
			return this.__singleton.m_LeftStick
		}
	}
	RightStick[]
	{
		get {
			return this.__singleton.m_RightStick
		}
	}

    MovementStick[]
    {
        get {
            return this.__singleton.m_MovementStick
        }
    }
    TargetStick[]
    {
        get {
            return this.__singleton.m_TargetStick
        }
    }

    MousePos[]
    {
        get {
            return this.__singleton.m_MousePos
        }
    }
    TargetPos[]
    {
        get {
            return this.__singleton.m_TargetPos
        }
    }

	BatteryStatus[]
	{
		get {
			return this.__singleton.m_BatteryStatus
		}
	}
	BatteryImages[]
	{
		get {
			return this.__singleton.m_BatteryImages
		}
	}

    RefreshState()
    {
        global

        Loop, 4
        {
            local _state := XInput_GetState(A_Index - 1)
            if (!_state)
                Continue

			local i, _control
            For i, _control in this.Controls
                _control.RefreshState(_state)

			this.LeftStick.RefreshState(_state)
			this.RightStick.RefreshState(_state)

			local _batteryStatus := XInput_GetBatteryInformation(A_Index - 1, 0)
			if (_batteryStatus.BatteryType != BATTERY_TYPE_WIRED
			and _batteryStatus.BatteryLevel != this.BatteryStatus.BatteryLevel)
			{
				this.BatteryStatus := _batteryStatus

				local i, _batteryImage
				For i, _batteryImage in this.BatteryImages
				{
					if (this.BatteryStatus.BatteryLevel = i)
						Graphics.DrawImage(_batteryImage
										, new Vector2(Graphics.ActiveWinStats.Pos.X, Graphics.ActiveWinStats.Pos.Y), False)
					else
						Graphics.HideImage(_batteryImage)
				}
			}
        }
    }

    ProcessInput()
    {
        global

		local i, _control
        For i, _control in this.Controls
        {
            ;Debug.AddToLog(_control.Name . " State: " . _control.State . " PrevState: " . _control.PrevState)
            if (_control.State != _control.PrevState)
            {
                if (_control.State)
                {
					; The first frame a button is pressed
					if (Inventory.Enabled and (_control.Index >= ControlIndex.DPadUp  and _control.Index <= ControlIndex.DPadRight))
						Inventory.ProcessPress(_control)
					else if (_control.Controlbind.OnHold.Action)
                    	_control.PressTick := A_TickCount
					else
					{
                    	Debug.AddToLog(_control.Name . " pressed " . _control.Controlbind.OnPress.String)
						InputHelper.PressKeybind(_control.Controlbind.OnPress)
					}
                }
                else if (_control.PressTick = 0)
                {
                    ; The first frame after a button was held long enough to trigger the hold action and then released
					if (Inventory.Enabled and (_control.Index >= ControlIndex.DPadUp  and _control.Index <= ControlIndex.DPadRight))
						Inventory.ProcessReleaseHold(_control)
					else
					{
						Debug.AddToLog(_control.Name . " released " . _control.Controlbind.OnHold.String . " after being held")
						InputHelper.ReleaseKeybind(_control.Controlbind.OnHold)
					}
                }
                else
                {
                    ; The first frame a button is released but was not held long enough to trigger the hold action
					if (Inventory.Enabled and (_control.Index >= ControlIndex.DPadUp  and _control.Index <= ControlIndex.DPadRight))
						Inventory.ProcessReleasePress(_control)
					else if (_control.Controlbind.OnHold.Action and _control.PressTick != -1)
					{
						Debug.AddToLog(_control.Name . " pressed and released " . _control.Controlbind.OnPress.String)
						InputHelper.PressKeybind(_control.Controlbind.OnPress)
						InputHelper.ReleaseKeybind(_control.Controlbind.OnPress)
					}
					else
					{
                    	Debug.AddToLog(_control.Name . " released " . _control.Controlbind.OnPress.String)
						InputHelper.ReleaseKeybind(_control.Controlbind.OnPress)
					}
                }
            }
            else if (_control.State)
            {
                ; The first frame a button has been held down long enough to trigger the hold action
				if (Inventory.Enabled and (_control.Index >= ControlIndex.DPadUp  and _control.Index <= ControlIndex.DPadRight))
					Inventory.ProcessHold(_control)
				else if (_control.PressTick > 0 and A_TickCount >= _control.PressTick + this.HoldDelay)
				{
					this.Vibrate()

					Debug.AddToLog(_control.Name . " held down " . _control.Controlbind.OnHold.String)
					InputHelper.PressKeybind(_control.Controlbind.OnHold)

					_control.PressTick := 0
				}
            }
        }

		if (Inventory.Enabled)
			Inventory.ProcessControlStack()

		if ((this.MovementStick.StickValue.X != this.MovementStick.PrevStickValue.X
        or this.MovementStick.StickValue.Y != this.MovementStick.PrevStickValue.Y)
        or this.ForceMouseUpdate or this.CursorMode)
            this.ProcessMovementStick()
        if ((this.TargetStick.StickValue.X != this.TargetStick.PrevStickValue.X
        or this.TargetStick.StickValue.Y != this.TargetStick.PrevStickValue.Y)
        or this.ForceReticuleUpdate or this.FreeTargetMode)
            this.ProcessTargetStick()
    }

	ProcessMovementStick()
	{
        global
        local _stick := this.MovementStick

        if (!this.CursorMode)
        {
			if (_stick.State)
			{
				if (!this.Moving and !this.PressStack.Peek)
					this.StartMoving()

				local _centerOffset
					:= new Vector2(Graphics.ActiveWinStats.Center.X
								+ this.MouseOffset.X * (Graphics.ActiveWinStats.Size.Width / Graphics.BaseResolution.Width)
								, Graphics.ActiveWinStats.Center.Y
								+ this.MouseOffset.Y * (Graphics.ActiveWinStats.Size.Height / Graphics.BaseResolution.Height))

				local _radius
					:= new Vector2(this.MovementRadius.Width * (Graphics.ActiveWinStats.Size.Width / Graphics.BaseResolution.Width)
								, this.MovementRadius.Height * (Graphics.ActiveWinStats.Size.Height / Graphics.BaseResolution.Height))

				this.MousePos.X
					:= _centerOffset.X + (_radius.Width * _radius.Height)
					/ Sqrt((_radius.Height ** 2) + (_radius.Width ** 2) * (Tan(-_stick.StickAngleRad) ** 2))
				this.MousePos.Y
					:= _centerOffset.Y + (_radius.Width * _radius.Height * Tan(-_stick.StickAngleRad))
					/ Sqrt((_radius.Height ** 2) + (_radius.Width ** 2) * (Tan(-_stick.StickAngleRad) ** 2))

				if (_stick.StickAngleDeg > 90 and _stick.StickAngleDeg <= 270)
				{
					this.MousePos.X := _centerOffset.X - (this.MousePos.X - _centerOffset.X)
					this.MousePos.Y := _centerOffset.Y - (this.MousePos.Y - _centerOffset.Y)
				}
			}
			else
			{
				if (this.Moving and !this.PressStack.Peek)
					this.StopMoving()

				this.MousePos
					:= new Vector2(Graphics.ActiveWinStats.Center.X + this.MouseOffset.X
								, Graphics.ActiveWinStats.Center.Y + this.MouseOffset.Y)
			}

			if (this.PressStack.Peek.Type != KeybindType.Targeted or (!this.TargetStick.State and !this.FreeTargetMode))
			{
				if (Inventory.Enabled and !this.Moving)
					InputHelper.MoveMouse(Inventory.GetGridPos())
				else
					InputHelper.MoveMouse(this.MousePos)
			}
			else
				Graphics.DrawReticule(this.MousePos)
        }
        else
        {
			if (_stick.State)
			{
				local _radius :=

				if (Abs(_stick.StickValue.X) >= Abs(_stick.StickValue.Y))
					_radius := 20 * ((Abs(_stick.StickValue.X) - _stick.Deadzone) / (_stick.MaxValue.X - _stick.Deadzone))
				else
					_radius := 20 * ((Abs(_stick.StickValue.Y) - _stick.Deadzone) / (_stick.MaxValue.Y - _stick.Deadzone))

				local _mouseDelta
					:= new Vector2(_radius * Cos(-_stick.StickAngleRad) * _stick.Sensitivity.X
								,_radius * Sin(-_stick.StickAngleRad) * _stick.Sensitivity.Y)

				this.MousePos.X := this.MousePos.X + _mouseDelta.X
				this.MousePos.Y := this.MousePos.Y + _mouseDelta.Y
			}

			if (this.PressStack.Peek.Type != KeybindType.Targeted or (!this.TargetStick.State and !this.FreeTargetMode))
				InputHelper.MoveMouse(this.MousePos)
			else
				Graphics.DrawReticule(this.MousePos)
        }

		this.ForceMouseUpdate := False
	}
	ProcessTargetStick()
    {
        global
        local _stick := this.TargetStick

		if ((_stick.State and this.PressStack.Peek.Type = KeybindType.Targeted)
		or (this.FreeTargetMode))
			this.UsingReticule := True
		else
			this.UsingReticule := False

        if (!this.FreeTargetMode)
        {
			if (_stick.State)
			{
				local _centerOffset
					:= new Vector2(Graphics.ActiveWinStats.Center.X + Graphics.ActiveWinStats.Pos.X
								+ this.TargetOffset.X * (Graphics.ActiveWinStats.Size.Width / Graphics.BaseResolution.Width)
								, Graphics.ActiveWinStats.Center.Y + Graphics.ActiveWinStats.Pos.Y
								+ this.TargetOffset.Y * (Graphics.ActiveWinStats.Size.Height / Graphics.BaseResolution.Height))

				local _stickValue := _stick.StickValue
				if (Abs(_stickValue.X) > _stick.MaxValue.X)
				{
					if (_stickValue.X > 0)
						_stickValue.X := _stick.MaxValue.X
					else
						_stickValue.X := -_stick.MaxValue.X
				}
				if (Abs(_stickValue.Y) > _stick.MaxValue.Y)
				{
					if (_stickValue.Y > 0)
						_stickValue.Y := _stick.MaxValue.Y
					else
						_stickValue.Y := -_stick.MaxValue.Y
				}

				local _radius
					:= new Vector2(this.TargetRadius.Width * (Graphics.ActiveWinStats.Size.Width / Graphics.BaseResolution.Width)
								, this.TargetRadius.Height * (Graphics.ActiveWinStats.Size.Height / Graphics.BaseResolution.Height))

				if (Abs(_stickValue.X) >= Abs(_stickValue.Y))
				{
					_radius.Width
						:= _radius.Width * ((Abs(_stickValue.X) - _stick.Deadzone) / (_stick.MaxValue.X - _stick.Deadzone))
					_radius.Height
						:= _radius.Height * ((Abs(_stickValue.X) - _stick.Deadzone) / (_stick.MaxValue.Y - _stick.Deadzone))
				}
				else
				{
					_radius.Width
						:= _radius.Width * ((Abs(_stickValue.Y) - _stick.Deadzone) / (_stick.MaxValue.X - _stick.Deadzone))
					_radius.Height
						:= _radius.Height * ((Abs(_stickValue.Y) - _stick.Deadzone) / (_stick.MaxValue.Y - _stick.Deadzone))
				}

				this.TargetPos.X := _centerOffset.X + (_radius.Width *_radius.Height)
								/ Sqrt((_radius.Height ** 2) + (_radius.Width ** 2) * (Tan(_stick.StickAngleRad) ** 2))
				this.TargetPos.Y := _centerOffset.Y + (_radius.Width * _radius.Height * Tan(-_stick.StickAngleRad))
								/ Sqrt((_radius.Height ** 2) + (_radius.Width ** 2) * (Tan(-_stick.StickAngleRad) ** 2))

				if (_stick.StickAngleDeg > 90 and _stick.StickAngleDeg <= 270)
				{
					this.TargetPos.X := _centerOffset.X - (this.TargetPos.X - _centerOffset.X)
					this.TargetPos.Y := _centerOffset.Y - (this.TargetPos.Y - _centerOffset.Y)
				}
			}
			else
			{
				this.TargetPos
					:= new Vector2(Graphics.ActiveWinStats.Center.X + Graphics.ActiveWinStats.Pos.X
								, Graphics.ActiveWinStats.Center.Y + Graphics.ActiveWinStats.Pos.Y)
			}

            if (this.UsingReticule and this.PressStack.Peek.Type = KeybindType.Targeted)
                InputHelper.MoveMouse(this.TargetPos)
            else if (_stick.state and this.PressStack.Peek.Type != KeybindType.Targeted)
                Graphics.DrawReticule(this.TargetPos)
			else
				Graphics.HideReticule()
        }
        else
        {
			if (_stick.State)
			{
				local _radius :=
				if (Abs(_stick.StickValue.X) >= Abs(_stick.StickValue.Y))
					_radius := 20 * ((Abs(_stick.StickValue.X) - _stick.Deadzone) / (_stick.MaxValue.X - _stick.Deadzone))
				else
					_radius := 20 * ((Abs(_stick.StickValue.Y) - _stick.Deadzone) / (_stick.MaxValue.Y - _stick.Deadzone))


				local _targetDelta
					:= new Vector2(_radius * Cos(_stick.StickAngleRad) * _stick.Sensitivity.X
								, _radius * Sin(_stick.StickAngleRad) * _stick.Sensitivity.Y)

				if (this.UsingReticule)
				{
					this.TargetPos.X := this.TargetPos.X + _targetDelta.X
					this.TargetPos.Y := this.TargetPos.Y - _targetDelta.Y
				}
			}

			if (this.PressStack.Peek.Type = KeybindType.Targeted)
                InputHelper.MoveMouse(this.TargetPos)
			else
                Graphics.DrawReticule(this.TargetPos)
        }

		this.ForceReticuleUpdate := False
    }

	Vibrate()
	{
		Loop, 4
		{
			if XInput_GetState(A_Index-1)
				XInput_SetState(A_Index-1, this.VibeStrength, this.VibeStrength) ; MAX 65535
		}
		SetTimer, VibeOff, % -this.VibeDuration
	}

    ToggleCursorMode()
    {
        if (!this.CursorMode)
            this.EnableCursorMode()
        else
            this.DisableCursorMode()
    }
    EnableCursorMode()
    {
        global

        if (Inventory.Enabled)
            Inventory.Disable()

		if (this.ShowCursorModeNotification)
		{
			local _controlInfo := this.FindControlInfo(IniReader.ParseKeybind("CursorMode"))

			Graphics.DrawToolTip("Cursor Mode: Enabled `n"
								. _controlInfo.Act . " the " _controlInfo.Control.Name . " on the controller to disable"
								, Graphics.ActiveWinStats.Center.X
								, 0
								, 1, HorizontalAlignment.Center)
		}

		this.StopMoving()

		this.ForceMouseUpdate 	:= True
		this.CursorMode 		:= True
    }
    DisableCursorMode()
    {
		global
		if (this.ShowCursorModeNotification)
			Graphics.HideToolTip(1)

		this.ForceMouseUpdate	:= True
		this.CursorMode 		:= False
    }

	ToggleFreeTargetMode()
	{
		if (!this.FreeTargetMode)
			this.EnableFreeTargetMode()
		else
			this.DisableFreeTargetMode()
	}
	EnableFreeTargetMode()
	{
		global
		if (this.ShowFreeTargetModeNotification)
		{
			local _controlInfo := this.FindControlInfo(IniReader.ParseKeybind("FreeTarget"))

			Graphics.DrawToolTip("Free Target Mode: Enabled `n"
								. _controlInfo.Act . " the " . _controlInfo.Control.Name . " on the controller to disable"
								, Graphics.ActiveWinStats.Center.X
								, 40
								, 2, HorizontalAlignment.Center)
		}

		this.ForceReticuleUpdate 	:= True
		this.FreeTargetMode 		:= True
	}
	DisableFreeTargetMode()
	{
		global
		if (this.ShowFreeTargetModeNotification)
			Graphics.HideToolTip(2)

		this.ForceReticuleUpdate 	:= True
		this.FreeTargetMode			:= False
	}

	SwapSticks()
	{
		local _temp := this.MovementStick
		this.MovementStick := this.TargetStick
		this.TargetStick := _temp

		this.ForceMouseUpdate 		:= True
		this.ForceReticuleUpdate	:= True
	}

	StartMoving()
	{
		Debug.AddToLog("Pressing " . this.MoveOnlyKey.String)
		InputHelper.PressKeybind(this.MoveOnlyKey)

		this.Moving := True
	}
	StopMoving()
	{
		Debug.AddToLog("Releasing " . this.MoveOnlyKey.String)
		InputHelper.ReleaseKeybind(Controller.MoveOnlyKey)

		this.Moving := False
	}

	FindControlInfo(p_Keybind)
	{
		global

		local _isSpecial
			:= !p_Keybind.Modifier
			and (p_Keybind.Action = "CursorMode" or p_Keybind.Action = "Loot"
			or p_Keybind.Action = "FreeTarget" or p_Keybind.Action = "Inventory"
			or p_Keybind.Action = "SwapSticks")

		local i, _control
		if (_isSpecial)
		{
			For i, _control in this.Controls
			{
				if (_control.Controlbind.OnPress.Action = p_Keybind.Action and !_control.Controlbind.OnPress.Modifier)
					return new ControlInfo(_control, "Press")
				if (_control.Controlbind.OnHold.Action = p_Keybind.Action and !_control.Controlbind.OnHold.Modifier)
					return new ControlInfo(_control, "Hold")
			}
		}

		For i, _control in this.Controls
		{
			local _isSpecialAction
				:= _control.Controlbind.OnPress.Action = "CursorMode" or _control.Controlbind.OnPress.Action = "Loot"
				or _control.Controlbind.OnPress.Action = "FreeTarget" or _control.Controlbind.OnPress.Action = "Inventory"
				or _control.Controlbind.OnPress.Action = "SwapSticks"
			local _isSpecialModifier
				:= _control.Controlbind.OnPress.Modifier = "CursorMode" or _control.Controlbind.OnPress.Modifier = "Loot"
				or _control.Controlbind.OnPress.Modifier = "FreeTarget" or _control.Controlbind.OnPress.Modifier = "Inventory"
				or _control.Controlbind.OnPress.Modifier = "SwapSticks"

			local _onPress := _control.Controlbind.OnPress
			if ((_isSpecialAction and _onPress.Modifier and _onPress.Modifier = p_Keybind.Modifier)
			or (_isSpecialModifier and _onPress.Action and _control.Controlbind.OnPress.Action = p_Keybind.Action)
			or (_onPress.Action = p_Keybind.Action and _onPress.Modifier = p_Keybind.Modifier))
				return new ControlInfo(_control, "Press")

			_isSpecialAction
				:= _control.Controlbind.OnHold.Action = "CursorMode" or _control.Controlbind.OnHold.Action = "Loot"
				or _control.Controlbind.OnHold.Action = "FreeTarget" or _control.Controlbind.OnHold.Action = "Inventory"
				or _control.Controlbind.OnHold.Action = "SwapSticks"
			_isSpecialModifier
				:= _control.Controlbind.OnHold.Modifier = "CursorMode" or _control.Controlbind.OnHold.Modifier = "Loot"
				or _control.Controlbind.OnHold.Modifier = "FreeTarget" or _control.Controlbind.OnHold.Modifier = "Inventory"
				or _control.Controlbind.OnHold.Modifier = "SwapSticks"

			local _onHold := _control.Controlbind.OnHold
			if ((_isSpecialAction and _onHold.Modifier and _onHold.Modifier = p_Keybind.Modifier)
			or (_isSpecialModifier and _onHold.Action and _control.Controlbind.OnPress.Action = p_Keybind.Action)
			or (_onHold.Action = p_Keybind.Action and _onHold.Modifier = p_Keybind.Modifier))
				return new ControlInfo(_control, "Hold")
		}
	}

	OnToolTip()
	{
		local _debugText :=

        _debugText := _debugText . "MousePos: (" . Round(this.MousePos.X, 2) . ", " . Round(this.MousePos.Y, 2) . ") `n"
        _debugText := _debugText . "Moving: " . this.Moving . " ForceMouseUpdate: " . this.ForceMouseUpdate . "`n"
        _debugText := _debugText . this.LeftStick.Nickname . " - State: " . this.LeftStick.State " ("
					. Round(this.LeftStick.StickValue.X, 2) . ", " . Round(this.LeftStick.StickValue.Y, 2) ") "
                    . "Angle: " . Round(this.LeftStick.StickAngleDeg, 2) . "`n`n"

        _debugText := _debugText . "TargetPos: (" . Round(this.TargetPos.X, 2) . ", " . Round(this.TargetPos.Y, 2) . ") `n"
        _debugText := _debugText . "UsingReticule: " . this.UsingReticule . " ForceReticuleUpdate: " . this.ForceReticuleUpdate . "`n"
		_debugText := _debugText . this.RightStick.Nickname . " - State: " . this.RightStick.State " ("
					. Round(this.RightStick.StickValue.X, 2) . ", " . Round(this.RightStick.StickValue.Y, 2) ") "
                    . "Angle: " . Round(this.RightStick.StickAngleDeg, 2) . "`n"

        _debugText := _debugText . "PressStack - Length: " . this.PressStack.Length . " Peek: " . this.PressStack.Peek.Type . "`n"
					. "PressCount - "
                    . "Targeted: " . this.PressCount.Targeted . " "
                    . "Movement: " . this.PressCount.Movement . "`n`n"

		local i, _control
		For i, _control in this.Controls
		{
			_debugText := _debugText . _control.Nickname . ": "
			if (_control.Index = ControlIndex.LTrigger or _control.Index = ControlIndex.RTrigger)
				_debugText := _debugText . _control.TriggerValue . "   "
			else
				_debugText := _debugText . _control.State . "   "

			if (Mod(i, 4) = 0)
				_debugText := _debugText . "`n"
		}

		return _debugText
	}


}