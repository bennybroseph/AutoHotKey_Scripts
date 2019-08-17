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

class Controller extends InputManager
{
	static m_StickSpeed := 1500

	static m_UsingReticule 	:= False

	static m_CursorMode 	:= False
	static m_FreeTargetMode := False

	static m_ShowCursorModeNotification
	static m_ShowFreeTargetModeNotification

	static m_VibeStrength
	static m_VibeDuration

	static m_TargetedKeybinds
	static m_MovementKeybinds

	static m_Controls := Array()

	static m_MovementStick
	static m_TargetStick

	static m_BatteryStatus
	static m_PrevBatteryStatus

    Init()
    {
		global

        this.m_ShowCursorModeNotification
			:= IniReader.ReadProfileKey(ProfileSection.Preferences, "Show_Cursor_Mode_Notification")
		this.m_ShowFreeTargetModeNotification
			:= IniReader.ReadProfileKey(ProfileSection.Preferences, "Show_FreeTarget_Mode_Notification")

		this.m_VibeStrength := IniReader.ReadProfileKey(ProfileSection.Preferences, "Vibration_Strength")
		this.m_VibeDuration := IniReader.ReadProfileKey(ProfileSection.Preferences, "Vibration_Duration")

		this.m_TargetedKeybinds	:= IniReader.ParseKeybindArray(KeybindingSection.Controller, "Targeted_Actions")
        this.m_MovementKeybinds	:= IniReader.ParseKeybindArray(KeybindingSection.Controller, "Movement_Actions")

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

		this.m_LeftStick := new Stick("Left Analog Stick", "Left Stick", StickIndex.Left, "Left_Stick_Button", "Left")
		this.m_RightStick := new Stick("Right Analog Stick", "Right Stick", StickIndex.Right, "Right_Stick_Button", "Right")

        this.m_MovementStick    := this.m_LeftStick
        this.m_TargetStick      := this.m_RightStick

		this.m_BatteryStatus := -1
		this.m_PrevBatteryStatus := this.m_BatteryStatus

		local i, _control
		for i, _control in this.m_Controls
			_control.ParseTargeting()

		local _cursorModeAtStart 		:= IniReader.ReadProfileKey(ProfileSection.Preferences, "Cursor_Mode_At_Start")
		if (_cursorModeAtStart)
			this.EnableCursorMode()

		local _freeTargetModeAtStart 	:= IniReader.ReadProfileKey(ProfileSection.Preferences, "FreeTarget_Mode_At_Start")
		if (_freeTargetModeAtStart)
			this.EnableFreeTargetMode()

		local _swapSticksAtStart		:= IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Swap_Sticks_At_Start")
		if (_swapSticksAtStart)
			this.SwapSticks()

		Debug.OnToolTipAddListener(new Delegate(Controller, "OnToolTip"))
    }

	TargetedKeybinds[] {
		get {
			return this.m_TargetedKeybinds
		}
	}
	MovementKeybinds[] {
		get {
			return this.m_MovementKeybinds
		}
	}

    CursorMode[]
    {
        get {
            return this.m_CursorMode
        }
    }
    FreeTargetMode[]
    {
        get {
            return this.m_FreeTargetMode
        }
    }

	LeftStick[]
	{
		get {
			return this.m_LeftStick
		}
	}
	RightStick[]
	{
		get {
			return this.m_RightStick
		}
	}

    MovementStick[]
    {
        get {
            return this.m_MovementStick
        }
    }
    TargetStick[]
    {
        get {
            return this.m_TargetStick
        }
    }

	BatteryStatus[]
	{
		get {
			return this.m_BatteryStatus
		}
		set {
			return this.m_BatteryStatus := value
		}
	}
	PrevBatteryStatus[]
	{
		get {
			return this.m_PrevBatteryStatus
		}
		set {
			return this.m_PrevBatteryStatus := value
		}
	}

