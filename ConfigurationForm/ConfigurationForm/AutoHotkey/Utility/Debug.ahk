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

	Draw()
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

	Hide()
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

global TEXT_OVERLAY_COUNT := 0

class TextOverlay
{
	__New(p_BackgroundColor)
	{
		global

		local _index := ++TEXT_OVERLAY_COUNT

		this.m_BackgroundName := "TextOverlayBackground" . _index
		local _guiName := this.m_BackgroundName

		Gui, %_guiName%: +E0x20 +LastFound +AlwaysOnTop -Caption +ToolWindow
		Gui, %_guiName%: Color, % p_BackgroundColor.Hex
		Gui, %_guiName%: Font, s12
		WinSet, Transparent,  % p_BackgroundColor.A

		this.m_BackgroundHWND := WinExist()

		this.m_Foreground := "TextOverlay" . _index
		_guiName := this.m_Foreground

		Gui, %_guiName%: -Caption +E0x20 +LastFound +AlwaysOnTop +ToolWindow
		Gui, %_guiName%: Color, % p_BackgroundColor.Hex
		Gui, %_guiName%: Font, s12
		WinSet, TransColor, % p_BackgroundColor.Hex . " 254"

		this.m_ForegroundHWND := WinExist()

		this.m_IsVisible := False
		this.m_SizeSet := False
	}

	IsVisible[]
	{
		get {
			return this.m_IsVisible
		}
	}

	Pos[]
	{
		get {
			return this.m_Pos
		}
	}
	Size[]
	{
		get {
			return this.m_Size
		}
	}

	Show(p_Pos)
	{
		global

		this.m_Pos := p_Pos

		local _posX := this.m_Pos.X
		local _posY := this.m_Pos.Y

		local _guiName := this.m_BackgroundName
		Gui, %_guiName%: Show, x%_posX% y%_posY% NA

		_guiName := this.m_Foreground
		Gui, %_guiName%: Show, x%_posX% y%_posY% NA

		this.m_Size := Graphics.GetClientSize(this.m_BackgroundHWND)

		this.m_IsVisible := True
	}

	Draw(p_Text, p_Pos)
	{
		global

		if (!this.m_SizeSet)
		{
			local _guiName := this.m_BackgroundName
			local _textName := _guiName . "Text"
			Gui, %_guiName%: Add, Text, v%_textName% cBlack, % p_Text

			_guiName := this.m_Foreground

			local _editName
			_editName := this.m_EditName := _guiName . "Edit"
			Gui, %_guiName%: Add, Edit, v%_editName% cWhite ReadOnly -VScroll -E0x200, % p_Text

			this.m_SizeSet := True
		}

		if (!this.m_IsVisible or !Vector2.IsEqual(this.m_Pos, p_Pos))
			this.Show(p_Pos)

		GuiControl, % this.m_Foreground . ":", % this.m_EditName, % p_Text
	}

	Hide()
	{
		local _guiName := this.m_BackgroundName
		Gui, %_guiName%: Hide

		_guiName := this.m_Foreground
		Gui, %_guiName%: Hide

		this.m_IsVisible := False
	}
}
class Debug
{
	static m_Enabled := False

	static m_LogEntries := Array()
	static m_UpdateLog := True

	static m_OnToolTip := Array()

	static m_LogFilename :=

	static m_DebugTextGUI :=
	static m_DebugLogGUI :=

	static m_LeftStickOverlay :=
	static m_RightStickOverlay :=

	Init()
	{
		global

		FileCreateDir, % "Log\"

		local _currentDate
		FormatTime, _currentDate, , yyyy-MM-dd  hh-mm-ss tt
		this.m_LogFilename := "Log\" . _currentDate . ".txt"
		FileAppend, , % this.m_LogFilename

		this.m_DebugTextGUI := new TextOverlay(new Color(0, 0, 0, 200))
		this.m_DebugLogGUI := new TextOverlay(new Color(0, 0, 0, 200))
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

	InitControllerOverlay()
	{
		this.m_LeftStickOverlay := new StickOverlay("Left")
		this.m_RightStickOverlay := new StickOverlay("Right")
	}

	Update()
	{
		global

		static _prevKeyState := GetKeyState("F3")
		if (GetKeyState("F3") and !_prevKeyState)
			this.Toggle()

		_prevKeyState := GetKeyState("F3")

		if (this.m_Enabled)
			this.DrawInfo()
	}

	DrawInfo()
	{
		global

		local _debugText :=

		local i, _delegate
		For i, _delegate in this.m_OnToolTip
		{
			_debugText .= %_delegate%()
			if (i != this.m_OnToolTip.MaxIndex())
				_debugText .= "`n`n"
		}

		this.m_DebugTextGUI.Draw(_debugText, new Vector2(0, 90))

		if (this.m_UpdateLog)
		{
			local _debugLog := _debugLog . "Debug Log:`n"

			For i, _entry in this.m_LogEntries
				_debugLog := _debugLog . _entry . "`n"

			this.m_DebugLogGUI.Draw(_debugLog, new Vector2(0, this.m_DebugTextGUI.Pos.Y + this.m_DebugTextGUI.Size.Height))

			this.m_UpdateLog := False
		}

		this.m_LeftStickOverlay.Draw()
		this.m_RightStickOverlay.Draw()
	}

	AddToLog(p_Entry)
	{
		global

		if (this.m_LogEntries.Length() >= 50)
			this.m_LogEntries.RemoveAt(1)

		local _newEntry := "[" . FPS.RuntimeString . "]: " . p_Entry

		FileAppend, % _newEntry . "`n", % this.m_LogFilename
		this.m_LogEntries.Push(_newEntry)

		this.m_UpdateLog := True
	}

	AddToOnToolTip(p_Delegate)
	{
		this.m_OnToolTip.Push(p_Delegate)
	}

	Toggle()
	{
		if (!this.m_Enabled)
			this.Enable()
		else
			this.Disable()
	}
	Enable()
	{
		Graphics.DrawToolTip("Debug mode enabled `nPress F3 to disable", 0, 50, 5)

		this.m_UpdateLog := True
		this.m_Enabled := True
	}
	Disable()
	{
		this.m_DebugTextGUI.Hide()
		this.m_DebugLogGUI.Hide()

		this.m_LeftStickOverlay.Hide()
		this.m_RightStickOverlay.Hide()

		Graphics.HideToolTip(5)

		this.m_Enabled := False
	}
}