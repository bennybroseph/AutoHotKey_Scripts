; Helps to maintain a steady and predictable frame-rate

class FPS
{
	static m_DeltaTime := 0
	static m_SleepDeltaTime := 0

	static m_CurrFPS := 0

	static m_AverageFPS := 0
	static m_FrameCount := 0
	static m_AddedDeltaTime := 0

	static m_TargetFPS

	static m_Frequency
	static m_Delay

	static m_StartupTime

	static m_CurrTime
	static m_PrevTime

	Init()
	{
		local _frequency
		DllCall("QueryPerformanceFrequency", "Int64*", _frequency)

		this.m_Frequency := _frequency

		this.m_TargetFPS := IniReader.ReadConfigKey(ConfigSection.Other, "Target_FPS")

		this.m_Delay := 1000 / this.m_TargetFPS

		this.m_StartupTime := this.GetCurrentTime()

		this.m_CurrTime := this.m_StartupTime
		this.m_PrevTime := this.m_CurrTime

		Debug.OnToolTipAddListener(new Delegate(FPS, "OnToolTip"))
	}

	DeltaTime[]
	{
		get {
			return this.m_Deltatime / 1000
		}
	}

	Runtime[]
	{
		get {
			return this.GetCurrentTime() - this.m_StartupTime
		}
	}
	RuntimeString[]
	{
		get {
			local _ticksRemaining := this.Runtime

			local _hours 	:= Floor(_ticksRemaining / 1000 / 60 / 60)
			_ticksRemaining := _ticksRemaining - (_hours * 1000 * 60 * 60)

			local _minutes 	:= Floor(_ticksRemaining / 1000 / 60)
			_ticksRemaining := _ticksRemaining - (_minutes * 1000 * 60)

			local _seconds := Floor(_ticksRemaining / 1000)
			_ticksRemaining := _ticksRemaining - (_seconds * 1000)

			local _miliseconds := Round(_ticksRemaining)

			return _hours . ":" . _minutes  . ":" . _seconds . ":" . _miliseconds
		}
	}

	Update()
	{
		global

		this.m_PrevTime := this.m_CurrTime

		local _counter := this.GetCurrentTime()
		local _deltaTime := _counter - this.m_PrevTime

		local _delay := Max(this.m_Delay - _deltaTime, 0)
		if (_delay > 0)
			Sleep(_delay)

		local _sleepDeltaTime := this.GetCurrentTime()
		this.m_SleepDeltaTime := _sleepDeltaTime - _counter

		this.m_CurrTime := _sleepDeltaTime
		this.m_DeltaTime := this.m_CurrTime - this.m_PrevTime

		this.m_CurrFPS := 1000 / this.m_DeltaTime

		this.m_AddedDeltaTime += this.m_DeltaTime
		if (this.m_AddedDeltaTime > 1000)
		{
			this.m_AverageFPS := (this.m_FrameCount * 1000) / this.m_AddedDeltaTime
			if (!Debug.Enabled and this.m_AverageFPS < this.m_TargetFPS * 0.8)
				Debug.Log("FPS dropped below 80%")

			this.m_AddedDeltaTime := 0
			this.m_FrameCount := 0
		}

		++this.m_FrameCount
	}

	ToMilliseconds(p_Counter)
	{
		return p_Counter * 1000 / this.m_Frequency
	}
	ToCounter(p_Time)
	{
		return p_Time * this.m_Frequency / 1000
	}

	QueryCounter()
	{
		local _counter
		DllCall("QueryPerformanceCounter", "Int64*", _counter)

		return _counter
	}

	GetCurrentTime()
	{
		return this.ToMilliseconds(this.QueryCounter())
	}

	OnToolTip()
	{
		global

		local _debugText :=

		_debugText .= "AverageFPS: " . Round(this.m_AverageFPS, 2) . "`tCurrFPS: " . Round(this.m_CurrFPS, 2) . "`n"
		_debugText .= "DeltaTime: " . Round(this.m_DeltaTime, 2) . "`tSleepDeltaTime: " . Round(this.m_SleepDeltaTime, 2)

		return _debugText
	}
}