; Contains the debug class

class StickOverlay
{
	__New(p_Direction)
	{
		global

		this.m_Direction := p_Direction

		this.m_Stick := this.m_Direction = "Left" ? Controller.LeftStick : Controller.RightStick

		local _overlayAlpha := 150
		this.m_OverlaySize
			:= new Vector2(Round(Graphics.ActiveWinStats.Size.Height / 2, 0)
						, Round(Graphics.ActiveWinStats.Size.Height / 2, 0))

		this.m_MaxRangeEllipse := new Ellipse(this.m_OverlaySize, new Color(255, 0, 255, _overlayAlpha), false, 1)
		this.m_OuterDeadzoneEllipse
			:= new Ellipse(new Vector2(this.m_OverlaySize.Width * this.m_Stick.MaxValue
									, this.m_OverlaySize.Height * this.m_Stick.MaxValue)
						, new Color(255, 0, 255, _overlayAlpha), false, 1)
		this.m_InnerDeadzoneEllipse
			:= new Ellipse(new Vector2(this.m_OverlaySize.Width * this.m_Stick.Deadzone
									, this.m_OverlaySize.Height * this.m_Stick.Deadzone)
						, new Color(255, 0, 255, _overlayAlpha), false, 1)

		this.m_AxisX
			:= new Line(new Vector2(0, this.m_OverlaySize.Height / 2)
					, new Vector2(this.m_OverlaySize.Width, this.m_OverlaySize.Height / 2)
					, this.m_OverlaySize
					, new Color(255, 0, 0, _overlayAlpha), 1)
		this.m_AxisY
			:= new Line(new Vector2(this.m_OverlaySize.Width / 2, 0)
					, new Vector2(this.m_OverlaySize.Width / 2, this.m_OverlaySize.Height)
					, this.m_OverlaySize
					, new Color(255, 0, 0, _overlayAlpha), 1)

		this.m_RawInputEllipse
			:= new Ellipse(new Vector2(this.m_OverlaySize.Width * 0.03, this.m_OverlaySize.Height * 0.03)
						, new Color(100, 0, 255, _overlayAlpha))
		this.m_ClampedInputEllipse
			:= new Ellipse(new Vector2(this.m_OverlaySize.Width * 0.03, this.m_OverlaySize.Height * 0.03)
						, new Color(0, 255, 0, _overlayAlpha))
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

	static m_LogFilename :=
	static m_DebugTextGUI := "DebugText"
	static m_DebugLogGUI := "DebugLog"

	static m_LeftStickOverlay :=
	static m_RightStickOverlay :=

	Init()
	{
		global

		this.__singleton := new Debug()

		FileCreateDir, % "Log\"

		local _currentDate
		FormatTime, _currentDate, , yyyy-MM-dd  hh-mm-ss tt
		this.m_LogFilename := "Log\" . _currentDate . ".txt"
		FileAppend, , % this.m_LogFilename

		; Example: On-screen display (OSD) via transparent window:

		CustomColor = 000000  ; Can be any RGB color (it will be made transparent below).
		Gui, 1: +LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
		Gui, 1: Color, %CustomColor%
		Gui, 1: Font, s12  ; Set a large font size (32-point).

		Gui, 2: +LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
		Gui, 2: Color, %CustomColor%
		Gui, 2: Font, s12  ; Set a large font size (32-point).

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

		static _textInit := False
		if (!_textInit)
		{
			Gui, 1: Add, Text, vTheText cWhite, % _debugText
			; Make all pixels of this color transparent and make the text itself translucent (150):
			;WinSet, TransColor, %CustomColor% 150
			Gui, 1: Show, x0 y90 NoActivate  ; NoActivate avoids deactivating the currently active window.
			_textInit := True
		}

		GuiControl, 1:Text, TheText, % _debugText
		;Graphics.DrawToolTip(_debugText, 0, 90, 7)

		local _x, _y, _w, _h
		WinGetPos, _x, _y, _w, _h, ahk_class tooltips_class32

		this.ToolTipPos		:= new Vector2(_x, _y)
		this.ToolTipSize 	:= new Vector2(_w, _h)

		if (this.UpdateLog)
		{
			local _debugLog := _debugLog . "Debug Log:`n"

			For i, _entry in this.LogEntries
				_debugLog := _debugLog . _entry . "`n"

			static _logInit := False
			if (!_logInit)
			{
				Gui, 2: Add, Text, vMyLog cWhite, % _debugLog
				; Make all pixels of this color transparent and make the text itself translucent (150):
				;WinSet, TransColor, %CustomColor% 150
				Gui, 2: Show, x0 y500 NoActivate  ; NoActivate avoids deactivating the currently active window.
				_logInit := True
			}
			GuiControl, 2:Text, MyLog, % _debugLog
			;Graphics.DrawToolTip(_debugLog, 0, this.ToolTipPos.Y + this.ToolTipSize.Height + 5, 8)

			this.UpdateLog := False
		}

		this.m_LeftStickOverlay.DrawOverlay()
		this.m_RightStickOverlay.DrawOverlay()
	}

	AddToLog(p_Entry)
	{
		global

		if (this.LogEntries.Length() >= 50)
			this.LogEntries.RemoveAt(1)

		local _newEntry := "[" . this.CurrentRuntime . "]: " . p_Entry

		FileAppend, % _newEntry . "`n", % this.m_LogFilename
		this.LogEntries.Push(_newEntry)

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