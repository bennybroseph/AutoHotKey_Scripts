; Contains the debug class

class StickOverlay
{
	__New(p_Direction)
	{
		global

		this.m_Direction := p_Direction

		this.m_Stick := this.m_Direction = "Left" ? Controller.LeftStick : Controller.RightStick

		this.m_OverlaySize
			:= new Vector2(Round(Graphics.ActiveWinStats.Size.Height / 2, 0)
						, Round(Graphics.ActiveWinStats.Size.Height / 2, 0))

		this.m_MaxRangeEllipse := new Ellipse(this.m_OverlaySize, 0x96ff0000, false, 1)
		this.m_OuterDeadzoneEllipse
			:= new Ellipse(new Vector2(this.m_OverlaySize.Width * this.m_Stick.MaxValue
									, this.m_OverlaySize.Height * this.m_Stick.MaxValue)
						, 0x96ff00ff, false, 1)
		this.m_InnerDeadzoneEllipse
			:= new Ellipse(new Vector2(this.m_OverlaySize.Width * this.m_Stick.Deadzone
									, this.m_OverlaySize.Height * this.m_Stick.Deadzone)
						, 0x96ff00ff, false, 1)

		this.m_AxisX
			:= new Line(new Vector2(0, this.m_OverlaySize.Height / 2)
					, new Vector2(this.m_OverlaySize.Width, this.m_OverlaySize.Height / 2)
					, this.m_OverlaySize
					, 0x96ff0000, 1)
		this.m_AxisY
			:= new Line(new Vector2(this.m_OverlaySize.Width / 2, 0)
					, new Vector2(this.m_OverlaySize.Width / 2, this.m_OverlaySize.Height)
					, this.m_OverlaySize
					, 0x96ff0000, 1)

		this.m_RawInputEllipse
			:= new Ellipse(new Vector2(this.m_OverlaySize.Width * 0.03, this.m_OverlaySize.Height * 0.03)
						, 0x966400ff)
		this.m_ClampedInputEllipse
			:= new Ellipse(new Vector2(this.m_OverlaySize.Width * 0.03, this.m_OverlaySize.Height * 0.03)
						, 0x9600ff00)
	}

	DrawOverlay()
	{
		global

		local _center := new Vector2(Graphics.ActiveWinStats.Pos.X, Graphics.ActiveWinStats.Pos.Y)
		_center.X += (Graphics.ActiveWinStats.Size.Width / 4) * 3
		_center.Y += (Graphics.ActiveWinStats.Size.Height / 4) * (this.m_Direction = "Left" ? 1 : 3)

		Graphics.DrawImage(this.m_MaxRangeEllipse, _center)
		Graphics.DrawImage(this.m_OuterDeadzoneEllipse, _center)
		Graphics.DrawImage(this.m_InnerDeadzoneEllipse, _center)

		Graphics.DrawImage(this.m_AxisX, _center)
		Graphics.DrawImage(this.m_AxisY, _center)

		Graphics.DrawImage(this.m_RawInputEllipse
			, new Vector2(_center.X + this.m_Stick.RawStickValue.X
							* (this.m_OverlaySize.Width / 2)
						, _center.Y - this.m_Stick.RawStickValue.Y
							* (this.m_OverlaySize.Height / 2)))
		Graphics.DrawImage(this.m_ClampedInputEllipse
			, new Vector2(_center.X + this.m_Stick.ClampedStickValue.X
							* (this.m_OverlaySize.Width / 2)
						, _center.Y - this.m_Stick.ClampedStickValue.Y
							* (this.m_OverlaySize.Height / 2)))
	}

	HideOverlay()
	{
		Graphics.HideImage(this.m_MaxRangeEllipse)
		Graphics.HideImage(this.m_OuterDeadzoneEllipse)
		Graphics.HideImage(this.m_InnerDeadzoneEllipse)

		Graphics.HideImage(this.m_AxisX)
		Graphics.HideImage(this.m_AxisY)

		Graphics.HideImage(this.m_RawInputEllipse)
		Graphics.HideImage(this.m_ClampedInputEllipse)
	}
}

class Debug
{
	static __singleton :=
	static __init := False

	static m_LeftStickOverlay :=
	static m_RightStickOverlay :=

