; Intercepts keyboard and mouse input and manipulates it

class Intercept extends InputManager
{
	static m_UsingReticule := True

	static m_TargetedKeybinds
	static m_MovementKeybinds

	static m_Up 	:= False
	static m_Down 	:= False
	static m_Left 	:= False
	static m_Right 	:= False

	static m_Keys := Array()

	static m_PrevMovement := new Vector2()
	static m_Movement := new Vector2()

	static m_PrevTargetPos := new Vector2()

	static m_Reticule

	Init()
	{
		global

		BlockInput, MouseMove

		this.m_Reticule := new Image("Images\" . Graphics.ApplicationTitle . ".png", 1, 5)

		this.m_TargetedKeybinds	:= IniReader.ParseKeybindArray(KeybindingSection.MouseKeyboard, "Targeted_Actions")
        this.m_MovementKeybinds	:= IniReader.ParseKeybindArray(KeybindingSection.MouseKeyboard, "Movement_Actions")

		local _moveKeys := Array("Up", "Down", "Left", "Right")

		local i, _moveKey
		for i, _moveKey in _moveKeys
		{
			local _key := new Key(IniReader.ReadKeybindingKey(KeybindingSection.MouseKeyboard, "Move_" . _moveKey))
			local _boundFunction := ObjBindMethod(Intercept, "MovePress", _moveKey)
			hotkey, % "*" . _key.Keybind.Hotkey, % _boundFunction
			_boundFunction := ObjBindMethod(Intercept, "MoveRelease", _moveKey)
			hotkey, % "*" . _key.Keybind.Hotkey . " Up", % _boundFunction
		}

		local _keybind
		for i, _keybind in this.m_TargetedKeybinds
			this.m_Keys.Push(CriticalObject(new Key(_keybind.String, KeybindType.Targeted)))
		for i, _keybind in this.m_MovementKeybinds
			this.m_Keys.Push(CriticalObject(new Key(_keybind.String, KeybindType.Movement)))

		local _key
		for i, _key in this.m_Keys
		{
			AHKThread("#Include Input\KeyPressThread.ahk", &_key)
			AHKThread("#Include Input\KeyReleaseThread.ahk", &_key)
		}

		AHKThread("#Include Input\MouseThread.ahk", &this.TargetPos)

		this.m_CurrTime := FPS.GetCurrentTime()
		this.m_PrevTime := this.m_CurrTime

		Debug.OnToolTipAddListener(new Delegate(Intercept, "OnToolTip"))
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

	RefreshState()
	{
		global

		this.m_PrevMovement := this.m_Movement.Clone()

		this.m_Movement := new Vector2()
		if (this.m_Up)
		{
			;this.m_Movement.X += 1
			this.m_Movement.Y -= 1
		}
		if (this.m_Down)
		{
			;this.m_Movement.X -= 1
			this.m_Movement.Y += 1
		}

		if (this.m_Left)
		{
			this.m_Movement.X -= 1
			;this.m_Movement.Y += 1
		}
		if (this.m_Right)
		{
			this.m_Movement.X += 1
			;this.m_Movement.Y += 1
		}
	}

	ProcessInput()
	{
		global

		local i, _key
		for i, _key in this.m_Keys
		{
			if (_key.State != _key.PrevState)
			{
				if (_key.State)
				{
					Debug.Log("Pressed " . _key.Keybind.String)
					InputHelper.PressKeybind(_key.Keybind)
				}
				else
				{
					Debug.Log("Released " . _key.Keybind.String)
					InputHelper.ReleaseKeybind(_key.Keybind)
				}

				_key.PrevState := _key.State
			}
		}
	}

	ProcessOther()
	{
		global

		if (!Vector2.IsEqual(this.m_Movement, this.m_PrevMovement)
		or ((this.RepeatForceMove or this.ForceMouseUpdate) and !this.ControllerEnabled))
		{
			local _centerOffset
				:= Vector2.Add(Vector2.Add(Graphics.ActiveWinStats.Pos, Graphics.ActiveWinStats.Center)
							, Vector2.Mul(this.MouseOffset, Graphics.ResolutionScale))

			this.MousePos := _centerOffset

			if (!Vector2.IsEqual(this.m_Movement, Vector2.Zero))
			{
				local _radius
					:= new Rect(Vector2.Mul(this.MovementRadius.Min, Graphics.ResolutionScale)
							, Vector2.Mul(this.MovementRadius.Max, Graphics.ResolutionScale))

				this.MousePos.X += (_radius.Min.Width * this.m_Movement.Normalize.X)
									+ (_radius.Size.Width * this.m_Movement.X)
				this.MousePos.Y += (_radius.Min.Height * this.m_Movement.Normalize.Y)
									+ (_radius.Size.Height * this.m_Movement.Y)
			}
			else if (this.Moving and !this.PressStack.Peek)
				this.StopMoving()

			if (this.PressStack.Peek.Type != KeybindType.Targeted and !Vector2.IsEqual(this.m_Movement, Vector2.Zero))
				InputHelper.MoveMouse(this.MousePos)

			if (!Vector2.IsEqual(this.m_Movement, Vector2.Zero))
			{
				if ((!this.Moving or this.RepeatForceMove) and !this.PressStack.Peek)
				{
					if (this.RepeatForceMove and FPS.GetCurrentTime() - this.LastForceMove >= this.RepeatForceMoveSpeed)
					{
						this.StopMoving()
						this.StartMoving()

						this.LastForceMove := FPS.GetCurrentTime()
					}
					else
						this.StartMoving()
				}
			}
		}

		if (!Vector2.IsEqual(this.TargetPos, this.m_PrevTargetPos)
		or this.ForceReticuleUpdate)
		{
			local newTargetPos := Vector2.Clamp(this.TargetPos, Graphics.ScreenBounds.Min, Graphics.Screenbounds.Max)

			this.TargetPos.X := newTargetPos.X
			this.TargetPos.Y := newTargetPos.Y

			if (this.PressStack.Peek.Type = KeybindType.Targeted
			or (this.PressStack.Peek.Type != KeybindType.Movement and !this.Moving))
				InputHelper.MoveMouse(this.TargetPos)

			this.m_Reticule.Draw(this.TargetPos, False)
		}

		this.m_PrevTargetPos.X := this.TargetPos.X
		this.m_PrevTargetPos.Y := this.TargetPos.Y
	}

	PressKeybind(p_Key)
	{
		if (p_Key.State = True)
			Exit

		Debug.Log("Pressed " . p_Key.Keybind.String)
		InputHelper.PressKeybind(p_Key.Keybind)

		p_Key.PrevState := p_Key.State
		p_Key.State := True
	}
	ReleaseKeybind(p_Key)
	{
		if (p_Key.State = False)
			Exit

		Debug.Log("Released " . p_Key.Keybind.String)
		InputHelper.ReleaseKeybind(p_Key.Keybind)

		p_Key.PrevState := p_Key.State
		p_Key.State := False
	}

	MovePress(p_Direction)
	{
		if (p_Direction = "Up")
			this.m_Up := True
		if (p_Direction = "Down")
			this.m_Down := True
		if (p_Direction = "Left")
			this.m_Left := True
		if (p_Direction = "Right")
			this.m_Right := True
	}
	MoveRelease(p_Direction)
	{
		if (p_Direction = "Up")
			this.m_Up := False
		if (p_Direction = "Down")
			this.m_Down := False
		if (p_Direction = "Left")
			this.m_Left := False
		if (p_Direction = "Right")
			this.m_Right := False
	}

	; MouseEvent(p_MouseID, p_X := 0, p_Y := 0)
	; {
	; 	global

	; 	static _carryX := 0, _carryY := 0, _mainMouse

	; 	if (p_MouseID = 0 or (_mainMouse and p_MouseID != _mainMouse))
	; 		return

	; 	_mainMouse := p_MouseID

	; 	this.m_PrevTime := this.m_CurrTime
	; 	this.m_CurrTime := FPS.GetCurrentTime()

	; 	local _deltaTime := Min(this.m_CurrTime - this.m_PrevTime, FPS.Delay)

	; 	; Pre-scale
	; 	p_X *= 3
	; 	p_Y *= 3

	; 	; Speedcap
	; 	if (False)
	; 	{
	; 		local _rate := Sqrt(p_X * p_X + p_Y * p_Y)

	; 		if (_rate >= 10)
	; 		{

	; 		}
	; 	}

	; 	; Acceleration
	; 	local _accelSens := 1
	; 	if (True)
	; 	{
	; 		local _rate := Sqrt(p_X * p_X + p_Y * p_Y) / _deltaTime
	; 		_rate -= 1

	; 		if (_rate > 0)
	; 		{
	; 			_rate *= 1.5

	; 			local _power = Max(2 - 1, 0)
	; 			_accelSens += Exp(_power * Log(_rate))
	; 		}
	; 	}
	; 	_accelSens /= 1

	; 	p_X *= _accelSens
	; 	p_Y *= _accelSens

	; 	p_X *= _deltaTime / 1000
	; 	p_Y *= _deltaTime / 1000

	; 	p_X *= 50
	; 	p_Y *= 50

	; 	this.m_DeltaMouse := new Vector2(p_X, p_Y)

	; 	this.m_CursorPos := Vector2.Add(this.m_CursorPos, this.m_DeltaMouse)
	; 	this.m_Reticule.Draw(this.m_CursorPos)
	; }

	OnToolTip()
	{
		global

		local _debugText :=

		_debugText .= "CursorPos: " . this.TargetPos.String . " Movement" . this.m_Movement.String

		return _debugText
	}
}