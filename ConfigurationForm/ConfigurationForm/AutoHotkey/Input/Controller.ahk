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

        this.m_TargetedKeybinds			:= IniReader.ParseKeybindArray("Targeted_Actions")
        this.m_IgnoreReticuleKeybinds	:= IniReader.ParseKeybindArray("Ignore_Reticule_Actions")

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
            := new Button("Left Stick Button", "LS", LThumbButton, "Left_Analog_Button", XINPUT_GAMEPAD_LEFT_THUMB)
        this.m_Controls[ControlIndex.RThumb]
            := new Button("Right Stick Button", "RS", RThumbButton, "Right_Analog_Button", XINPUT_GAMEPAD_RIGHT_THUMB)

		this.m_Controls[ControlIndex.Guide]
			:= new Button("Guide Button", "Guide", ControlIndex.Guide, "Guide_Button", XINPUT_GAMEPAD_GUIDE)
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

    Controls[]
    {
        get {
            return Controller.__singleton.m_Controls
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

            For i, _control in Controller.Controls
                _control.RefreshState(_state)
        }
    }

    ProcessInput()
    {
        global

        For i, _control in Controller.Controls
        {
            ;Debug.AddToLog(_control.Name . " State: " . _control.State . " PrevState: " . _control.PrevState)
            if (_control.State != _control.PrevState)
            {
                if (_control.State)
                {
                    ; The first frame a button is pressed
                    _control.PressTick := A_TickCount
                    Debug.AddToLog(_control.Name . " pressed: " . _control.Controlbind.OnPress.Action)
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
    }

	OnTooltip()
	{
		local _debugText :=

		For i, _control in Controller.Controls
		{
			_debugText := _debugText . _control.Nickname . ": " . _control.State . "   "
			if (Mod(i, 4) = 0)
				_debugText := _debugText . "`n"
		}

		return _debugText
	}
}