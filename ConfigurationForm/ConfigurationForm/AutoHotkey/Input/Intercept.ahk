; Intercepts keyboard and mouse input and manipulates it

class Intercept
{
	static m_CurrTime
	static m_PrevTime

	static m_DeltaMouse := new Vector2()
	static m_PrevMousePos := new Vector2()

	static m_CursorPos := new Vector2()

	static m_Up 	:= False
	static m_Down 	:= False
	static m_Left 	:= False
	static m_Right 	:= False

	static m_PrevMovement := new Vector2()
	static m_Movement := new Vector2()

	static m_Reticule

	Init()
	{
		global

		BlockInput, MouseMove

		this.m_Reticule := new Image("Images\Target.png")

		; TODO Loop through movement inputs

		; Up inputs
		local fn := ObjBindMethod(Intercept, "MovePress", "Up")
		hotkey, $w, % fn
		local fn := ObjBindMethod(Intercept, "MoveRelease", "Up")
		hotkey, $w Up, % fn

		; Down inputs
		local fn := ObjBindMethod(Intercept, "MovePress", "Down")
		hotkey, $s, % fn
		local fn := ObjBindMethod(Intercept, "MoveRelease", "Down")
		hotkey, $s Up, % fn

		; Left inputs
		local fn := ObjBindMethod(Intercept, "MovePress", "Left")
		hotkey, $a, % fn
		local fn := ObjBindMethod(Intercept, "MoveRelease", "Left")
		hotkey, $a Up, % fn

		; Right Inputs
		local fn := ObjBindMethod(Intercept, "MovePress", "Right")
		hotkey, $d, % fn
		local fn := ObjBindMethod(Intercept, "MoveRelease", "Right")
		hotkey, $d Up, % fn

		; TODO Loop through Targeted Skills
		local fn := ObjBindMethod(Intercept, "TargetedPress", "q")
		hotkey, $q, % fn
		local fn := ObjBindMethod(Intercept, "TargetedRelease", "q")
		hotkey, $q Up, % fn

		local fn := ObjBindMethod(Intercept, "TargetedPress", "LButton")
		hotkey, $*LButton, % fn
		local fn := ObjBindMethod(Intercept, "TargetedRelease", "LButton")
		hotkey, $*LButton Up, % fn

		this.m_PrevMousePos := InputHelper.GetMousePos()

		local _function := new MouseDelta(new Delegate(Intercept, "MouseEvent"))
		_function.SetState(1)

		this.m_CurrTime := FPS.GetCurrentTime()
		this.m_PrevTime := this.m_CurrTime

		Debug.OnToolTipAddListener(new Delegate(Intercept, "OnToolTip"))
	}

	Update()
	{
		this.m_PrevMovement := this.m_Movement.Clone()

		this.m_Movement := new Vector2()
		if (this.m_Up)
			this.m_Movement.Y -= 1
		if (this.m_Down)
			this.m_Movement.Y += 1

		if (this.m_Left)
			this.m_Movement.X -= 1.5
		if (this.m_Right)
			this.m_Movement.X += 1.5

		if (!Vector2.IsEqual(this.m_Movement, this.m_PrevMovement))
		{
			InputHelper.MoveMouse(Vector2.Add(Graphics.ActiveWinStats.Center, Vector2.Mul(this.m_Movement, 50)))
			if (!Vector2.IsEqual(this.m_Movement, Vector2.Zero))
				InputHelper.PressKey("Space")
			else
				InputHelper.ReleaseKey("Space")
		}
	}

	TargetedPress(p_Key)
	{
		InputHelper.ReleaseKey("Space")
		InputHelper.MoveMouse(this.m_CursorPos)
		InputHelper.PressKey(p_Key)
	}
	TargetedRelease(p_Key)
	{
		InputHelper.ReleaseKey(p_Key)
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

	MouseEvent(p_MouseID, p_X := 0, p_Y := 0)
	{
		global

		static _carryX := 0, _carryY := 0, _mainMouse

		if (p_MouseID = 0 or (_mainMouse and p_MouseID != _mainMouse))
			return

		_mainMouse := p_MouseID

		this.m_PrevTime := this.m_CurrTime
		this.m_CurrTime := FPS.GetCurrentTime()

		local _deltaTime := Min(this.m_CurrTime - this.m_PrevTime, 200)

		; Pre-scale
		p_X *= 3
		p_Y *= 3

		; Speedcap
		if (False)
		{
			local _rate := Sqrt(p_X * p_X + p_Y * p_Y)

			if (_rate >= 10)
			{

			}
		}

		; Acceleration
		local _accelSens := 1
		if (True)
		{
			local _rate := Sqrt(p_X * p_X + p_Y * p_Y) / _deltaTime
			_rate -= 1

			if (_rate > 0)
			{
				_rate *= 0.75

				local _power = Max(2 - 1, 0)
				_accelSens += Exp(_power * Log(_rate))
			}
		}
		_accelSens /= 1

		p_X *= _accelSens
		p_Y *= _accelSens

		p_X *= _deltaTime / 1000
		p_Y *= _deltaTime / 1000

		p_X *= 60
		p_Y *= 60

		this.m_DeltaMouse := new Vector2(p_X, p_Y)

		this.m_CursorPos := Vector2.Add(this.m_CursorPos, this.m_DeltaMouse)
		this.m_Reticule.Draw(this.m_CursorPos)
	}

	OnToolTip()
	{
		global

		local _debugText :=

		_debugText .= "DeltaMouse: " . this.m_DeltaMouse.String . " CursorPos: " . this.m_CursorPos.String . "`n"
		_debugText .= "Movement" . this.m_Movement.String

		return _debugText
	}
}