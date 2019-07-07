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

class PressCounter
{
    __New()
    {
        this.m_Targeted     := 0
        this.m_UnTargeted   := 0
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
    UnTargeted[]
    {
        get {
            return this.m_UnTargeted
        }
        set {
            return this.m_UnTargeted := value
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

        Controller.__singleton := new Controller()

		For i, _control in Controller.Controls
			_control.ParseTargeting()

		Debug.AddToOnTooltip(new Delegate(Controller, "OnTooltip"))
        Controller.__init := True
    }

    __New()
    {
		global

        this.m_CursorMode       := False
        this.m_FreeTargetMode   := False
        this.m_InventoryMode    := False

        this.m_MoveOnlyKey := IniReader.ParseKeybind(IniReader.ReadProfileKey(ProfileSection.Keybindings, "Force_Move"))
        this.m_Moving := False
        this.m_ForceMovement := False

        this.m_UsingReticule := False
        this.m_ForceReticule := False

        this.m_MouseOffset
            := new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Left_Analog_Center_XOffset")
                        , IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Left_Analog_Center_YOffset"))

        this.m_TargetedKeybinds			:= IniReader.ParseKeybindArray("Targeted_Actions")
        this.m_IgnoreReticuleKeybinds	:= IniReader.ParseKeybindArray("Ignore_Reticule_Actions")

        this.m_PressCount := new PressCounter()

        this.m_Controls := Array()

        this.m_Controls[ControlIndex.A] := new Button("A Button", "A", ControlIndex.A, "A_Button", XINPUT_GAMEPAD_A)
        this.m_Controls[ControlIndex.B] := new Button("B Button", "B", ControlIndex.B, "B_Button", XINPUT_GAMEPAD_B)
        this.m_Controls[ControlIndex.X] := new Button("X Button", "X", ControlIndex.X, "X_Button", XINPUT_GAMEPAD_X)
        this.m_Controls[ControlIndex.Y] := new Button("Y Button", "Y", ControlIndex.Y, "Y_Button", XINPUT_GAMEPAD_Y)

        this.m_Controls[ControlIndex.DPadUp]
			:= new Button("D-pad Up", "Up", ControlIndex.DPadUp, "D-Pad_Up", XINPUT_GAMEPAD_DPAD_UP)
        this.m_Controls[ControlIndex.DPadDown]
			:= new Button("D-pad Down", "Down", ControlIndex.DPadDown, "D-Pad_Down", XINPUT_GAMEPAD_DPAD_DOWN)
        this.m_Controls[ControlIndex.DPadLeft]
			:= new Button("D-pad Left", "Left", ControlIndex.DPadLeft, "D-Pad_Left", XINPUT_GAMEPAD_DPAD_LEFT)
        this.m_Controls[ControlIndex.DPadRight]
			:= new Button("D-pad Right", "Right", ControlIndex.DPadRight, "D-Pad_Right", XINPUT_GAMEPAD_DPAD_RIGHT)

		this.m_Controls[ControlIndex.LShoulder]
            := new Button("Left Bumper", "LB", ControlIndex.LShoulder, "Left_Shoulder", XINPUT_GAMEPAD_LEFT_SHOULDER)
        this.m_Controls[ControlIndex.RShoulder]
            := new Button("Right Bumper", "RB", ControlIndex.RShoulder, "Right_Shoulder", XINPUT_GAMEPAD_RIGHT_SHOULDER)

		this.m_Controls[ControlIndex.LTrigger] := new Trigger("Left Trigger", "LT", ControlIndex.LTrigger, "Left_Trigger", "Left")
        this.m_Controls[ControlIndex.RTrigger] := new Trigger("Right Trigger", "RT", ControlIndex.RTrigger, "Right_Trigger", "Right")

        this.m_Controls[ControlIndex.Start]
			:= new Button("Start Button", "Start", ControlIndex.Start, "Start_Button", XINPUT_GAMEPAD_START)
        this.m_Controls[ControlIndex.Back]
			:= new Button("Back Button", "Back", ControlIndex.Back, "Back_Button", XINPUT_GAMEPAD_BACK)

        this.m_Controls[ControlIndex.LThumb]
            := new Button("Left Stick Button", "LS", ControlIndex.LThumb, "Left_Analog_Button", XINPUT_GAMEPAD_LEFT_THUMB)
        this.m_Controls[ControlIndex.RThumb]
            := new Button("Right Stick Button", "RS", ControlIndex.RThumb, "Right_Analog_Button", XINPUT_GAMEPAD_RIGHT_THUMB)

		this.m_Controls[ControlIndex.Guide]
			:= new Button("Guide Button", "Guide", ControlIndex.Guide, "Guide_Button", XINPUT_GAMEPAD_GUIDE)

		this.m_LeftStick := new Stick("Left Analog Stick", "Left Stick", StickIndex.Left, "ERROR", "Left")
		this.m_RightStick := new Stick("Right Analog Stick", "Right Stick", StickIndex.Right, "ERROR", "Right")

        this.m_MovementStick := this.m_LeftStick
        this.m_TargetStick := this.m_RightStick

        this.m_MousePos := new Vector2()
        this.m_TargetPos := new Vector2()
    }

    CursorMode[]
    {
        get {
            return Controller.__singleton.m_CursorMode
        }
    }
    FreeTargetMode[]
    {
        get {
            return Controller.__singleton.m_FreeTargetMode
        }
    }
    InventoryMode[]
    {
        get {
            return Controller.__singleton.m_InventoryMode
        }
    }

    MoveOnlyKey[]
    {
        get {
            return Controller.__singleton.m_MoveOnlyKey
        }
    }
    Moving[]
    {
        get {
            return Controller.__singleton.m_Moving
        }
    }
    ForceMovement[]
    {
        get {
            return Controller.__singleton.m_ForceMovement
        }
    }

    UsingReticule[]
    {
        get {
            return Controller.__singleton.m_UsingReticule
        }
    }
    ForceReticule[]
    {
        get {
            return Controller.__singleton.m_ForceReticule
        }
    }

    MouseOffset[]
    {
        get {
            return Controller.__singleton.m_MouseOffset
        }
    }

	TargetedKeybinds[]
	{
		get {
			return Controller.__singleton.m_TargetedKeybinds
		}
	}
	IgnoreReticuleKeybinds[]
	{
		get {
			return Controller.__singleton.m_IgnoreReticuleKeybinds
		}
	}

    PressCount[]
    {
        get {
            return Controller.__singleton.m_PressCount
        }
    }

    Controls[]
    {
        get {
            return Controller.__singleton.m_Controls
        }
    }

	LeftStick[]
	{
		get {
			return Controller.__singleton.m_LeftStick
		}
	}
	RightStick[]
	{
		get {
			return Controller.__singleton.m_RightStick
		}
	}

    MovementStick[]
    {
        get {
            return Controller.__singleton.m_MovementStick
        }
    }
    TargetStick[]
    {
        get {
            return Controller.__singleton.m_TargetStick
        }
    }

    MousePos[]
    {
        get {
            return Controller.__singleton.m_MousePos
        }
    }
    TargetPos[]
    {
        get {
            return Controller.__singleton.m_TargetPos
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

            For i, _control in this.Controls
                _control.RefreshState(_state)

			this.LeftStick.RefreshState(_state)
			this.RightStick.RefreshState(_state)
        }
    }

    ProcessInput()
    {
        global

        For i, _control in this.Controls
        {
            ;Debug.AddToLog(_control.Name . " State: " . _control.State . " PrevState: " . _control.PrevState)
            if (_control.State != _control.PrevState)
            {
                if (_control.State)
                {
                    ; The first frame a button is pressed
                    _control.PressTick := A_TickCount
                    Debug.AddToLog(_control.Name . " pressed")
                }
                else if (_control.Controlbind.OnHold.Action and _control.PressTick = 0)
                {
                    ; The first frame after a button was held long enough to trigger the hold action and then released
                    Debug.AddToLog(_control.Name . " released after being held")
                }
                else if (_control.PressTick != -1)
                {
                    ; The first frame a button is released but was not held long enough to trigger the hold action
                    Debug.AddToLog(_control.Name . " pressed and released")
                }
            }
            else if (_control.Controlbind.OnHold.Action and _control.State
                    and _control.PressTick > 0 and A_TickCount >= _control.PressTick + Delay)
            {
                ; The first frame a button has been held down long enough to trigger the hold action
                _control.PressTick := 0
                Debug.AddToLog(_control.Name . " held down")
            }
        }

        if (this.MovementStick.State != this.MovementStick.PrevState or this.ForceMovement)
            this.ProcessMovementStick()
        this.ProcessTargetStick()
    }

	ProcessMovementStick()
	{
        global
        local _stick := this.MovementStick

        if (_stick.State)
        {
            if (!this.Moving or this.ForceMovement)
            {
                if ((this.PressCount.Targeted = 0 and !this.CursorMode) or this.PressCount.UnTargeted > 0)
                {
                    Debug.AddToLog("Pressing " . this.MoveOnlyKey.Action)
                    InputHelper.PressKeybind(this.MoveOnlyKey)
                }

                this.Moving := True
                this.ForceMovement := False
            }
        }
        else
        {
            if (this.Moving)
            {
                if (this.PressCount.UnTargeted = 0 and !this.CursorMode)
                {
                    Debug.AddToLog("Release " . this.MoveOnlyKey.Action)
                    InputHelper.ReleaseKeybind(this.MoveOnlyKey)
                }

                this.Moving := False
                this.ForceMovement := False
            }
        }

        if (!this.CursorMode)
        {
            this.MousePos.X := (_stick.StickValue.X) + (_stick.Radius.X * _stick.Radius.Y)
                            / Sqrt((_stick.Radius.Y ** 2) + (_stick.Radius.X ** 2) * (Tan(_stick.StickAngleRad) ** 2))
            this.MousePos.Y := (_stick.StickValue.Y) + (_stick.Radius.X * _stick.Radius.Y * Tan(_stick.StickAngleRad))
                            / Sqrt((_stick.Radius.Y ** 2) + (_stick.Radius.X ** 2) * (Tan(_stick.StickAngleRad) ** 2))

            if (_stick.AngleDeg > 90 and _stick.AngleDeg <= 270)
            {
                this.MousePos.X := _stick.StickValue.X - (this.MousePos.X - _stick.StickValue.X)
                this.MousePos.Y := _stick.StickValue.Y - (this.MousePos.Y - _stick.StickValue.Y)
            }

            if ((this.PressCount.Targeted = 0 or (!this.UsingReticule and !this.ForceReticule))
            and (!this.InventoryMode or this.Moving))
            {
                if (this.Moving)
                    InputHelper.MoveMouse(this.MousePos)
                else
                    InputHelper.MoveMouse(Graphics.ActiveWinStats.Center)
            }
            else if ((this.UsingReticule or this.ForceReticule) and this.PressCount.Targeted > 0)
            {
                if (this.Moving)
                {

                }
                else
                {

                }
            }
            else if (!this.Moving and this.InventoryMode)
            {

            }
        }
        else
        {
            local _radius :=

            if (Abs(_stick.StickValue.X) >= Abs(_stick.StickValue.Y))
                _radius := 20 * ((Abs(_stick.StickValue.X) - _stick.Deadzone) / (_stick.MaxValue - _stick.Deadzone))
            else
                _radius := 20 * ((Abs(_stick.StickValue.Y) - _stick.Deadzone) / (_stick.MaxValue - _stick.Deadzone))

            this.MousePos
                := new Vector2(_radius * Cos(_stick.StickAngleRad) * _stick.Sensitivity.X
                            ,_radius * Cos(_stick.StickAngleRad) * _stick.Sensitivity.Y)

            if (this.Moving)
                InputHelper.MoveMouse(this.MousePos, , "R")
        }
	}
    ProcessTargetStick()
    {

    }

	OnTooltip()
	{
		local _debugText :=

        _debugText := _debugText . "MousePos: (" . this.MousePos.X . ", " . this.MousePos.Y . ") `n"
        _debugText := _debugText . "Moving: " . this.Moving . "`n"
        _debugText := _debugText . this.LeftStick.Nickname . " - State: " . this.LeftStick.State " ("
					. this.LeftStick.StickValue.X . ", " . this.LeftStick.StickValue.Y ") "
                    . "Angle: " . this.LeftStick.StickAngleDeg . "`n"
		_debugText := _debugText . this.RightStick.Nickname . " - State: " . this.RightStick.State " ("
					. this.RightStick.StickValue.X . ", " . this.RightStick.StickValue.Y ") "
                    . "Angle: " . this.RightStick.StickAngleDeg . "`n"

        _debugText := _debugText . "PressCount - "
                    . "Targeted: " . this.PressCount.Targeted . " "
                    . " UnTargeted: " . this.PressCount.UnTargeted . "`n`n"

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