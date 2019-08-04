; =======================================================================================
; LLMouse - A library to send Low Level Mouse input

; Note that many functions have time and rate parameters.
; These all work the same way:
; times	- How many times to send the requested action. Optional, default is 1
; rate	- The rate (in ms) to send the action at. Optional, default rate varies
; Note that if you use a value for rate of less than 10, special code will kick in.
; QPX is used for rates of <10ms as the AHK Sleep command does not support sleeps this short
; More CPU will be used in this mode.
class LLMouse {
	static MOUSEEVENTF_MOVE := 0x1
	static MOUSEEVENTF_WHEEL := 0x800

	; ======================= Functions for the user to call ============================
	; Move the mouse
	; All values are Signed Integers (Whole numbers, Positive or Negative)
	; x		- How much to move in the x axis. + is right, - is left
	; y		- How much to move in the y axis. + is down, - is up
	Move(x, y, times := 1, rate := 1){
		this._MouseEvent(times, rate, this.MOUSEEVENTF_MOVE, x, y)
	}

	; Move the wheel
	; dir	- Which direction to move the wheel. 1 is up, -1 is down
	Wheel(dir, times := 1, rate := 10){
		static WHEEL_DELTA := 120
		this._MouseEvent(times, rate, this.MOUSEEVENTF_WHEEL, , , dir * WHEEL_DELTA)
	}

	; ============ Internal functions not intended to be called by end-users ============
	_MouseEvent(times, rate, dwFlags := 0, dx := 0, dy := 0, dwData := 0){
		Loop % times {
			DllCall("mouse_event", uint, dwFlags, int, dx ,int, dy, uint, dwData, int, 0)
			if (A_Index != times){	; Do not delay after last send, or if rate is 0
				if (rate >= 10){
					Sleep % rate
				} else {
					this._Delay(rate * 0.001)
				}
			}
		}
	}

	_Delay( D=0.001 ) { ; High Resolution Delay ( High CPU Usage ) by SKAN | CD: 13/Jun/2009
		Static F ; www.autohotkey.com/forum/viewtopic.php?t=52083 | LM: 13/Jun/2009
		Critical
		F ? F : DllCall( "QueryPerformanceFrequency", Int64P,F )
		DllCall( "QueryPerformanceCounter", Int64P,pTick ), cTick := pTick
		While( ( (Tick:=(pTick-cTick)/F)) <D ) {
			DllCall( "QueryPerformanceCounter", Int64P,pTick )
			Sleep -1
		}
		Return Round( Tick,3 )
	}
}