	StickSpeed[]
	{
		get {
			return Graphics.ActiveWinStats.Size.Height / Graphics.BaseResolution.Height * this.m_StickSpeed
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
            for i, _control in this.m_Controls
                _control.RefreshState(_state)

			this.m_LeftStick.RefreshState(_state)
			this.m_RightStick.RefreshState(_state)

			this.m_PrevBatteryStatus := this.m_BatteryStatus
			this.m_BatteryStatus := XInput_GetBatteryInformation(A_Index - 1, 0)
        }
    }

    ProcessInput()
    {
        global

		if (this.m_TargetStick.State or this.m_FreeTargetMode)
			this.m_UsingReticule := True
		else
			this.m_UsingReticule := False

		local i, _control
        for i, _control in this.m_Controls
        {
            ;Debug.Log(_control.Name . " State: " . _control.State . " PrevState: " . _control.PrevState)
            if (_control.State != _control.PrevState)
            {
                if (_control.State)
                {
					; The first frame a button is pressed
					if (Inventory.Enabled and (_control.Index >= ControlIndex.DPadUp  and _control.Index <= ControlIndex.DPadRight))
						Inventory.ProcessPress(_control)
					else if (_control.Controlbind.OnHold.Action)
                    	_control.PressTick := FPS.GetCurrentTime()
					else
					{
                    	Debug.Log(_control.Name . " pressed " . _control.Controlbind.OnPress.String)
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
						Debug.Log(_control.Name . " released " . _control.Controlbind.OnHold.String . " after being held")
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
						Debug.Log(_control.Name . " pressed and released " . _control.Controlbind.OnPress.String)
						InputHelper.PressKeybind(_control.Controlbind.OnPress)
						InputHelper.ReleaseKeybind(_control.Controlbind.OnPress)
					}
					else
					{
                    	Debug.Log(_control.Name . " released " . _control.Controlbind.OnPress.String)
						InputHelper.ReleaseKeybind(_control.Controlbind.OnPress)
					}
                }
            }
            else if (_control.State)
            {
                ; The first frame a button has been held down long enough to trigger the hold action
				if (Inventory.Enabled and (_control.Index >= ControlIndex.DPadUp  and _control.Index <= ControlIndex.DPadRight))
					Inventory.ProcessHold(_control)
				else if (_control.PressTick > 0 and FPS.GetCurrentTime() >= _control.PressTick + this.HoldDelay)
				{
					this.Vibrate()

					Debug.Log(_control.Name . " held down " . _control.Controlbind.OnHold.String)
					InputHelper.PressKeybind(_control.Controlbind.OnHold)

					_control.PressTick := 0
				}
            }
        }
    }

	ProcessOther()
	{
		global

		if (!Vector2.IsEqual(this.m_MovementStick.StickValue, this.m_MovementStick.PrevStickValue)
        or this.RepeatForceMove or this.ForceMouseUpdate or (this.m_CursorMode and this.m_MovementStick.State))
            this.ProcessMovementStick()

        if (!Vector2.IsEqual(this.m_TargetStick.StickValue, this.m_TargetStick.PrevStickValue)
        or (this.ForceReticuleUpdate and !this.MouseKeyboardEnabled) or (this.m_FreeTargetMode and this.m_TargetStick.State))
            this.ProcessTargetStick()
	}

