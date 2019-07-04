; Stores Keybinds

class ButtonIndex
{
    static A			:= 1
    static B			:= 2
    static X 			:= 3
    static Y			:= 4

    static DPadUp		:= 5
    static DPadDown		:= 6
    static DPadLeft		:= 7
    static DPadRight	:= 8

    static Start		:= 9
    static Back         := 10
    static Guide        := 11

    static LShoulder	:= 12
    static RShoulder	:= 13

    static LThumb		:= 14
    static RThumb		:= 15

    static LTrigger		:= 16
    static RTrigger		:= 17
}

class Controller
{
    static __singleton :=
    static __init := False

    Init()
    {
        Controller.__singleton := new Controller()

		For i, _button in Controller.Buttons
			_button.ParseTargeting()

        Controller.__init := True
    }

    __New()
    {
        ;AddToDebugLog("Creating instance...")

        this.m_TargetedKeybinds			:= IniReader.ParseKeybindArray("Targeted_Actions")
        this.m_IgnoreReticuleKeybinds	:= IniReader.ParseKeybindArray("Ignore_Reticule_Actions")

        this.m_Buttons := Array()

        ;AddToDebugLog("A: " . XINPUT_GAMEPAD_A)
        this.m_Buttons[ButtonIndex.A] := new Button("A Button", "A", ButtonIndex.A, "A_Button", XINPUT_GAMEPAD_A)
        this.m_Buttons[ButtonIndex.B] := new Button("B Button", "B", ButtonIndex.B, "B_Button", XINPUT_GAMEPAD_B)
        this.m_Buttons[ButtonIndex.X] := new Button("X Button", "X", ButtonIndex.X, "X_Button", XINPUT_GAMEPAD_X)
        this.m_Buttons[ButtonIndex.Y] := new Button("Y Button", "Y", ButtonIndex.Y, "Y_Button", XINPUT_GAMEPAD_Y)

        this.m_Buttons[ButtonIndex.DPadUp]
			:= new Button("D-pad Up", "Up", ButtonIndex.DPadUp, "D-Pad_Up", XINPUT_GAMEPAD_DPAD_UP)
        this.m_Buttons[ButtonIndex.DPadDown]
			:= new Button("D-pad Down", "Down", ButtonIndex.DPadDown, "D-Pad_Down", XINPUT_GAMEPAD_DPAD_DOWN)
        this.m_Buttons[ButtonIndex.DPadLeft]
			:= new Button("D-pad Left", "Left", ButtonIndex.DPadLeft, "D-Pad_Left", XINPUT_GAMEPAD_DPAD_LEFT)
        this.m_Buttons[ButtonIndex.DPadRight]
			:= new Button("D-pad Right", "Right", ButtonIndex.DPadRight, "D-Pad_Right", XINPUT_GAMEPAD_DPAD_RIGHT)

        this.m_Buttons[ButtonIndex.Start]
			:= new Button("Start Button", "Start", ButtonIndex.Start, "Start_Button", XINPUT_GAMEPAD_START)
        this.m_Buttons[ButtonIndex.Back]
			:= new Button("Back Button", "Back", ButtonIndex.Back, "Back_Button", XINPUT_GAMEPAD_BACK)
        this.m_Buttons[ButtonIndex.Guide]
			:= new Button("Guide Button", "Guide", ButtonIndex.Guide, "Guide_Button", XINPUT_GAMEPAD_GUIDE)

        this.m_Buttons[ButtonIndex.LShoulder]
            := new Button("Left Bumper", "LB", ButtonIndex.LShoulder, "Left_Shoulder", XINPUT_GAMEPAD_LEFT_SHOULDER)
        this.m_Buttons[ButtonIndex.RShoulder]
            := new Button("Right Bumper", "RB", ButtonIndex.RShoulder, "Right_Shoulder", XINPUT_GAMEPAD_RIGHT_SHOULDER)

        this.m_Buttons[ButtonIndex.LThumb]
            := new Button("Left Stick Button", "LS", LThumbButton, "Left_Analog_Button", XINPUT_GAMEPAD_LEFT_THUMB)
        this.m_Buttons[ButtonIndex.RThumb]
            := new Button("Right Stick Button", "RS", RThumbButton, "Right_Analog_Button", XINPUT_GAMEPAD_RIGHT_THUMB)

        this.m_Buttons[ButtonIndex.LTrigger] := new Trigger("Left Trigger", "LT", ButtonIndex.LTrigger, "Left_Trigger", "Left")
        this.m_Buttons[ButtonIndex.RTrigger] := new Trigger("Right Trigger", "RT", ButtonIndex.RTrigger, "Right_Trigger", "Right")
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

    Buttons[]
    {
        get {
            return Controller.__singleton.m_Buttons
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

            For i, _button in Controller.Buttons
                _button.RefreshState(_state)
        }
    }

    ProcessInput()
    {
        global

        For i, _button in Controller.Buttons
        {
            if (!_button.IsValidInput)
                Continue

            ;AddToDebugLog(_button.Name . " State: " . _button.State . " PrevState:" . _button.PrevState)
            if (_button.State != _button.PrevState)
            {
                if (_button.State)
                {
                    ; The first frame a button is pressed
                    _button.PressTick := A_TickCount
                    AddToDebugLog(_button.Name . " pressed: " . _button.Controlbind.OnPress.Action)
                }
                else if (_button.Controlbind.OnHold.Action and _button.PressTick = 0)
                {
                    ; The first frame after a button was held long enough to trigger the hold action and then released
                    AddToDebugLog(_button.Name . " released after being held")
                }
                else if (_button.PressTick != -1)
                {
                    ; The first frame a button is released but was not held long enough to trigger the hold action
                    AddToDebugLog(_button.Name . " pressed and released")
                }
            }
            else if (_button.Controlbind.OnHold.Action and _button.State
                    and _button.PressTick > 0 and A_TickCount >= _button.PressTick + Delay)
            {
                ; The first frame a button has been held down long enough to trigger the hold action
                _button.PressTick := 0
                AddToDebugLog(_button.Name . " held down")
            }
        }
    }
}