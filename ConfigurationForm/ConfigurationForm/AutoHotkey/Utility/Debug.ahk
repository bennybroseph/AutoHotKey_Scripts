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
			:= new Vector2(Round(Graphics.ActiveWinStats.Size.Height / 2.15, 0)
						, Round(Graphics.ActiveWinStats.Size.Height / 2.15, 0))

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
		this.m_AdjustedInputEllipse
			:= new Ellipse(new Vector2(this.m_OverlaySize.Width * 0.03, this.m_OverlaySize.Height * 0.03)
						, new Color(0, 100, 255, _overlayAlpha))
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

		this.m_MaxRangeEllipse.Draw(_center)
		this.m_OuterDeadzoneEllipse.Draw(_center)
		this.m_InnerDeadzoneEllipse.Draw(_center)

		this.m_AxisX.Draw(_center)
		this.m_AxisY.Draw(_center)


		this.m_RawInputEllipse
			.Draw(new Vector2(_center.X + this.m_Stick.RawStickValue.X
								* (this.m_OverlaySize.Width / 2)
							, _center.Y - this.m_Stick.RawStickValue.Y
								* (this.m_OverlaySize.Height / 2)))
		this.m_AdjustedInputEllipse
			.Draw(new Vector2(_center.X + this.m_Stick.AdjustedStickValue.X
								* (this.m_OverlaySize.Width / 2)
							, _center.Y - this.m_Stick.AdjustedStickValue.Y
								* (this.m_OverlaySize.Height / 2)))
		this.m_ClampedInputEllipse
			.Draw(new Vector2(_center.X + this.m_Stick.ClampedStickValue.X
								* (this.m_OverlaySize.Width / 2)
							, _center.Y - this.m_Stick.ClampedStickValue.Y
								* (this.m_OverlaySize.Height / 2)))

		this.m_FirstDraw := False
	}

	Hide()
	{
		this.m_MaxRangeEllipse.Hide()
		this.m_OuterDeadzoneEllipse.Hide()
		this.m_InnerDeadzoneEllipse.Hide()

		this.m_AxisX.Hide()
		this.m_AxisY.Hide()

		this.m_RawInputEllipse.Hide()
		this.m_AdjustedInputEllipse.Hide()
		this.m_ClampedInputEllipse.Hide()

		this.m_FirstDraw := True
	}
}

global TEXT_OVERLAY_COUNT := 0

class TextOverlay
{
	__New(p_BackgroundColor, p_AutoSize := False)
	{
		global

		this.m_BackgroundColor := p_BackgroundColor
		this.m_AutoSize := p_AutoSize

		local _index := ++TEXT_OVERLAY_COUNT

		this.m_BackgroundName := "TextOverlayBackground" . _index
		local _guiName := this.m_BackgroundName

		Gui, %_guiName%: -Caption +E0x20 +LastFound +AlwaysOnTop +ToolWindow
		Gui, %_guiName%: Color, % this.m_BackgroundColor.Hex
		Gui, %_guiName%: Font, s11, Consolas
		WinSet, Transparent,  % this.m_BackgroundColor.A

		this.m_BackgroundHWND := WinExist()

		this.m_ForegroundName := "TextOverlay" . _index
		_guiName := this.m_ForegroundName

		Gui, %_guiName%: -Caption +E0x20 +LastFound +AlwaysOnTop +ToolWindow
		Gui, %_guiName%: Color, % this.m_BackgroundColor.Hex
		Gui, %_guiName%: Font, s11, Consolas
		WinSet, TransColor, % this.m_BackgroundColor.Hex . " 254"

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
		Gui, %_guiName%: Show, x%_posX% y%_posY% NA AutoSize

		_guiName := this.m_ForegroundName
		Gui, %_guiName%: Show, x%_posX% y%_posY% NA AutoSize

		this.m_Size := Graphics.GetClientSize(this.m_BackgroundHWND)

		this.m_IsVisible := True
	}

