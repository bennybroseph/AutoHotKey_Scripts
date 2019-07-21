; Holds functionality for Calibration

Calibrate()
{
	global

	local _buttonState := False

	local _calibrate := IniReader.ReadConfigKey(ConfigSection.Calibration, "Calibrate")
	if (!_calibrate)
		return ; Calibrate is false

	MsgBox, , % "Calibration"
		, % "Since this appears to be the first time using the program, "
			. "we need to calibrate the controller for use with it."
	MsgBox, , % "Instructions"
		, % "To begin, we need to determine the max range that your analog sticks are able to reach. `n`n"
			. "1). Move both the Left Analog Stick all the way up. `n"
			. "2). Move the Left Stick in a max range circle multiple times. `n"
			. "3). Press any button while CONTINUING to hold the Left Stick at max range.`n"
			. "4). Repeat this for the Right Analog Stick.`n`n"
			. "Press 'OK' to begin."

	local _overlayAlpha := 150
	local _overlaySize
		:= new Vector2(Round(Graphics.ActiveWinStats.Size.Height / 2, 0)
					, Round(Graphics.ActiveWinStats.Size.Height / 2, 0))

	local _maxRangeEllipse := new Ellipse(_overlaySize, new Color(0, 255, 150, _overlayAlpha), false, 5)

	local _axisX
		:= new Line(new Vector2(0, _overlaySize.Height / 2)
				, new Vector2(_overlaySize.Width, _overlaySize.Height / 2)
				, _overlaySize
				, new Color(0, 255, 150, _overlayAlpha), 1)
	local _axisY
		:= new Line(new Vector2(_overlaySize.Width / 2, 0)
				, new Vector2(_overlaySize.Width / 2, _overlaySize.Height)
				, _overlaySize
				, new Color(0, 255, 150, _overlayAlpha), 1)

	local _rightInputEllipse
		:= new Ellipse(new Vector2(_overlaySize.Width * 0.03, _overlaySize.Height * 0.03)
					, new Color(255, 150, 0, _overlayAlpha))
	local _leftInputEllipse
		:= new Ellipse(new Vector2(_overlaySize.Width * 0.03, _overlaySize.Height * 0.03)
					, new Color(0, 150, 255, _overlayAlpha))

	local _center := Graphics.ActiveWinStats.Center

	Graphics.DrawImage(_maxRangeEllipse, _center)
	Graphics.DrawImage(_axisX, _center)
	Graphics.DrawImage(_axisY, _center)

	Loop, 2
	{
		local _stickCalibration := A_Index = 1 ? "Left" : "Right"
		Graphics.HideImage(_stickCalibration != "Left" ? _leftInputEllipse : _rightInputEllipse)

		Graphics.DrawToolTip("Start by moving the stick upwards until you hit the frame."
				, Graphics.ActiveWinStats.Center.X
				, 0
				, 1
				, HorizontalAlignment.Center
				, VerticalAlignment.Center)

		local _state :=

		local _stickValueL := new Vector2()
		local _stickValueR := new Vector2()
		Loop
		{
			Loop, 4
			{
				if _state := XInput_GetState(A_Index-1)
				{
					_stickValueL	:= new Vector2(_state.ThumbLX / Stick.s_MaxValue, _state.ThumbLY / Stick.s_MaxValue)
					_stickValueR	:= new Vector2(_state.ThumbRX / Stick.s_MaxValue, _state.ThumbRY / Stick.s_MaxValue)

					local _stickValue := _stickCalibration = "Left" ? _stickValueL : _stickValueR
					Graphics.DrawImage(_stickCalibration = "Left" ? _leftInputEllipse : _rightInputEllipse
									, new Vector2(_center.X + _stickValue.X * (_overlaySize.Width / 2)
												, _center.Y - _stickValue.Y * (_overlaySize.Height / 2)))
				}
			}
		}Until _stickValueL.Magnitude >= 1 or _stickValueR.Magnitude >= 1

		Graphics.DrawToolTip("Now, spin the stick in a circle multiple times while still making contact with the frame.`n"
							. "Press any button when complete."
				, Graphics.ActiveWinStats.Center.X
				, 0
				, 1
				, HorizontalAlignment.Center
				, VerticalAlignment.Center)

		local _maxMagnitudeL := 1
		local _maxMagnitudeR := 1
		Loop
		{
			Loop, 4
			{
				if _state := XInput_GetState(A_Index-1)
				{
					_buttonState := _state.Buttons

					_stickValueL 	:= new Vector2(_state.ThumbLX / Stick.s_MaxValue, _state.ThumbLY / Stick.s_MaxValue)
					_stickValueR	:= new Vector2(_state.ThumbRX / Stick.s_MaxValue, _state.ThumbRY / Stick.s_MaxValue)

					local _stickValue := _stickCalibration = "Left" ? _stickValueL : _stickValueR
					Graphics.DrawImage(_stickCalibration = "Left" ? _leftInputEllipse : _rightInputEllipse
									, new Vector2(_center.X + _stickValue.X * (_overlaySize.Width / 2)
												, _center.Y - _stickValue.Y * (_overlaySize.Height / 2)))
				}
			}
			if (_stickValueL.Magnitude < _maxMagnitudeL and _stickCalibration = "Left")
				_maxMagnitudeL := _stickValueL.Magnitude
			if (_stickValueR.Magnitude < _maxMagnitudeR and _stickCalibration = "Right")
				_maxMagnitudeR := _stickValueR.Magnitude
		}Until _buttonState

		if (A_Index = 2)
			continue

		Graphics.DrawToolTip("Now let's calibrate the right stick."
				, Graphics.ActiveWinStats.Center.X
				, 0
				, 1
				, HorizontalAlignment.Center
				, VerticalAlignment.Center)

		Loop
		{
			Loop, 4
			{
				if _state := XInput_GetState(A_Index-1)
				{
					_stickValueL	:= new Vector2(_state.ThumbLX / Stick.s_MaxValue, _state.ThumbLY / Stick.s_MaxValue)
					_stickValueR	:= new Vector2(_state.ThumbRX / Stick.s_MaxValue, _state.ThumbRY / Stick.s_MaxValue)
				}
			}
		}Until _stickValueL.Magnitude <= 0.2 and _stickValueR.Magnitude <= 0.2


		Sleep(500)

		Graphics.HideToolTip(1)
	}

	Graphics.HideImage(_maxRangeEllipse)
	Graphics.HideImage(_axisX)
	Graphics.HideImage(_axisY)
	Graphics.HideImage(_leftInputEllipse)
	Graphics.HideImage(_rightInputEllipse)

	Graphics.HideToolTip(1)

	local _maxThresholdL := _maxMagnitudeL - 0.025
	local _maxThresholdR := _maxMagnitudeR - 0.025

	local _repetitions := 3
	MsgBox, , % "Instructions"
		, % "Now I need to determine where the sticks rest when you aren't pressing them. `n`n"
			. "1). Move both sticks around a bunch in random directions. `n"
			. "2). Let go of both sticks and allow them to come to rest. `n"
			. "3). Once they are completely still, press any button on the controller.`n"
			. "4). Repeat this " . _repetitions . " times.`n`n"
			. "Press 'OK' to begin."

	Graphics.DrawImage(_maxRangeEllipse, _center)
	Graphics.DrawImage(_axisX, _center)
	Graphics.DrawImage(_axisY, _center)

	local _minZeroL := 1, local _maxZeroL := 0
	local _minZeroR := 1, local _maxZeroR := 0

	local _minValueAverageL := new Vector2()
	local _minValueAverageR := new Vector2()
	Loop, % _repetitions
	{
		Graphics.DrawToolTip("Move the sticks in random directions, then let them come to rest. Press any button when complete.`n"
							. _repetitions - (A_Index - 1) . " more input(s) needed."
			, Graphics.ActiveWinStats.Center.X
			, 0
			, 1
			, HorizontalAlignment.Center
			, VerticalAlignment.Center)

		_buttonState := 0
		Loop
		{
			Loop, 4
			{
				if _state := XInput_GetState(A_Index-1)
				{
					_buttonState := _state.Buttons

					_stickValueL	:= new Vector2(_state.ThumbLX / Stick.s_MaxValue, _state.ThumbLY / Stick.s_MaxValue)
					_stickValueR	:= new Vector2(_state.ThumbRX / Stick.s_MaxValue, _state.ThumbRY / Stick.s_MaxValue)

					Graphics.DrawImage(_leftInputEllipse
									, new Vector2(_center.X + _stickValueL.X * (_overlaySize.Width / 2)
												, _center.Y - _stickValueL.Y * (_overlaySize.Height / 2)))
					Graphics.DrawImage(_rightInputEllipse
									, new Vector2(_center.X + _stickValueR.X * (_overlaySize.Width / 2)
												, _center.Y - _stickValueR.Y * (_overlaySize.Height / 2)))
				}
			}
		}Until _buttonState

		Loop, 4
		{
			if _state := XInput_GetState(A_Index-1)
			{
				_stickValueL	:= new Vector2(_state.ThumbLX / Stick.s_MaxValue, _state.ThumbLY / Stick.s_MaxValue)
				_stickValueR	:= new Vector2(_state.ThumbRX / Stick.s_MaxValue, _state.ThumbRY / Stick.s_MaxValue)
			}
		}
		_minValueAverageL := Vector2.Add(_minValueAverageL, _stickValueL)
		_minValueAverageR := Vector2.Add(_minValueAverageR, _stickValueR)

		if (_stickValueL.Magnitude < _minZeroL)
			_minZeroL := _stickValueL.Magnitude
		if (_stickValueL.Magnitude > _maxZeroL)
			_maxZeroL := _stickValueL.Magnitude

		if (_stickValueR.Magnitude < _minZeroR)
			_minZeroR := _stickValueR.Magnitude
		if (_stickValueR.Magnitude > _maxZeroR)
			_maxZeroR := _stickValueR.Magnitude

		Graphics.HideToolTip(1)

		if (A_Index = _repetitions)
			continue

		Sleep(500)
	}

	Graphics.HideImage(_maxRangeEllipse)
	Graphics.HideImage(_axisX)
	Graphics.HideImage(_axisY)
	Graphics.HideImage(_leftInputEllipse)
	Graphics.HideImage(_rightInputEllipse)

	_minValueAverageL := Vector2.Div(_minValueAverageL, _repetitions)
	_minValueAverageR := Vector2.Div(_minValueAverageR, _repetitions)

	local _zeroDeltaL := _minValueAverageL.Magnitude + 0.125
	local _zeroDeltaR := _minValueAverageR.Magnitude + 0.125

	MsgBox, , % "Calibration Complete"
		, % "That concludes the calibration! `n`n"
			. "Thank you for taking the time to complete these instructions. `n"
			. "If for any reason you think these values are incorrect, you can either edit them yourself "
			. "or set 'Calibrate = true' in:`n" . IniReader.ConfigPath . "`nto run this again."

	IniReader.WriteConfigKey(_maxThresholdL, ConfigSection.Calibration, "Left_Analog_Max_Value")
	IniReader.WriteConfigKey(_maxThresholdR, ConfigSection.Calibration, "Right_Analog_Max_Value")

	IniReader.WriteConfigKey(_minValueAverageL.X, ConfigSection.Calibration, "Left_Analog_Zero_Average_X")
	IniReader.WriteConfigKey(_minValueAverageL.Y, ConfigSection.Calibration, "Left_Analog_Zero_Average_Y")

	IniReader.WriteConfigKey(_minValueAverageR.X, ConfigSection.Calibration, "Right_Analog_Zero_Average_X")
	IniReader.WriteConfigKey(_minValueAverageR.Y, ConfigSection.Calibration, "Right_Analog_Zero_Average_Y")

	IniReader.WriteConfigKey(_zeroDeltaL, ConfigSection.Calibration, "Left_Analog_Deadzone ")
	IniReader.WriteConfigKey(_zeroDeltaR, ConfigSection.Calibration, "Right_Analog_Deadzone ")

	IniReader.WriteConfigKey("false", ConfigSection.Calibration, "Calibrate")
}