	Init()
	{
		this.__singleton := new Debug()

		this.__init := True
	}

	__New()
	{
		this.m_Enabled := False

		this.m_StartupTick := A_TickCount

		this.m_ToolTipPos	:= new Vector2()
		this.m_ToolTipSize	:= new Vector2()

		this.m_LogEntries := Array()
		this.m_UpdateLog := True

		this.m_OnToolTip := Array()
	}

	CurrentTickDelta[]
	{
		get {
			return A_TickCount - Debug.__singleton.m_StartupTick
		}
	}
	CurrentRuntime[]
	{
		get {
			local _ticksRemaining := this.CurrentTickDelta

			local _hours 	:= Floor(_ticksRemaining / 1000 / 60 / 60)
			_ticksRemaining := _ticksRemaining - (_hours * 1000 * 60 * 60)

			local _minutes 	:= Floor(_ticksRemaining / 1000 / 60)
			_ticksRemaining := _ticksRemaining - (_minutes * 1000 * 60)

			local _seconds := Floor(_ticksRemaining / 1000)
			_ticksRemaining := _ticksRemaining - (_seconds * 1000)

			local _miliseconds := _ticksRemaining

			return _hours . ":" . _minutes  . ":" . _seconds . ":" . _miliseconds
		}
	}

	Enabled[]
	{
		get {
			return this.__singleton.m_Enabled
		}
	}

	ToolTipPos[]
	{
		get {
			return this.__singleton.m_ToolTipPos
		}
	}
	ToolTipSize[]
	{
		get {
			return this.__singleton.m_ToolTipSize
		}
	}

	LogEntries[]
	{
		get {
			return this.__singleton.m_LogEntries
		}
	}
	UpdateLog[]
	{
		get {
			return this.__singleton.m_UpdateLog
		}
		set {
			return this.__singleton.m_UpdateLog := value
		}
	}

	OnToolTip[]
	{
		get {
			return this.__singleton.m_OnToolTip
		}
	}

	InitControllerOverlay()
	{
		this.m_LeftStickOverlay := new StickOverlay("Left")
		this.m_RightStickOverlay := new StickOverlay("Right")
	}

	DrawInfo()
	{
		global

		local _debugText :=

		local i, _delegate
		For i, _delegate in this.OnToolTip
			_debugText := _debugText . %_delegate%() . "`n`n"

		Graphics.DrawToolTip(_debugText, 0, 90, 7)

		local _x, _y, _w, _h
		WinGetPos, _x, _y, _w, _h, ahk_class tooltips_class32

		this.ToolTipPos		:= new Vector2(_x, _y)
		this.ToolTipSize 	:= new Vector2(_w, _h)

		if (this.UpdateLog)
		{
			local _debugLog := _debugLog . "Debug Log:`n"

			For i, _entry in this.LogEntries
				_debugLog := _debugLog . _entry . "`n"

			Graphics.DrawToolTip(_debugLog, 0, this.ToolTipPos.Y + this.ToolTipSize.Height + 5, 8)

			this.UpdateLog := False
		}

		this.m_LeftStickOverlay.DrawOverlay()
		this.m_RightStickOverlay.DrawOverlay()
	}

	AddToLog(p_Entry)
	{
		if (this.LogEntries.Length() >= 50)
			this.LogEntries.RemoveAt(1)

		this.LogEntries.Push("[" . this.CurrentRuntime . "]: " . p_Entry)

		this.UpdateLog := True
	}

	AddToOnToolTip(p_Delegate)
	{
		this.OnToolTip.Push(p_Delegate)
	}

	Toggle()
	{
		if (!this.Enabled)
			this.Enable()
		else
			this.Disable()
	}
	Enable()
	{
		Graphics.DrawToolTip("Debug mode enabled `nPress F3 to disable", 0, 50, 5)

		this.UpdateLog := True
		this.Enabled := True
	}
	Disable()
	{
		this.m_LeftStickOverlay.HideOverlay()
		this.m_RightStickOverlay.HideOverlay()

		Graphics.HideToolTip(5)
		Graphics.HideToolTip(7)
		Graphics.HideToolTip(8)

		this.Enabled := False
	}
}