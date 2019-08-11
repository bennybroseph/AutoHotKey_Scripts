
class InputManager
{
	static s_Init := False

	static s_MouseKeyboardEnabled
	static s_ControllerEnabled

	static s_Moving := False

	static s_ForceMouseUpdate	:= True
	static s_ForceReticuleUpdate 	:= True

	static s_ForceMoveKey

	static s_RepeatForceMove
	static s_HaltMovementOnTarget

	static s_MouseOffset
	static s_TargetOffset

	static s_PressStack
	static s_PressCount

	static s_LootDelay
	static s_TargetingDelay
	static s_HoldDelay

	static s_MovementRadius
	static s_TargetRadius

	static s_MousePos
	static s_TargetPos

	static s_MouseHidden

	static s_Cursor
	static s_Reticule

	Init()
	{
		this.s_ControllerEnabled 	:= IniReader.ReadKeybindingKey(KeybindingSection.Controller, "Enabled")
		this.s_MouseKeyboardEnabled := IniReader.ReadKeybindingKey(KeybindingSection.MouseKeyboard, "Enabled")

		this.s_ForceMoveKey := IniReader.ParseKeybind(IniReader.ReadKeybindingKey(KeybindingSection.Other, "Force_Move"))

		this.s_RepeatForceMove := IniReader.ReadProfileKey(ProfileSection.Preferences, "Repeat_Force_Move")
		this.s_HaltMovementOnTarget := IniReader.ReadProfileKey(ProfileSection.Preferences, "Halt_Movement_On_Target")

		this.s_MouseOffset
            := new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Movement_Center_Offset_X")
                        , IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Movement_Center_Offset_Y"))
        this.s_TargetOffset
            := new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Targeting_Center_Offset_X")
                        , IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Targeting_Center_Offset_Y"))

		this.s_PressStack := new LooseStack()
        this.s_PressCount := new PressCounter()

		this.s_LootDelay 		:= IniReader.ReadProfileKey(ProfileSection.Preferences, "Loot_Delay")
		this.s_TargetingDelay	:= IniReader.ReadProfileKey(ProfileSection.Preferences, "Targeting_Delay")
		this.s_HoldDelay 		:= IniReader.ReadProfileKey(ProfileSection.Preferences, "Hold_Delay")

		this.s_MovementRadius
			:= new Rect(new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Movement_Min_Radius_Width")
								, IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Movement_Min_Radius_Height"))
					, new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Movement_Max_Radius_Width")
								, IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Movement_Max_Radius_Height")))

		this.s_TargetRadius
			:= new Rect(new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Targeting_Min_Radius_Width")
								, IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Targeting_Min_Radius_Height"))
					, new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Targeting_Max_Radius_Width")
								, IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Targeting_Max_Radius_Height")))

		this.s_MousePos		:= InputHelper.GetMousePos()
		this.s_TargetPos	:= CriticalObject(InputHelper.GetMousePos())

		this.s_MouseHidden := IniReader.ReadProfileKey(ProfileSection.Preferences, "Using_Invisible_Cursor")

		this.s_Cursor 	:= new Image("Images\" . Graphics.ApplicationTitle . ".png", 1, 5)
		this.s_Reticule := new Image("Images\Target.png", 1, 5)

		Debug.OnToolTipAddListener(new Delegate(this, "OnToolTip"))

		this.s_Init := True

		Controller.Init()
		if (this.s_MouseKeyboardEnabled)
			Intercept.Init()
	}
	; Create accessors for children
	ControllerEnabled[]	{
		get {
			return InputManager.s_ControllerEnabled
		}
	}
	MouseKeyboardEnabled[] {
		get {
			return InputManager.s_MouseKeyboardEnabled
		}
	}

	Moving[] {
		get {
			return InputManager.s_Moving
		}
		set {
			return InputManager.s_Moving := value
		}
	}
	ForceMouseUpdate[] {
		get {
			return InputManager.s_ForceMouseUpdate
		}
		set {
			return InputManager.s_ForceMouseUpdate := value
		}
	}

	UsingReticule[] {
		get {
			return Controller.m_UsingReticule or Intercept.m_UsingReticule
		}
	}
	ForceReticuleUpdate[] {
		get {
			return InputManager.s_ForceReticuleUpdate
		}
		set {
			return InputManager.s_ForceReticuleUpdate := value
		}
	}

	ForceMoveKey[] {
		get {
			return InputManager.s_ForceMoveKey
		}
	}

	RepeatForceMove[] {
		get {
			return InputManager.s_RepeatForceMove
		}
	}

	HaltMovementOnTarget[] {
		get {
			return InputManager.s_HaltMovementOnTarget
		}
	}

	MouseOffset[]	{
		get {
			return InputManager.s_MouseOffset
		}
	}
	TargetOffset[] {
		get {
			return InputManager.s_TargetOffset
		}
	}

	PressStack[] {
		get {
			return InputManager.s_PressStack
		}
	}
	PressCount[] {
		get {
			return InputManager.s_PressCount
		}
	}

	LootDelay[] {
		get {
			return InputManager.s_LootDelay
		}
	}
	TargetingDelay[] {
		get {
			return InputManager.s_TargetingDelay
		}
	}
	HoldDelay[] {
		get {
			return InputManager.s_HoldDelay
		}
	}

	MovementRadius[] {
		get {
			return InputManager.s_MovementRadius
		}
	}
	TargetRadius[] {
		get {
			return InputManager.s_TargetRadius
		}
	}

	MousePos[] {
		get {
			return InputManager.s_MousePos
		}
		set {
			return InputManager.s_MousePos := value
		}
	}
	TargetPos[] {
		get {
			return InputManager.s_TargetPos
		}
	}

	MouseHidden[] {
		get {
			return InputManager.s_MouseHidden
		}
	}

	Cursor[] {
		get {
			return InputManager.s_Cursor
		}
	}
	Reticule[] {
		get {
			return InputManager.s_Reticule
		}
	}

	Update()
	{
		if (this.s_ControllerEnabled)
			Controller.RefreshState()
		if (this.s_MouseKeyboardEnabled)
			Intercept.RefreshState()

		if (this.s_ControllerEnabled)
			Controller.ProcessInput()
		if (this.s_MouseKeyboardEnabled)
			Intercept.ProcessInput()

		if (this.s_ControllerEnabled)
			Controller.ProcessOther()
		if (this.s_MouseKeyboardEnabled)
			Intercept.ProcessOther()

		this.s_ForceMouseUpdate		:= False
		this.s_ForceReticuleUpdate	:= False
	}

	StartMoving()
	{
		Debug.Log("Pressing " . this.ForceMoveKey.String)
		InputHelper.PressKeybind(this.ForceMoveKey)

		this.Moving := True
	}
	StopMoving()
	{
		Debug.Log("Releasing " . this.ForceMoveKey.String)
		InputHelper.ReleaseKeybind(this.ForceMoveKey)

		this.Moving := False
	}

	OnToolTip()
	{
		local _debugText :=

        _debugText .= "MousePos: " . this.s_MousePos.String . "`n"
        _debugText .= "Moving: " . this.s_Moving . " ForceMouseUpdate: " . this.s_ForceMouseUpdate . "`n"

        _debugText .= "TargetPos: " this.s_TargetPos.String "`n"
        _debugText .= "UsingReticule: " . this.s_UsingReticule
				. " ForceReticuleUpdate: " . this.s_ForceReticuleUpdate . "`n"

        _debugText .= "PressStack - Length: " . this.s_PressStack.Length
					. " Peek: " . this.s_PressStack.Peek.Type . "`n"
					. "PressCount - "
                    . "Targeted: " . this.s_PressCount.Targeted . " "
                    . "Movement: " . this.s_PressCount.Movement

		return _debugText
	}
}