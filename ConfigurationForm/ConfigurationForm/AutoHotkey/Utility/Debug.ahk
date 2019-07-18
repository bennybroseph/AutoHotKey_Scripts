; Contains the debug class

class Debug
{
	static __singleton :=
	static __init := False

	Init()
	{
		Debug.__singleton := new Debug()

		Debug.__init := True
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

	DrawToolTip()
	{
		global

		local _debugText :=

		local i, _delegate
		For i, _delegate in this.OnToolTip
			_debugText := _debugText . %_delegate%() . "`n`n"

		Graphics.DrawToolTip(_debugText, 0, 80, 7)

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
		if(!this.Enabled)
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
		Graphics.HideToolTip(5)
		Graphics.HideToolTip(7)
		Graphics.HideToolTip(8)

		this.Enabled := False
	}
}