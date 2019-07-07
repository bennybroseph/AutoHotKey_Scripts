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
		this.m_StartupTick := A_TickCount

		this.m_LogEntries := Array()

		this.m_OnTooltip := Array()
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

	LogEntries[]
	{
		get {
			return Debug.__singleton.m_LogEntries
		}
	}

	OnTooltip[]
	{
		get {
			return Debug.__singleton.m_OnTooltip
		}
	}

	DrawTooltip()
	{
		local _debugText :=

		For i, _delegate in this.OnTooltip
			_debugText := _debugText . %_delegate%() . "`n`n"

		_debugText := _debugText . "Debug Log:`n"

		For i, _entry in this.LogEntries
			_debugText := _debugText . _entry . "`n"

		ToolTip, % _debugText, 0, 90, 7
	}

	AddToLog(p_Entry)
	{
		if (this.LogEntries.Length() >= 60)
			this.LogEntries.RemoveAt(1)

		this.LogEntries.Push("[" . this.CurrentRuntime . "]: " . p_Entry)
	}

	AddToOnTooltip(p_Delegate)
	{
		this.OnTooltip.Push(p_Delegate)
	}
}