	ProcessMovementStick()
	{
        global

        local _stick := this.m_MovementStick

        if (!this.m_CursorMode)
        {
			local _centerOffset
				:= Vector2.Add(Vector2.Add(Graphics.ActiveWinStats.Pos, Graphics.ActiveWinStats.Center)
							, Vector2.Mul(this.MouseOffset, Graphics.ResolutionScale))

			this.MousePos := _centerOffset

			if (_stick.State)
			{
				local _radius
					:= new Rect(Vector2.Mul(this.MovementRadius.Min, Graphics.ResolutionScale)
							, Vector2.Mul(this.MovementRadius.Max, Graphics.ResolutionScale))

				this.MousePos.X += (_radius.Min.Width * _stick.StickValue.Normalize.X)
									+ (_radius.Size.Width * _stick.StickValue.X)
				this.MousePos.Y -= (_radius.Min.Height * _stick.StickValue.Normalize.Y)
									+ (_radius.Size.Height * _stick.StickValue.Y)
			}
			else if (this.Moving and !this.PressStack.Peek)
				this.StopMoving()

			if (this.PressStack.Peek.Type != KeybindType.Targeted or (!this.m_TargetStick.State and !this.m_FreeTargetMode))
			{
				if (Inventory.Enabled and !_stick.State)
					InputHelper.MoveMouse(Inventory.GetGridPos())
				else
					InputHelper.MoveMouse(this.MousePos)

				if (this.MouseHidden and Inventory.Enabled)
					this.Cursor.Draw(Inventory.GetGridPos(), False)
				else
					this.Cursor.Hide()
			}
			else if (!this.MouseHidden)
				this.Reticule.Draw(this.MousePos)

			if (_stick.State)
			{
				if ((!this.Moving or this.RepeatForceMove) and !this.PressStack.Peek)
				{
					if (this.RepeatForceMove and FPS.GetCurrentTime() - this.LastForceMove >= this.RepeatForceMoveSpeed)
					{
						this.StartMoving()
						this.StopMoving()

						this.LastForceMove := FPS.GetCurrentTime()
					}
					else
						this.StartMoving()
				}
			}
        }
        else if (_stick.State or this.ForceMouseUpdate)
        {
			if (_stick.State)
			{
				local _mouseDelta
					:= Vector2.Mul(Vector2.Mul(_stick.StickValue, FPS.DeltaTime * this.StickSpeed), _stick.Sensitivity)

				this.MousePos.X += _mouseDelta.X
				this.MousePos.Y -= _mouseDelta.Y

				this.MousePos := Vector2.Clamp(this.MousePos, Graphics.ScreenBounds.Min, Graphics.ScreenBounds.Max)
			}

			if (this.PressStack.Peek.Type != KeybindType.Targeted or (!this.m_TargetStick.State and !this.m_FreeTargetMode))
				InputHelper.MoveMouse(this.MousePos)
			else if (!this.MouseHidden)
				this.Reticule.Draw(this.MousePos)

			if (this.MouseHidden)
				this.Cursor.Draw(this.MousePos, False)
        }
	}
	ProcessTargetStick()
    {
        global
        local _stick := this.m_TargetStick

        if (!this.m_FreeTargetMode)
        {
			local _centerOffset
				:= Vector2.Add(Vector2.Add(Graphics.ActiveWinStats.Pos, Graphics.ActiveWinStats.Center)
							, Vector2.Mul(this.TargetOffset, Graphics.ResolutionScale))

			this.TargetPos.X := _centerOffset.X
			this.TargetPos.Y := _centerOffset.Y

			if (_stick.State)
			{
				local _radius
					:= new Rect(Vector2.Mul(this.TargetRadius.Min, Graphics.ResolutionScale)
							, Vector2.Mul(this.TargetRadius.Max, Graphics.ResolutionScale))

				this.TargetPos.X += (_radius.Min.Width * _stick.StickValue.Normalize.X)
									+ (_radius.Size.Width * _stick.StickValue.X)
				this.TargetPos.Y -= (_radius.Min.Height * _stick.StickValue.Normalize.Y)
									+ (_radius.Size.Height * _stick.StickValue.Y)
			}

            if (this.m_UsingReticule and this.PressStack.Peek.Type = KeybindType.Targeted)
			{
                InputHelper.MoveMouse(this.TargetPos)
				if (this.MouseHidden)
					this.Reticule.Draw(this.TargetPos)
			}
			else if (_stick.state and this.PressStack.Peek.Type != KeybindType.Targeted)
				this.Reticule.Draw(this.TargetPos)
			else
				this.Reticule.Hide()
        }
        else if (_stick.State or this.ForceReticuleUpdate)
        {
			if (_stick.State)
			{
				local _targetDelta
					:= Vector2.Mul(Vector2.Mul(_stick.StickValue, FPS.DeltaTime * this.StickSpeed), _stick.Sensitivity)

				if (this.m_UsingReticule)
				{
					this.TargetPos.X += _targetDelta.X
					this.TargetPos.Y -= _targetDelta.Y
				}

				local _clampedTargetPos := Vector2.Clamp(this.TargetPos, Graphics.ScreenBounds.Min, Graphics.ScreenBounds.Max)

				this.TargetPos.X := _clampedTargetPos.X
				this.TargetPos.Y := _clampedTargetPos.Y
			}

			if (this.PressStack.Peek.Type = KeybindType.Targeted)
				InputHelper.MoveMouse(this.TargetPos)
			else if (!this.MouseHidden)
				this.Reticule.Draw(this.TargetPos)

			if (this.MouseHidden)
				this.Reticule.Draw(this.TargetPos)
        }
    }

