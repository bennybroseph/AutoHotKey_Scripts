XInput_Init(dll="xinput1_3.dll")
{
global
if _XInput_hm
return
XUSER_MAX_COUNT   := 4
XUSER_INDEX_ANY   := 0x0FF
ERROR_SUCCESS   := 0x000
ERROR_EMPTY     := 0x10D2
ERROR_DEVICE_NOT_CONNECTED   := 0X48F
XINPUT_DEVSUBTYPE_UNKNOWN          := 0x00
XINPUT_DEVSUBTYPE_GAMEPAD          := 0x01
XINPUT_DEVSUBTYPE_WHEEL            := 0x02
XINPUT_DEVSUBTYPE_ARCADE_STICK     := 0x03
XINPUT_DEVSUBTYPE_FLIGHT_SICK      := 0x04
XINPUT_DEVSUBTYPE_DANCE_PAD        := 0x05
XINPUT_DEVSUBTYPE_GUITAR           := 0x06
XINPUT_DEVSUBTYPE_GUITAR_ALTERNATE := 0x07
XINPUT_DEVSUBTYPE_DRUM_KIT         := 0x08
XINPUT_DEVSUBTYPE_GUITAR_BASS      := 0x0B
XINPUT_DEVSUBTYPE_ARCADE_PAD       := 0x13
XINPUT_CAPS_VOICE_SUPPORTED   := 0x0004
XINPUT_CAPS_FFB_SUPPORTED     := 0x0001
XINPUT_CAPS_WIRELESS          := 0x0002
XINPUT_CAPS_PMD_SUPPORTED     := 0x0008
XINPUT_CAPS_NO_NAVIGATION     := 0x0010
XINPUT_GAMEPAD_DPAD_UP          := 0x0001
XINPUT_GAMEPAD_DPAD_DOWN        := 0x0002
XINPUT_GAMEPAD_DPAD_LEFT        := 0x0004
XINPUT_GAMEPAD_DPAD_RIGHT       := 0x0008
XINPUT_GAMEPAD_START            := 0x0010
XINPUT_GAMEPAD_BACK             := 0x0020
XINPUT_GAMEPAD_LEFT_THUMB       := 0x0040
XINPUT_GAMEPAD_RIGHT_THUMB      := 0x0080
XINPUT_GAMEPAD_LEFT_SHOULDER    := 0x0100
XINPUT_GAMEPAD_RIGHT_SHOULDER   := 0x0200
XINPUT_GAMEPAD_A                := 0x1000
XINPUT_GAMEPAD_B                := 0x2000
XINPUT_GAMEPAD_X                := 0x4000
XINPUT_GAMEPAD_Y                := 0x8000
VK_PAD_A                  := 0x5800
VK_PAD_B                  := 0x5801
VK_PAD_X                  := 0x5802
VK_PAD_Y                  := 0x5803
VK_PAD_RSHOULDER          := 0x5804
VK_PAD_LSHOULDER          := 0x5805
VK_PAD_LTRIGGER           := 0x5806
VK_PAD_RTRIGGER           := 0x5807
VK_PAD_DPAD_UP            := 0x5810
VK_PAD_DPAD_DOWN          := 0x5811
VK_PAD_DPAD_LEFT          := 0x5812
VK_PAD_DPAD_RIGHT         := 0x5813
VK_PAD_START              := 0x5814
VK_PAD_BACK               := 0x5815
VK_PAD_LTHUMB_PRESS       := 0x5816
VK_PAD_RTHUMB_PRESS       := 0x5817
VK_PAD_LTHUMB_UP          := 0x5820
VK_PAD_LTHUMB_DOWN        := 0x5821
VK_PAD_LTHUMB_RIGHT       := 0x5822
VK_PAD_LTHUMB_LEFT        := 0x5823
VK_PAD_LTHUMB_UPLEFT      := 0x5824
VK_PAD_LTHUMB_UPRIGHT     := 0x5825
VK_PAD_LTHUMB_DOWNRIGHT   := 0x5826
VK_PAD_LTHUMB_DOWNLEFT    := 0x5827
VK_PAD_RTHUMB_UP          := 0x5830
VK_PAD_RTHUMB_DOWN        := 0x5831
VK_PAD_RTHUMB_RIGHT       := 0x5832
VK_PAD_RTHUMB_LEFT        := 0x5833
VK_PAD_RTHUMB_UPLEFT      := 0x5834
VK_PAD_RTHUMB_UPRIGHT     := 0x5835
VK_PAD_RTHUMB_DOWNRIGHT   := 0x5836
VK_PAD_RTHUMB_DOWNLEFT    := 0x5837
XINPUT_KEYSTROKE_KEYDOWN   := 0x0001
XINPUT_KEYSTROKE_KEYUP     := 0x0002
XINPUT_KEYSTROKE_REPEAT    := 0x0004
BATTERY_DEVTYPE_GAMEPAD   :=  0x00
BATTERY_DEVTYPE_HEADSET   :=  0x01
BATTERY_TYPE_DISCONNECTED   := 0x00
BATTERY_TYPE_WIRED          := 0x01
BATTERY_TYPE_ALKALINE       := 0x02
BATTERY_TYPE_NIMH           := 0x03
BATTERY_TYPE_UNKNOWN        := 0xFF
BATTERY_LEVEL_EMPTY    := 0x00
BATTERY_LEVEL_LOW      := 0x01
BATTERY_LEVEL_MEDIUM   := 0x02
BATTERY_LEVEL_FULL     := 0x03
_XInput_hm := DllCall("LoadLibrary" ,"str", dll)
if !_XInput_hm {
MsgBox, Failed to initialize XInput: %dll%.dll not found.
return
}
_XInput_GetState        := DllCall("GetProcAddress", "uint", _XInput_hm, "uint", 100)
_XInput_SetState        := DllCall("GetProcAddress", "uint", _XInput_hm, "AStr", "XInputSetState")
_XInput_GetKeystroke    := DllCall("GetProcAddress", "uint", _XInput_hm, "AStr", "XInputGetKeystroke")
_XInput_GetCapabilities := DllCall("GetProcAddress", "uint", _XInput_hm, "AStr", "XInputGetCapabilities")
_XInput_GetBatteryInformation := DllCall("GetProcAddress", "uint", _XInput_hm, "AStr", "XInputGetBatteryInformation")
if !(_XInput_GetState && _XInput_SetState && _XInput_GetKeystroke && _XInput_GetCapabilities && _XInput_GetBatteryInformation) {
XInput_Term()
MsgBox, Failed to initialize XInput: function not found.
return
}
}
XInput_Term() {
global
if _XInput_hm {
DllCall("FreeLibrary", "uint", _XInput_hm)
_XInput_hm :=_0
_XInput_GetState := 0
_XInput_SetState := 0
_XInput_GetKeystroke := 0
_XInput_GetCapabilities := 0
_XInput_GetBatteryInformation := 0
}
}
XInput_GetState(UserIndex = 0)
{
global _XInput_GetState
VarSetCapacity(xiState, 16)
if ErrorLevel := DllCall(_XInput_GetState, "uint", UserIndex , "uint", &xiState)
return 0
return {
        (Join,
            UserIndex    : UserIndex
            PacketNumber : NumGet(xiState, 0) 
            Buttons      : NumGet(xiState, 4, "UShort")
            LeftTrigger  : NumGet(xiState, 6, "UChar")
            RightTrigger : NumGet(xiState, 7, "UChar")
            ThumbLX      : NumGet(xiState, 8, "Short")
            ThumbLY      : NumGet(xiState, 10, "Short")
            ThumbRX      : NumGet(xiState, 12, "Short")
            ThumbRY      : NumGet(xiState, 14, "Short")
)}
}
XInput_GetKeystroke(UserIndex = 0x0FF)
{
global _XInput_GetKeystroke
VarSetCapacity(xiKeystroke, 8)
if ErrorLevel := DllCall(_XInput_GetKeystroke, "uint", UserIndex, "uint", 0, "uint", &xiKeystroke)
return 0
return {
        (Join,
            VirtualKey : NumGet(xiKeystroke, 0, "UShort")
            Flags : NumGet(xiKeystroke, 4, "UShort")
            UserIndex : NumGet(xiKeystroke, 6, "UChar")
            HidCode : NumGet(xiKeystroke, 7, "UChar")
)}
}
XInput_SetState(UserIndex, LeftMotorSpeed, RightMotorSpeed)
{
global _XInput_SetState
return DllCall(_XInput_SetState ,"uint", UserIndex , "uint*", LeftMotorSpeed|RightMotorSpeed<<16) = 0
}
XInput_GetCapabilities(UserIndex = 0, Flags = 0)
{
global _XInput_GetCapabilities
VarSetCapacity(xiCaps, 20)
if ErrorLevel := DllCall(_XInput_GetCapabilities, "uint", UserIndex, "uint", Flags, "uint", &xiCaps)
return 0
return {
        (Join,
            UserIndex : UserIndex
            Type : NumGet(xiCaps, 0 "UChar")
            SubType : NumGet(xiCaps, 1, "UChar")
            Flags : NumGet(xiCaps, 2, "UShort")
            Buttons : NumGet(xiCaps, 4, "UShort")
            LeftTrigger : NumGet(xiCaps, 6, "UChar")
            RightTrigger : NumGet(xiCaps, 7, "UChar")
            ThumbLX : NumGet(xiCaps, 8, "UShort")
            ThumbLY : NumGet(xiCaps, 10, "UShort")
            ThumbRX : NumGet(xiCaps, 12, "UShort")
            ThumbRY : NumGet(xiCaps, 14, "UShort")
            LeftMotorSpeed : NumGet(xiCaps, 16, "UShort")
            RightMotorSpeed : NumGet(xiCaps,  18, "UShort")
)}
}
XInput_GetBatteryInformation(UserIndex = 0, DevType = 1)
{
global _XInput_GetBatteryInformation
VarSetCapacity(xiBattery, 8)
if ErrorLevel := DllCall(_XInput_GetBatteryInformation, "uint", UserIndex, "uchar", DevType, "uint", &xiBattery)
return 0
return {
        (Join,
            UserIndex : UserIndex
            DevType : DevType
            BatteryType : NumGet(xiBattery, 0, "UChar")
            BatteryLevel : NumGet(xiBattery, 1, "UChar")
)}
}
