
class InputManager
{
	static s_Init := False

	static s_Moving := False

	static s_ForceMouseUpdate	:= True
	static s_ForceReticuleUpdate 	:= True

	static s_MoveOnlyKey

	static s_RepeatForceMove
	static s_HaltMovementOnTarget

	static s_MouseOffset
	static s_TargetOffset

	static s_TargetedKeybinds
	static s_MovementKeybinds

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
		InputManager.s_MoveOnlyKey := IniReader.ParseKeybind(IniReader.ReadKeybindingKey(KeybindingSection.Keybindings, "Force_Move"))

		InputManager.s_RepeatForceMove := IniReader.ReadProfileKey(ProfileSection.Preferences, "Repeat_Force_Move")
		InputManager.s_HaltMovementOnTarget := IniReader.ReadProfileKey(ProfileSection.Preferences, "Halt_Movement_On_Target")

		InputManager.s_MouseOffset
            := new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Movement_Center_Offset_X")
                        , IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Movement_Center_Offset_Y"))
        InputManager.s_TargetOffset
            := new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Targeting_Center_Offset_X")
                        , IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Targeting_Center_Offset_Y"))

		InputManager.s_TargetedKeybinds	:= IniReader.ParseKeybindArray("Targeted_Actions")
        InputManager.s_MovementKeybinds	:= IniReader.ParseKeybindArray("Movement_Actions")

		InputManager.s_PressStack := new LooseStack()
        InputManager.s_PressCount := new PressCounter()

		InputManager.s_LootDelay 		:= IniReader.ReadProfileKey(ProfileSection.Preferences, "Loot_Delay")
		InputManager.s_TargetingDelay	:= IniReader.ReadProfileKey(ProfileSection.Preferences, "Targeting_Delay")
		InputManager.s_HoldDelay 		:= IniReader.ReadProfileKey(ProfileSection.Preferences, "Hold_Delay")

		InputManager.s_MovementRadius
			:= new Rect(new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Movement_Min_Radius_Width")
								, IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Movement_Min_Radius_Height"))
					, new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Movement_Max_Radius_Width")
								, IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Movement_Max_Radius_Height")))

		InputManager.s_TargetRadius
			:= new Rect(new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Targeting_Min_Radius_Width")
								, IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Targeting_Min_Radius_Height"))
					, new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Targeting_Max_Radius_Width")
								, IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Targeting_Max_Radius_Height")))

		InputManager.s_MousePos		:= InputHelper.GetMousePos()
		InputManager.s_TargetPos	:= CriticalObject(InputHelper.GetMousePos())

		InputManager.s_MouseHidden := True

		InputManager.s_Cursor 	:= new Image("Images\diabloCursor.png")
		InputManager.s_Reticule := new Image("Images\Target.png")

		Debug.OnToolTipAddListener(new Delegate(this, "OnToolTip"))

		InputManager.s_Init := True

		Controller.Init()
		Intercept.Init()
	}
	; Create accessors for children
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

	MoveOnlyKey[] {
		get {
			return InputManager.s_MoveOnlyKey
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

	TargetedKeybinds[] {
		get {
			return InputManager.s_TargetedKeybinds
		}
	}
	MovementKeybinds[] {
		get {
			return InputManager.s_MovementKeybinds
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
		set {
			return InputManager.s_TargetPos := value.Clone()
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

	RefreshState()
	{
		;Controller.RefreshState()
		Intercept.RefreshState()
	}
	ProcessInput()
	{
		;Controller.ProcessInput()
		Intercept.ProcessInput()
	}

	StartMoving()
	{
		Debug.Log("Pressing " . this.MoveOnlyKey.String)
		InputHelper.PressKeybind(this.MoveOnlyKey)

		this.Moving := True
	}
	StopMoving()
	{
		Debug.Log("Releasing " . this.MoveOnlyKey.String)
		InputHelper.ReleaseKeybind(this.MoveOnlyKey)

		this.Moving := False
	}

	OnToolTip()
	{
		local _debugText :=

        _debugText .= "MousePos: " . InputManager.s_MousePos.String . "`n"
        _debugText .= "Moving: " . InputManager.s_Moving . " ForceMouseUpdate: " . InputManager.s_ForceMouseUpdate . "`n"

        _debugText .= "TargetPos: " InputManager.s_TargetPos.String "`n"
        _debugText .= "UsingReticule: " . InputManager.s_UsingReticule
				. " ForceReticuleUpdate: " . InputManager.s_ForceReticuleUpdate . "`n"

        _debugText .= "PressStack - Length: " . InputManager.s_PressStack.Length
					. " Peek: " . InputManager.s_PressStack.Peek.Type . "`n"
					. "PressCount - "
                    . "Targeted: " . InputManager.s_PressCount.Targeted . " "
                    . "Movement: " . InputManager.s_PressCount.Movement

		return _debugText
	}
}