	Draw(p_Text, p_Pos)
	{
		global

		if (!this.m_SizeSet)
		{
			local _guiName := this.m_BackgroundName

			local _backgroundColor := this.m_BackgroundColor.Hex
			local _textName
			_textName := this.m_TextName := _guiName . "Text"
			Gui, %_guiName%: Add, Text, v%_textName% c%_backgroundColor%, % p_Text

			_guiName := this.m_ForegroundName

			local _editName
			_editName := this.m_EditName := _guiName . "Edit"
			Gui, %_guiName%: Add, Edit, v%_editName% cd4d4d4 ReadOnly -VScroll -E0x200, % p_Text
		}
		else if (this.m_AutoSize)
		{
			local _size := Graphics.GetControlAutoSize(p_Text)
			if (!Vector2.IsEqual(_size, this.m_Size))
			{
				GuiControl, % this.m_BackgroundName . ": Move", % this.m_TextName, % "w" _size.Width "h" _size.Height
				GuiControl, % this.m_ForegroundName . ": Move", % this.m_EditName, % "w" _size.Width "h" _size.Height

				this.Show(p_Pos)
			}
		}

		if (!this.m_IsVisible or !Vector2.IsEqual(this.m_Pos, p_Pos))
			this.Show(p_Pos)

		GuiControl, % this.m_ForegroundName . ":", % this.m_EditName, % p_Text

		this.m_SizeSet := True
	}

	Hide()
	{
		local _guiName := this.m_BackgroundName
		Gui, %_guiName%: Hide

		_guiName := this.m_ForegroundName
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

	static m_LogFilename

	static m_DebugTextGUI
	static m_DebugLogGUI

	static m_LeftStickOverlay
	static m_RightStickOverlay

	Init()
	{
		global

		FileCreateDir, % "Log\"

		local _currentDate
		FormatTime, _currentDate, , yyyy-MM-dd  hh-mm-ss tt
		this.m_LogFilename := "Log\" . _currentDate . ".txt"
		FileAppend, , % this.m_LogFilename

		local _logCount := 0
		Loop, Log\*.*
			++_logCount

		local _maxLogCount := 50
		if (_logCount > _maxLogCount)
		{
			Debug.Log("Deleting old log files...")

			local _maxLoops := _logCount - (_maxLogCount / 2)
			local _iter := 0
			Loop, Log\*.*
			{
				if (_iter > _maxLoops)
					break

				FileDelete, % A_LoopFileFullPath
				++_iter
			}
		}

		this.m_DebugTextGUI := new TextOverlay(new Color(30, 30, 30, 225))
		this.m_DebugLogGUI := new TextOverlay(new Color(30, 30, 30, 225), True)
	}

	Enabled[]
	{
		get {
			return this.m_Enabled
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

		static _prevKeyState := GetKeyState("F3", "P")
		if (GetKeyState("F3", "P") and !_prevKeyState)
			this.Toggle()

		_prevKeyState := GetKeyState("F3", "P")

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

			local i, _entry
			For i, _entry in this.m_LogEntries
			{
				_debugLog .= _entry
				if (i != this.m_LogEntries.MaxIndex())
					_debugLog .= "`n"
			}

			this.m_DebugLogGUI.Draw(_debugLog, new Vector2(0, this.m_DebugTextGUI.Pos.Y + this.m_DebugTextGUI.Size.Height))

			this.m_UpdateLog := False
		}

		this.m_LeftStickOverlay.Draw()
		this.m_RightStickOverlay.Draw()
	}

	Log(p_Entry)
	{
		global

		if (this.m_LogEntries.Length() >= 40)
			this.m_LogEntries.RemoveAt(1)

		local _newEntry := "[" . FPS.RuntimeString . "]: " . p_Entry

		FileAppend, % _newEntry . "`n", % this.m_LogFilename
		this.m_LogEntries.Push(_newEntry)

		this.m_UpdateLog := True
	}

	OnToolTipAddListener(p_Delegate)
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