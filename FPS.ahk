Class FPS
{
	__New(TargetFPS) {
		this.TargetFPS := TargetFPS
		this.LastFrame := A_TickCount
		
		this.TimeHold := A_TickCount
	}
	
	Get_Sleep() {
		SleepTime := (1000/this.TargetFPS)-(A_TickCount - this.LastFrame)
		
		if(SleepTime > 0)
			return SleepTime
		else
		{
			this.LastFrame := A_TickCount
			return false
		}
	}
	
	Get_FPS()
	{
		this.Ticks += 1
		if(A_TickCount > this.Timehold + 1000)
		{
			this.Timehold := A_TickCount
			Tooltip, % "FPS: " this.Ticks, 0, 50
			this.Ticks := 0
		}
	}
}
	