; Holds functionality for Calibration

Calibrate()
{
	global

	local _maxValueL := 32767, _maxValueR := 32767, Button

	local _calibrate := IniReader.ReadConfigKey(ConfigSection.Calibration, "Calibrate")
	if (!_calibrate)
		return ; Calibrate is false

	MsgBox, , % "Calibration"
		, % "Since this appears to be the first time using the program, "
			. "We need to calibrate the controller for use with it."
	MsgBox, , % "Instructions"
		, % "To begin, I need to determine the max range that your analog sticks are able to reach. `n`n"
			. "1). Move both the Left AND Right analog stick all the way up at the same time. `n"
			. "2). Move them both in a circle multiple times. `n"
			. "3). Press any button while CONTINUING to hold them at max range."

	local _state :=

	local _leftStickValue := new Vector2()
	local _rightStickValue := new Vector2()
	Loop
	{
		Loop, 4
		{
			if _state := XInput_GetState(A_Index-1)
			{
				_leftStickValue.X := _state.ThumbLX
				_leftStickValue.Y := _state.ThumbLY

				_rightStickValue.X := _state.ThumbRX
				_rightStickValue.Y := _state.ThumbRY
			}
		}
	}Until _leftStickValue.Y = 32767 and _rightStickValue.Y = 32767

	Graphics.DrawToolTip("Now, spin the sticks in a max range circle multiple times. Press any button when complete."
			, Graphics.ActiveWinStats.Center.X
			, Graphics.ActiveWinStats.Center.Y
			, 1
			, "Center")

	Loop
	{
		Loop, 4
		{
			if _state := XInput_GetState(A_Index-1)
			{
				Button := _state.Buttons

				_leftStickValue.X := _state.ThumbLX
				_leftStickValue.Y := _state.ThumbLY

				_rightStickValue.X := _state.ThumbRX
				_rightStickValue.Y := _state.ThumbRY
			}
		}
		if(Abs(_leftStickValue.X) < _maxValueL && Abs(_leftStickValue.X) >= Abs(_leftStickValue.Y))
			_maxValueL := Abs(_leftStickValue.X)
		if(Abs(_leftStickValue.Y) < _maxValueL && Abs(_leftStickValue.Y) > Abs(_leftStickValue.X))
			_maxValueL := Abs(_leftStickValue.Y)
		if(Abs(_rightStickValue.X) < _maxValueR && Abs(_rightStickValue.X) >= Abs(_rightStickValue.Y))
			_maxValueR := Abs(_rightStickValue.X)
		if(Abs(_rightStickValue.Y) < _maxValueR && Abs(_rightStickValue.Y) > Abs(_rightStickValue.X))
			_maxValueR := Abs(_rightStickValue.Y)
	}Until Button

	Graphics.HideToolTip(1)

	local _maxThresholdL := _maxValueL - 750
	_maxThresholdR := _maxValueR - 750

	MsgBox, , % "Instructions"
		, % "Now I need to determine where the sticks rest when you aren't pressing them. `n`n"
			. "1). Move both sticks around a bunch in random directions. `n"
			. "2). Let go of both sticks and allow them to come to rest. `n"
			. "3). Once they are completely still, press any button on the controller."

	Button := 0
	Loop
	{
		Loop, 4
		{
			if _state := XInput_GetState(A_Index-1)
			{
				Button := _state.Buttons
			}
		}
	}Until Button

	Loop, 4
	{
		if _state := XInput_GetState(A_Index-1)
		{
			_leftStickValue.X := _state.ThumbLX
			_leftStickValue.Y := _state.ThumbLY

			_rightStickValue.X := _state.ThumbRX
			_rightStickValue.Y := _state.ThumbRY
		}
	}
	_minValueL := new Vector2(_leftStickValue.X, _leftStickValue.Y)
	_minValueR := new Vector2(_rightStickValue.X, _rightStickValue.Y)

	MsgBox, , % "Calibration Complete"
		, % "That concludes the calibration! `n`n"
			. "Thank you for taking the time to complete these instructions. `n"
			. "If for any reason you think these values are incorrect, you can either edit them yourself (not recommended) "
			. "or set 'Calibrate = true' in " . IniReader.ConfigPath . " to 'true' to run this again."

	IniReader.WriteConfigKey(_maxValueL, ConfigSection.Calibration, "Left_Analog_Max")
	IniReader.WriteConfigKey(_maxValueR, ConfigSection.Calibration, "Right_Analog_Max")

	IniReader.WriteConfigKey(_minValueL.X, ConfigSection.Calibration, "Left_Analog_XZero")
	IniReader.WriteConfigKey(_minValueL.Y, ConfigSection.Calibration, "Left_Analog_YZero")

	IniReader.WriteConfigKey(_minValueR.X, ConfigSection.Calibration, "Right_Analog_XZero")
	IniReader.WriteConfigKey(_minValueR.Y, ConfigSection.Calibration, "Right_Analog_YZero")

	IniReader.WriteConfigKey("false", ConfigSection.Calibration, "Calibrate")
}