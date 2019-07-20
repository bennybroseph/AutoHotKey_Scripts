; Helps to maintain a steady and predictable frame-rate

class FPS
{
	static m_TargetFPS := 60
	static m_Delay :=

	static m_CurrentTick :=
	static m_PrevTick :=

	static m_DeltaTime :=
	static m_SleepTime :=

	Init()
	{
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

		this.m_PrevTick := this.m_CurrentTick

		local _currentTick := A_TickCount
		local _deltaTime := _currentTick - this.m_PrevTick

		if (_deltaTime < this.m_Delay)
			Sleep(this.m_Delay - _deltaTime)

		this.m_SleepTime := A_TickCount - _currentTick

		this.m_CurrentTick := A_TickCount
		this.m_DeltaTime := this.m_CurrentTick - this.m_PrevTick

		Debug.AddToLog("DeltaTime: " . this.m_DeltaTime . "  SleepTime:" . this.m_SleepTime)
	}

	OnToolTip()
	{
		global

		local _debugText := "FPS - DeltaTime: " . this.m_DeltaTime . " SleepTime: " . this.m_SleepTime

		return _debugText
	}
}