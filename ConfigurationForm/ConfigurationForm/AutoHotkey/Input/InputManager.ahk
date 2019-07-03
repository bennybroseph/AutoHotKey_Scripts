#Include Library\XInput.ahk

#Include Utility\IniUtility.ahk

#Include Input\Input.ahk

class InputManager
{
    static __singleton :=

    Init()
    {
        InputManager.__singleton := new InputManager()
    }

    __New()
    {
        ;AddToDebugLog("Creating instance...")
        global

        AButton          := 1
        BButton          := 2
        XButton          := 3
        YButton          := 4

        UpButton         := 5
        DownButton       := 6
        LeftButton       := 7
        RightButton      := 8

        StartButton      := 9
        BackButton       := 10
        GuideButton      := 11

        LShoulderButton  := 12
        RShoulderButton  := 13

        LThumbButton     := 14
        RThumbButton     := 15

        LTriggerIndex    := 16
        RTriggerIndex    := 17

        this.m_Buttons := Array()

        ;AddToDebugLog("A: " . XINPUT_GAMEPAD_A)
        this.m_Buttons[AButton] := new Button("A Button", "A", AButton, "A_Button", XINPUT_GAMEPAD_A)
        this.m_Buttons[BButton] := new Button("B Button", "B", BButton, "B_Button", XINPUT_GAMEPAD_B)
        this.m_Buttons[XButton] := new Button("X Button", "X", XButton, "X_Button", XINPUT_GAMEPAD_X)
        this.m_Buttons[YButton] := new Button("Y Button", "Y", YButton, "Y_Button", XINPUT_GAMEPAD_Y)

        this.m_Buttons[UpButton] := new Button("D-pad Up", "Up", UpButton, "D-Pad_Up", XINPUT_GAMEPAD_DPAD_UP)
        this.m_Buttons[DownButton] := new Button("D-pad Down", "Down", DownButton, "D-Pad_Down", XINPUT_GAMEPAD_DPAD_DOWN)
        this.m_Buttons[LeftButton] := new Button("D-pad Left", "Left", LeftButton, "D-Pad_Left", XINPUT_GAMEPAD_DPAD_LEFT)
        this.m_Buttons[RightButton] := new Button("D-pad Right", "Right", RightButton, "D-Pad_Right", XINPUT_GAMEPAD_DPAD_RIGHT)

        this.m_Buttons[StartButton] := new Button("Start Button", "Start", StartButton, "Start_Button", XINPUT_GAMEPAD_START)
        this.m_Buttons[BackButton] := new Button("Back Button", "Back", BackButton, "Back_Button", XINPUT_GAMEPAD_BACK)
        this.m_Buttons[BackButton] := new Button("Guide Button", "Guide", BackButton, "Guide_Button", XINPUT_GAMEPAD_GUIDE)

        this.m_Buttons[LShoulderButton]
            := new Button("Left Bumper", "LB", LShoulderButton, "Left_Shoulder", XINPUT_GAMEPAD_LEFT_SHOULDER)
        this.m_Buttons[RShoulderButton]
            := new Button("Right Bumper", "RB", RShoulderButton, "Right_Shoulder", XINPUT_GAMEPAD_RIGHT_SHOULDER)

        this.m_Buttons[LThumbButton]
            := new Button("Left Stick Button", "LS", LThumbButton, "Left_Analog_Button", XINPUT_GAMEPAD_LEFT_THUMB)
        this.m_Buttons[RThumbButton]
            := new Button("Right Stick Button", "RS", RThumbButton, "Right_Analog_Button", XINPUT_GAMEPAD_RIGHT_THUMB)

        this.m_Buttons[LTriggerIndex] := new Trigger("Left Trigger", "LT", LTriggerIndex, "Left_Trigger", "Left")
        this.m_Buttons[RTriggerIndex] := new Trigger("Right Trigger", "RT", RTriggerIndex, "Right_Trigger", "Right")
    }

    Buttons[]
    {
        get {
            return InputManager.__singleton.m_Buttons
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

            For i, _button in InputManager.Buttons
                _button.RefreshState(_state)
        }
    }

    ProcessInput()
    {
        global

        For i, _button in InputManager.Buttons
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
                    AddToDebugLog(_button.Name . " pressed: " . _button.Inputbind.Press.Action)
                }
                else if (_button.Inputbind.Hold.Action and _button.PressTick = 0)
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
            else if (_button.Inputbind.Hold.Action and _button.State
                    and _button.PressTick > 0 and A_TickCount >= _button.PressTick + Delay)
            {
                ; The first frame a button has been held down long enough to trigger the hold action
                _button.PressTick := 0
                AddToDebugLog(_button.Name . " held down")
            }
        }
    }
}