	Vibrate()
	{
		Loop, 4
		{
			if XInput_GetState(A_Index-1)
				XInput_SetState(A_Index-1, this.m_VibeStrength, this.m_VibeStrength) ; MAX 65535
		}
		SetTimer, VibeOff, % -this.m_VibeDuration
	}

	ResetDPadTick()
	{
		global

		Loop, 4
		{
			local _control := this.m_Controls[A_Index + ControlIndex.DPadUp - 1]
			_control.PressTick := -1
			_control.HoldTick := -1
		}
	}

    ToggleCursorMode()
    {
        if (!this.m_CursorMode)
            this.EnableCursorMode()
        else
            this.DisableCursorMode()
    }
    EnableCursorMode()
    {
        global

        if (Inventory.Enabled)
            Inventory.Disable()

		if (this.m_ShowCursorModeNotification)
		{
			local _controlInfo := this.FindControlInfo(IniReader.ParseKeybind("m_CursorMode"))

			Graphics.DrawToolTip("Cursor Mode: Enabled `n"
								. _controlInfo.Act . " the " _controlInfo.Control.Name . " on the controller to disable"
								, Graphics.ActiveWinStats.Center.X
								, 0
								, 1, HorizontalAlignment.Center)
		}

		this.StopMoving()

		this.ForceMouseUpdate 	:= True
		this.m_CursorMode 		:= True

		Debug.Log("Cursor Mode: Enabled")
    }
    DisableCursorMode()
    {
		global
		if (this.m_ShowCursorModeNotification)
			Graphics.HideToolTip(1)

		this.ForceMouseUpdate	:= True
		this.m_CursorMode 		:= False

		Debug.Log("Cursor Mode: Disabled")
    }

	ToggleFreeTargetMode()
	{
		if (!this.m_FreeTargetMode)
			this.EnableFreeTargetMode()
		else
			this.DisableFreeTargetMode()
	}
	EnableFreeTargetMode()
	{
		global
		if (this.m_ShowFreeTargetModeNotification)
		{
			local _controlInfo := this.FindControlInfo(IniReader.ParseKeybind("FreeTarget"))

			Graphics.DrawToolTip("Free Target Mode: Enabled `n"
								. _controlInfo.Act . " the " . _controlInfo.Control.Name . " on the controller to disable"
								, Graphics.ActiveWinStats.Center.X
								, 40
								, 2, HorizontalAlignment.Center)
		}

		this.ForceReticuleUpdate 	:= True
		this.m_FreeTargetMode 		:= True

		Debug.Log("FreeTarget Mode: Enabled")
	}
	DisableFreeTargetMode()
	{
		global
		if (this.m_ShowFreeTargetModeNotification)
			Graphics.HideToolTip(2)

		this.ForceReticuleUpdate 	:= True
		this.m_FreeTargetMode			:= False

		Debug.Log("FreeTarget Mode: Disabled")
	}

	SwapSticks()
	{
		local _temp := this.m_MovementStick
		this.m_MovementStick := this.m_TargetStick
		this.m_TargetStick := _temp

		this.ForceMouseUpdate 		:= True
		this.ForceReticuleUpdate	:= True
	}

