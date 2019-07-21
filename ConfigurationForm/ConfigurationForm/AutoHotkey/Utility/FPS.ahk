; Helps to maintain a steady and predictable frame-rate

class FPS
{
	static m_Frequency :=

	static m_TargetFPS := 72
	static m_Delay :=

	static m_CurrentTick :=
	static m_PrevTick :=

	static m_DeltaTime :=
	static m_SleepTime :=

	static m_Counter :=
	static m_PrevCounter :=

	static m_DeltaCounter :=
	static m_SleepCount :=

	Init()
	{
		local _frequency
		DllCall("QueryPerformanceFrequency", "Int64*", _frequency)

		this.m_Frequency := _frequency

		this.m_Delay := 1000 / this.m_TargetFPS

		this.m_CurrentTick := A_TickCount
		this.m_PrevTick := this.m_CurrentTick

		this.m_DeltaTime := 0
		this.m_SleepTime := 0

		Debug.AddToOnToolTip(new Delegate(FPS, "OnToolTip"))
	}

	DeltaTime[]
	{
		get {
			return this.m_Deltatime / 1000
		}
	}

	Update()
	{
		global

		this.m_PrevCounter := this.m_Counter
		this.m_PrevTick := this.m_CurrentTick

		local _counter
		DllCall("QueryPerformanceCounter", "Int64*", _counter)

		local _deltaCounter := (_counter - this.m_PrevCounter) * 1000 / this.m_Frequency

		local _currentTick := A_TickCount
		local _deltaTime := _currentTick - this.m_PrevTick

		if (_deltaCounter < this.m_Delay)
			Sleep(this.m_Delay - _deltaCounter)

		local _sleepCounter
		DllCall("QueryPerformanceCounter", "Int64*", _sleepCounter)

		this.m_SleepCount := _sleepCounter - _counter
		this.m_SleepTime := A_TickCount - _currentTick

		this.m_Counter := _sleepCounter
		this.m_DeltaCounter := (this.m_Counter - this.m_PrevCounter) * 1000 / this.m_Frequency

		this.m_CurrentTick := A_TickCount
		this.m_DeltaTime := this.m_CurrentTick - this.m_PrevTick
	}

	OnToolTip()
	{
		global

		local _debugText :=

		_debugText .= "FPS - DeltaTime: " . this.m_DeltaTime . "`tSleepTime: " . this.m_SleepTime . "`n"
		_debugText .= "DeltaCounter: " . this.m_DeltaCounter . "`tSleepCount: " . this.m_SleepCount

		return _debugText
	}
}