Sleep(period := 1, Mode := "S")
{
	static Frequency, MinSetResolution, PID 		; frequency can't change while computer is on

	if (Mode = "P")				; Precise, but the loop will eat CPU cycles! - use for short time periods
	{
		pBatchLines := A_BatchLines
		SetBatchLines, -1  		;	increase the precision
;		if !PID
;			PID := DllCall("GetCurrentProcessId")
;		pPiority := DllCall("GetPriorityClass","UInt", hProc := DllCall("OpenProcess","Uint",0x400,"Int",0,"UInt", PID)) 	; have to use 0x400 (PROCESS_QUERY_INFORMATION)
;							, DllCall("CloseHandle","Uint",hProc)
;		if (pPiority != 0x20)  ;  Normal - I figure if priortiy less than normal increase it to normal for accuracy else if its above normal decrease it, so it doesn't affect other programs as much
;			DllCall("SetPriorityClass","UInt", hProc := DllCall("OpenProcess","Uint",0x200,"Int",0,"UInt",PID), "Uint", 0x20) ; set priority to normal ;have to open a new process handle with 0x200 (PROCESS_SET_INFORMATION)
;							, PriorityAltered := True
		if !Frequency
			DllCall("QueryPerformanceFrequency", "Int64*", Frequency) 	; e.g. 3222744 (/s)
		DllCall("QueryPerformanceCounter", "Int64*", Start)
		Finish := Start + ( Frequency * (period/1000))
		loop
			DllCall("QueryPerformanceCounter", "Int64*", Current) 		;	eats the cpu
		until (Current >= Finish)
		SetBatchLines, %pBatchLines%
;		if PriorityAltered ; restore original priority
;			DllCall("SetPriorityClass","UInt", hProc := DllCall("OpenProcess","Uint",0x200,"Int",0,"UInt",PID), "Uint", pPiority) ; reset priority
;				, DllCall("CloseHandle","Uint",hProc)

	}
	else if (Mode = "HP" || Mode = "HS" )		; hybrid Precise or hybrid suspend
	{ 											; will sleep the majority of the time using AHKs sleep
		if !Frequency 							; and sleep the remainder using Precise or suspend
			DllCall("QueryPerformanceFrequency", "Int64*", Frequency)
		DllCall("QueryPerformanceCounter", "Int64*", Start)
		Finish := Start + ( Frequency * (period/1000))
		if (A_BatchLines = -1)
			sleep % period - 15  		; if period is < 15 this will be a nagative number which will simply make AHK check its message queue
		else sleep, % period - 25  		; I picked 25 ms, as AHK sleep is usually accurate to 15 ms, and then added an extra 10 ms in case there was an AHK internal 10ms sleep
		DllCall("QueryPerformanceCounter", "Int64*", Current)
		if (Current < Finish) 						; so there is still a small amount of sleep time left, lets use the precise methods for the remainder
		{
			period := (Finish - Current)*1000 / Frequency ; convert remainder to ms
			if (Mode = "HP")
				sleep(period, "P")
			else sleep(period, "S")
		}
	}
	else if (Mode = "S")  	; suspend/sleep (sleeps entire script so will delay timers/hotkeys)
	{
		if !MinSetResolution
		{
			error := DllCall("winmm\timeGetDevCaps", Int64P, TimeCaps, UInt,8)
			if ( error || Errorlevel)
			{
				DLLcallErrorlevel := Errorlevel
				sleep, %period% 		;fall back to AHKs own sleep
				return error ? error : DLLcallErrorlevel
			}
			MinSetResolution := TimeCaps & 0xFFFFFFFF
   			;MaxResolution := TimeCaps >> 32
   			DllCall("Winmm.dll\timeBeginPeriod", UInt, MinSetResolution)
		}
		DllCall("Sleep", UInt, period)
	}
	else if (Mode = "Off" && MinSetResolution) 		; this should be called once at the end of the script
	{ 												; if mode "s" has been used somewhere
		DllCall("Winmm.dll\timeEndPeriod", UInt, MinSetResolution)
		MinSetResolution := False
	}
	else 						; When no mode is specified, the function will use the precise method when the period
	{							; is 20 ms or less (i have a number of sleep calls which contain a variable period)
		if (period > 20) 		; otherwise it just uses AHKs sleep
			sleep, %period%
		else sleep(period, "P")
	}
	return
}


/*
MSDN:
Use caution when calling timeBeginPeriod, as frequent calls can significantly affect the system clock,
system power usage, and the scheduler. If you call timeBeginPeriod, call it one time early in the application
and be sure to call the timeEndPeriod function at the very end of the application.

*/