	IsSpecial(p_Key)
	{
		return p_Key = "m_CursorMode" or p_Key = "Loot" or p_Key = "FreeTarget" or p_Key = "Inventory" or p_Key = "SwapSticks"
	}
	FindControlInfo(p_Keybind)
	{
		global

		local _isSpecial := !p_Keybind.Modifier	and this.IsSpecial(p_Keybind.Action)

		local i, _control
		if (_isSpecial)
		{
			for i, _control in this.m_Controls
			{
				if (_control.Controlbind.OnPress.Action = p_Keybind.Action and !_control.Controlbind.OnPress.Modifier)
					return new ControlInfo(_control, "Press")
				if (_control.Controlbind.OnHold.Action = p_Keybind.Action and !_control.Controlbind.OnHold.Modifier)
					return new ControlInfo(_control, "Hold")
			}
		}

		for i, _control in this.m_Controls
		{
			local _onPress := _control.Controlbind.OnPress

			local _isSpecialAction 		:= this.IsSpecial(_onPress.Action)
			local _isSpecialModifier	:= this.IsSpecial(_onPress.Modifier)

			if ((_isSpecialAction and _onPress.Modifier and _onPress.Modifier = p_Keybind.Modifier)
			or (_isSpecialModifier and _onPress.Action and _onPress.Action = p_Keybind.Action)
			or (_onPress.Action = p_Keybind.Action and _onPress.Modifier = p_Keybind.Modifier))
				return new ControlInfo(_control, "Press")

			local _onHold := _control.Controlbind.OnHold

			_isSpecialAction 	:= this.IsSpecial(_control.Controlbind.OnHold.Action)
			_isSpecialModifier	:= this.IsSpecial(_control.Controlbind.OnHold.Modifier)

			if ((_isSpecialAction and _onHold.Modifier and _onHold.Modifier = p_Keybind.Modifier)
			or (_isSpecialModifier and _onHold.Action and _onHold.Action = p_Keybind.Action)
			or (_onHold.Action = p_Keybind.Action and _onHold.Modifier = p_Keybind.Modifier))
				return new ControlInfo(_control, "Hold")
		}

		if (!p_Keybind.Modifier)
		{
			local _keybindClone := p_Keybind.Clone()
			_keybindClone.Modifier := _keybindClone.Action

			;Debug.Log("Could not find " . p_Keybind.String . " in list of configured controls. Trying again...")
			return this.FindControlInfo(_keybindClone)
		}

		Debug.Log("Could not find " . p_Keybind.String . " in list of configured controls")
	}

	OnToolTip()
	{
		local _debugText :=

		_debugText .= "RawStickValue: " . this.m_MovementStick.RawStickValue.String "`n"
		_debugText .= "AdjustedStickValue: " . this.m_MovementStick.AdjustedStickValue.String "`n"
		_debugText .= "ClampedStickValue: " . this.m_MovementStick.ClampedStickValue.String "`n"
        _debugText .= this.m_MovementStick.Nickname . " - State: " . this.m_MovementStick.State " "
					. this.m_MovementStick.StickValue.String . "`tAngle: " . Round(this.m_MovementStick.StickAngleDeg, 2) . "`n`n"

        _debugText .= "RawStickValue: " . this.m_TargetStick.RawStickValue.String "`n"
		_debugText .= "AdjustedStickValue: " . this.m_TargetStick.AdjustedStickValue.String "`n"
		_debugText .= "ClampedStickValue: " . this.m_TargetStick.ClampedStickValue.String "`n"
		_debugText .= this.m_TargetStick.Nickname . " - State: " . this.m_TargetStick.State " "
					. this.m_TargetStick.StickValue.String " Angle: " . Round(this.m_TargetStick.StickAngleDeg, 2) . "`n`n"

		local i, _control
		for i, _control in this.m_Controls
		{
			_debugText := _debugText . _control.Nickname . ": "
			if (_control.Index = ControlIndex.LTrigger or _control.Index = ControlIndex.RTrigger)
				_debugText .= _control.TriggerValue . "   "
			else
				_debugText .= _control.State . "   "

			if (Mod(i, 4) = 0)
				_debugText .= "`n"
		}

		return _debugText
	}
}