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
    static m_Init := False

	static m_CursorMode 	:= False
	static m_FreeTargetMode := False

	static m_ShowCursorModeNotification :=
	static m_ShowFreeTargetModeNotification :=

	static m_MoveOnlyKey :=

	static m_Moving				:= False
	static m_ForceMouseUpdate 	:= True

	static m_UsingReticule 			:= False
	static m_ForceReticuleUpdate 	:= True

	static m_RepeatForceMove		:=
	static m_HaltMovementOnTarget	:=

	static m_MouseOffset	:=
	static m_TargetOffset 	:=

	static m_TargetedKeybinds :=
	static m_MovementKeybinds :=

	static m_PressStack :=
	static m_PressCount :=

	static m_LootDelay		:=
	static m_TargetingDelay	:=
	static m_HoldDelay		:=

	static m_VibeStrength :=
	static m_VibeDuration :=

	static m_Controls := Array()

	static m_MovementStick    :=
	static m_TargetStick      :=

	static m_MousePos	:=
	static m_TargetPos	:=

	static m_BatteryStatus 		:=
	static m_PrevBatteryStatus 	:=

	static m_StickSpeed := 1500

    Init()
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

		this.m_RepeatForceMove := IniReader.ReadProfileKey(ProfileSection.Preferences, "Repeat_Force_Move")
		this.m_HaltMovementOnTarget := IniReader.ReadProfileKey(ProfileSection.Preferences, "Halt_Movement_On_Target")

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
		this.m_PrevBatteryStatus := this.m_BatteryStatus

		local i, _control
		For i, _control in this.m_Controls
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

		Debug.AddToOnToolTip(new Delegate(Controller, "OnToolTip"))

        this.m_Init := True
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

    ForceMouseUpdate[]
    {
        get {
            return this.m_ForceMouseUpdate
        }
		set {
			return this.m_ForceMouseUpdate := value
		}
    }
    ForceReticuleUpdate[]
    {
        get {
            return this.m_ForceReticuleUpdate
        }
		set {
			return this.m_ForceReticuleUpdate := value
		}
    }

	HaltMovementOnTarget[]
	{
		get {
			return this.m_HaltMovementOnTarget
		}
	}

	TargetedKeybinds[]
	{
		get {
			return this.m_TargetedKeybinds
		}
	}
	MovementKeybinds[]
	{
		get {
			return this.m_MovementKeybinds
		}
	}

	PressStack[]
	{
		get {
			return this.m_PressStack
		}
	}
    PressCount[]
    {
        get {
            return this.m_PressCount
        }
    }

	LootDelay[]
	{
		get {
			return this.m_LootDelay
		}
	}
	TargetingDelay[]
	{
		get {
			return this.m_TargetingDelay
		}
	}
	HoldDelay[]
	{
		get {
			return this.m_HoldDelay
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

    MousePos[]
    {
        get {
            return this.m_MousePos
        }
    }
    TargetPos[]
    {
        get {
            return this.m_TargetPos
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
            For i, _control in this.m_Controls
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

		local i, _control
        For i, _control in this.m_Controls
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
				else if (_control.PressTick > 0 and A_TickCount >= _control.PressTick + this.m_HoldDelay)
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

		if ((this.m_MovementStick.StickValue.X != this.m_MovementStick.PrevStickValue.X
        or this.m_MovementStick.StickValue.Y != this.m_MovementStick.PrevStickValue.Y)
        or this.m_RepeatForceMove or this.m_ForceMouseUpdate or this.CursorMode)
            this.ProcessMovementStick()
        if ((this.m_TargetStick.StickValue.X != this.m_TargetStick.PrevStickValue.X
        or this.m_TargetStick.StickValue.Y != this.m_TargetStick.PrevStickValue.Y)
        or this.m_ForceReticuleUpdate or this.FreeTargetMode)
            this.ProcessTargetStick()
    }

	ProcessMovementStick()
	{
        global
        local _stick := this.m_MovementStick

        if (!this.CursorMode)
        {
			if (_stick.State)
			{
				if ((!this.m_Moving or this.m_RepeatForceMove) and !this.m_PressStack.Peek)
				{
					if (this.m_RepeatForceMove)
					{
						this.StartMoving()
						this.StopMoving()
					}
					else
						this.StartMoving()
				}

				local _centerOffset
					:= new Vector2(Graphics.ActiveWinStats.Center.X
								+ this.m_MouseOffset.X * (Graphics.ActiveWinStats.Size.Width / Graphics.BaseResolution.Width)
								, Graphics.ActiveWinStats.Center.Y
								+ this.m_MouseOffset.Y * (Graphics.ActiveWinStats.Size.Height / Graphics.BaseResolution.Height))

				local _radius
					:= new Vector2(this.m_MovementRadius.Width * (Graphics.ActiveWinStats.Size.Width / Graphics.BaseResolution.Width)
								, this.m_MovementRadius.Height * (Graphics.ActiveWinStats.Size.Height / Graphics.BaseResolution.Height))

				this.m_MousePos.X	:= _centerOffset.X + _stick.StickValue.Normalize.X * _radius.Width
				this.m_MousePos.Y := _centerOffset.Y - _stick.StickValue.Normalize.Y * _radius.Height
			}
			else
			{
				if (this.m_Moving and !this.m_PressStack.Peek)
					this.StopMoving()

				this.m_MousePos
					:= new Vector2(Graphics.ActiveWinStats.Center.X + this.m_MouseOffset.X
								, Graphics.ActiveWinStats.Center.Y + this.m_MouseOffset.Y)
			}

			if (this.m_PressStack.Peek.Type != KeybindType.Targeted or (!this.m_TargetStick.State and !this.FreeTargetMode))
			{
				if (Inventory.Enabled and !this.m_Moving)
					InputHelper.MoveMouse(Inventory.GetGridPos())
				else
					InputHelper.MoveMouse(this.m_MousePos)
			}
			else
				Graphics.DrawReticule(this.m_MousePos)
        }
        else
        {
			if (_stick.State)
			{
				local _mouseDelta
					:= new Vector2(FPS.DeltaTime * this.StickSpeed * _stick.StickValue.X * _stick.Sensitivity.X
								, FPS.DeltaTime * this.StickSpeed * -_stick.StickValue.Y * _stick.Sensitivity.Y)

				this.m_MousePos.X := this.m_MousePos.X + _mouseDelta.X
				this.m_MousePos.Y := this.m_MousePos.Y + _mouseDelta.Y
			}

			if (_stick.State or this.m_ForceMouseUpdate)
			{
				if (this.m_PressStack.Peek.Type != KeybindType.Targeted or (!this.m_TargetStick.State and !this.FreeTargetMode))
					InputHelper.MoveMouse(this.m_MousePos)
				else
					Graphics.DrawReticule(this.m_MousePos)
			}
        }

		this.m_ForceMouseUpdate := False
	}
	ProcessTargetStick()
    {
        global
        local _stick := this.m_TargetStick

		if ((_stick.State and this.m_PressStack.Peek.Type = KeybindType.Targeted)
		or (this.FreeTargetMode))
			this.m_UsingReticule := True
		else
			this.m_UsingReticule := False

        if (!this.FreeTargetMode)
        {
			if (_stick.State)
			{
				local _centerOffset
					:= new Vector2(Graphics.ActiveWinStats.Center.X + Graphics.ActiveWinStats.Pos.X
								+ this.m_TargetOffset.X * (Graphics.ActiveWinStats.Size.Width / Graphics.BaseResolution.Width)
								, Graphics.ActiveWinStats.Center.Y + Graphics.ActiveWinStats.Pos.Y
								+ this.m_TargetOffset.Y * (Graphics.ActiveWinStats.Size.Height / Graphics.BaseResolution.Height))

				local _radius
					:= new Vector2(this.m_TargetRadius.Width * (Graphics.ActiveWinStats.Size.Width / Graphics.BaseResolution.Width)
								, this.m_TargetRadius.Height * (Graphics.ActiveWinStats.Size.Height / Graphics.BaseResolution.Height))

				this.m_TargetPos.X := _centerOffset.X + _stick.StickValue.X * _radius.Width
				this.m_TargetPos.Y := _centerOffset.Y - _stick.StickValue.Y * _radius.Height
			}
			else
			{
				this.m_TargetPos
					:= new Vector2(Graphics.ActiveWinStats.Center.X + Graphics.ActiveWinStats.Pos.X
								, Graphics.ActiveWinStats.Center.Y + Graphics.ActiveWinStats.Pos.Y)
			}

            if (this.m_UsingReticule and this.m_PressStack.Peek.Type = KeybindType.Targeted)
                InputHelper.MoveMouse(this.m_TargetPos)
            else if (_stick.state and this.m_PressStack.Peek.Type != KeybindType.Targeted)
                Graphics.DrawReticule(this.m_TargetPos)
			else
				Graphics.HideReticule()
        }
        else
        {
			if (_stick.State)
			{
				local _targetDelta
					:= new Vector2(FPS.DeltaTime * this.StickSpeed * _stick.StickValue.X * _stick.Sensitivity.X
								, FPS.DeltaTime * this.StickSpeed * _stick.StickValue.Y * _stick.Sensitivity.Y)

				if (this.m_UsingReticule)
				{
					this.m_TargetPos.X := this.m_TargetPos.X + _targetDelta.X
					this.m_TargetPos.Y := this.m_TargetPos.Y - _targetDelta.Y
				}
			}

			if (_stick.State or this.m_ForceReticuleUpdate)
			{
				if (this.m_PressStack.Peek.Type = KeybindType.Targeted)
					InputHelper.MoveMouse(this.m_TargetPos)
				else
					Graphics.DrawReticule(this.m_TargetPos)
			}
        }

		this.m_ForceReticuleUpdate := False
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

		if (this.m_ShowCursorModeNotification)
		{
			local _controlInfo := this.FindControlInfo(IniReader.ParseKeybind("CursorMode"))

			Graphics.DrawToolTip("Cursor Mode: Enabled `n"
								. _controlInfo.Act . " the " _controlInfo.Control.Name . " on the controller to disable"
								, Graphics.ActiveWinStats.Center.X
								, 0
								, 1, HorizontalAlignment.Center)
		}

		this.StopMoving()

		this.m_ForceMouseUpdate 	:= True
		this.CursorMode 		:= True
    }
    DisableCursorMode()
    {
		global
		if (this.m_ShowCursorModeNotification)
			Graphics.HideToolTip(1)

		this.m_ForceMouseUpdate	:= True
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
		if (this.m_ShowFreeTargetModeNotification)
		{
			local _controlInfo := this.FindControlInfo(IniReader.ParseKeybind("FreeTarget"))

			Graphics.DrawToolTip("Free Target Mode: Enabled `n"
								. _controlInfo.Act . " the " . _controlInfo.Control.Name . " on the controller to disable"
								, Graphics.ActiveWinStats.Center.X
								, 40
								, 2, HorizontalAlignment.Center)
		}

		this.m_ForceReticuleUpdate 	:= True
		this.FreeTargetMode 		:= True
	}
	DisableFreeTargetMode()
	{
		global
		if (this.m_ShowFreeTargetModeNotification)
			Graphics.HideToolTip(2)

		this.m_ForceReticuleUpdate 	:= True
		this.FreeTargetMode			:= False
	}

	SwapSticks()
	{
		local _temp := this.m_MovementStick
		this.m_MovementStick := this.m_TargetStick
		this.m_TargetStick := _temp

		this.m_ForceMouseUpdate 		:= True
		this.m_ForceReticuleUpdate	:= True
	}

	StartMoving()
	{
		Debug.AddToLog("Pressing " . this.m_MoveOnlyKey.String)
		InputHelper.PressKeybind(this.m_MoveOnlyKey)

		this.m_Moving := True
	}
	StopMoving()
	{
		Debug.AddToLog("Releasing " . this.m_MoveOnlyKey.String)
		InputHelper.ReleaseKeybind(this.m_MoveOnlyKey)

		this.m_Moving := False
	}

	IsSpecial(p_Key)
	{
		return p_Key = "CursorMode" or p_Key = "Loot" or p_Key = "FreeTarget" or p_Key = "Inventory" or p_Key = "SwapSticks"
	}
	FindControlInfo(p_Keybind)
	{
		global

		local _isSpecial := !p_Keybind.Modifier	and this.IsSpecial(p_Keybind.Action)

		local i, _control
		if (_isSpecial)
		{
			For i, _control in this.m_Controls
			{
				if (_control.Controlbind.OnPress.Action = p_Keybind.Action and !_control.Controlbind.OnPress.Modifier)
					return new ControlInfo(_control, "Press")
				if (_control.Controlbind.OnHold.Action = p_Keybind.Action and !_control.Controlbind.OnHold.Modifier)
					return new ControlInfo(_control, "Hold")
			}
		}

		For i, _control in this.m_Controls
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

			Debug.AddToLog("Could not find " . p_Keybind.String . " in list of configured controls. Trying again...")
			return this.FindControlInfo(_keybindClone)
		}

		Debug.AddToLog("Could not find " . p_Keybind.String . " in list of configured controls")
	}

	OnToolTip()
	{
		local _debugText :=

        _debugText .= "MousePos: " . this.m_MousePos.String . "`n"
        _debugText .= "Moving: " . this.m_Moving . " ForceMouseUpdate: " . this.m_ForceMouseUpdate . "`n"
		_debugText .= "RawStickValue: " . this.m_MovementStick.RawStickValue.String "`n"
		_debugText .= "AdjustedStickValue: " . this.m_MovementStick.AdjustedStickValue.String "`n"
		_debugText .= "ClampedStickValue: " . this.m_MovementStick.ClampedStickValue.String "`n"
        _debugText .= this.m_MovementStick.Nickname . " - State: " . this.m_MovementStick.State " "
					. this.m_MovementStick.StickValue.String . "`tAngle: " . Round(this.m_MovementStick.StickAngleDeg, 2) . "`n`n"

        _debugText .= "TargetPos: " this.m_TargetPos.String "`n"
        _debugText .= "UsingReticule: " . this.m_UsingReticule . " ForceReticuleUpdate: " . this.m_ForceReticuleUpdate . "`n"
		_debugText .= "RawStickValue: " . this.m_TargetStick.RawStickValue.String "`n"
		_debugText .= "AdjustedStickValue: " . this.m_TargetStick.AdjustedStickValue.String "`n"
		_debugText .= "ClampedStickValue: " . this.m_TargetStick.ClampedStickValue.String "`n"
		_debugText .= this.m_TargetStick.Nickname . " - State: " . this.m_TargetStick.State " "
					. this.m_TargetStick.StickValue.String " Angle: " . Round(this.m_TargetStick.StickAngleDeg, 2) . "`n`n"

        _debugText .= "PressStack - Length: " . this.m_PressStack.Length . " Peek: " . this.m_PressStack.Peek.Type . "`n"
					. "PressCount - "
                    . "Targeted: " . this.m_PressCount.Targeted . " "
                    . "Movement: " . this.m_PressCount.Movement . "`n`n"

		local i, _control
		For i, _control in this.m_Controls
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