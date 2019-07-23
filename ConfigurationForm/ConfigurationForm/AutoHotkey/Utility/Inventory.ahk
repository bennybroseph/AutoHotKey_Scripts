; Contains functionality related to the inventory grid

class Inventory
{
	Init()
	{
		global

		this.m_Enabled := False

		this.m_Grid := InventoryGrids.CreateGrid()
		this.m_Pos := new Vector2(1, 6)

		this.m_HoldToMove := IniReader.ReadProfileKey(ProfileSection.Inventory, "Hold_To_Move")
		this.m_HoldDelay := IniReader.ReadProfileKey(ProfileSection.Inventory, "Hold_Delay")

		this.m_ShowInventoryModeNotification
			:= IniReader.ReadProfileKey(ProfileSection.Preferences, "Show_Inventory_Mode_Notification")

		this.m_RemeberPosition
			:= IniReader.ReadProfileKey(ProfileSection.Inventory, "Remember_Position")

		this.m_BaseResolution := new Vector2(1920, 1080)
		this.m_Scaling
			:= new Vector2(IniReader.ReadProfileKey(ProfileSection.Inventory, "Custom_Scaling_Width")
						, IniReader.ReadProfileKey(ProfileSection.Inventory, "Custom_Scaling_Height"))

		Debug.OnToolTipAddListener(new Delegate(Inventory, "OnToolTip"))
	}

	Enabled[]
	{
		get {
			return this.m_Enabled
		}
	}

	MaxPos[]
	{
		get {
			return new Vector2(this.m_Grid.MaxIndex(), this.m_Grid[1].MaxIndex())
		}
	}

	GetGridPos(p_X := 0, p_Y := 0)
	{
		global

		if (p_X = 0)
			p_X := this.m_Pos.X
		if (p_Y = 0)
			p_Y := this.m_Pos.Y

		local _gridPos
			:= Vector2
				.Mul(Vector2
					.Mul(this.m_Grid[p_X, p_Y], Vector2.Div(Graphics.ActiveWinStats.Size, this.m_BaseResolution)), this.m_Scaling)

		return _gridPos
	}

	ProcessPress(p_DPadButton)
	{
		if (p_DPadButton.Controlbind.OnPress.Action or this.m_HoldToMove)
			p_DPadButton.PressTick := A_TickCount

		if (!p_DPadButton.Controlbind.OnPress.Action or this.m_HoldToMove)
			this.PressControl(p_DPadButton.Index)
	}
	ProcessReleaseHold(p_DPadButton)
	{
		if (!this.m_HoldToMove)
			InputHelper.ReleaseKeybind(p_DPadButton.Controlbind.OnPress)
		else
			p_DPadButton.HoldTick := 0
	}
	ProcessReleasePress(p_DPadButton)
	{
		if (!this.m_HoldToMove)
			this.PressControl(p_DPadButton.Index)
	}
	ProcessHold(p_DPadButton)
	{
		if (this.m_HoldToMove)
		{
			if (p_DPadButton.PressTick > 0 and A_TickCount >= p_DPadButton.PressTick + Controller.m_HoldDelay)
			{
				this.PressControl(p_DPadButton.Index)

				p_DPadButton.HoldTick	:= A_TickCount
				p_DPadButton.PressTick 	:= 0
			}
			else if (p_DPadButton.HoldTick > 0 and A_TickCount >= p_DPadButton.HoldTick + Inventory.m_HoldDelay)
			{
				this.PressControl(p_DPadButton.Index)

				p_DPadButton.HoldTick	:= A_TickCount
			}
		}
		else if (_control.PressTick > 0 and A_TickCount >= p_DPadButton.PressTick + Controller.m_HoldDelay)
		{
			Controller.Vibrate()

			Debug.Log(p_DPadButton.Name . " held down " . p_DPadButton.Controlbind.OnPress.String)
			InputHelper.PressKeybind(p_DPadButton.Controlbind.OnPress)

			_control.PressTick := 0
		}
	}

	PressControl(p_ControlIndex)
	{
		global

		local _prevGridPos := new Vector2(this.GetGridPos().X, this.GetGridPos().Y)
		Loop
		{
			if (p_ControlIndex = ControlIndex.DPadUp)
				this.m_Pos.Y--
			if (p_ControlIndex = ControlIndex.DPadDown)
				this.m_Pos.Y++
			if (p_ControlIndex = ControlIndex.DPadLeft)
				this.m_Pos.X--
			if (p_ControlIndex = ControlIndex.DPadRight)
				this.m_Pos.X++

			if (this.m_Pos.X < 1)
				this.m_Pos.X := this.MaxPos.X
			if (this.m_Pos.X > this.MaxPos.X)
				this.m_Pos.X := 1

			if (this.m_Pos.Y < 1)
				this.m_Pos.Y := this.MaxPos.Y
			if (this.m_Pos.Y > this.MaxPos.Y)
				this.m_Pos.Y := 1
		} Until (this.GetGridPos().X != _prevGridPos.X
			or this.GetGridPos().Y != _prevGridPos.Y)

		InputHelper.MoveMouse(this.GetGridPos())
	}

	Toggle()
	{
		if (!this.m_Enabled)
			this.Enable()
		else
			this.Disable()
	}
	Enable()
	{
		global

		if (Controller.CursorMode)
			Controller.DisableCursorMode()

		if (this.m_ShowInventoryModeNotification)
		{
			local _controlInfo := Controller.FindControlInfo(IniReader.ParseKeybind("Inventory"))

			Graphics.DrawToolTip("Inventory Mode: m_Enabled `n"
								. _controlInfo.Act . " the " . _controlInfo.Control.Name . " button on the controller to disable"
								, Graphics.ActiveWinStats.Center.X
								, 0
								, 1, HorizontalAlignment.Center)
		}

		Controller.ForceMouseUpdate := True
		this.m_Enabled := True

		Debug.Log("Inventory Mode: m_Enabled")
	}
    Disable()
    {
		global

		if (this.m_ShowInventoryModeNotification)
			Graphics.HideToolTip(1)

		Controller.ResetDPadTick()
		if (!this.m_RememberPosition)
			this.m_Pos := new Vector2(1, 6)

		Controller.ForceMouseUpdate := True
		this.m_Enabled := False

		Debug.Log("Inventory Mode: Disabled")
    }

	OnToolTip()
	{
		global

		local _debugText
			.= "Inventory - " . this.m_Enabled . "`n"
			. "m_Pos: " . this.m_Pos.String . " Value: " . this.GetGridPos().String . " m_HoldToMove: " . this.m_HoldToMove

		return _debugText
	}
}

class InventoryGrids
{
	CreateGrid(p_Type := "Diablo III")
	{
		local _newGrid := Array()

		if (p_Type = "Diablo III")
		{
			; Base Inventory m_Grid
			Loop, 10
			{
				i := A_Index
				Loop, 6
					_newGrid[i, A_Index + 5] := new Vector2(1428.5 + 50 * (i - 1), 583.5 + 50 * (A_Index - 1))
			}

			; The two UI buttons "Paragon" and "Details"
			Loop, 4
			{
				i := A_Index
				Loop, 5
				{
					if(A_Index > 2)
						_newGrid[i, A_Index] := new Vector2(1524.5, 511)
					else
						_newGrid[i, A_Index] := new Vector2(1524.5,  223)
				}
			}

			; Weapon
			_newGrid[5, 5] := new Vector2(1641.5, 476)
			_newGrid[6, 5] := _newGrid[5, 5]
			_newGrid[5, 4] := _newGrid[5, 5]
			_newGrid[6, 4] := _newGrid[5, 5]

			; Left Ring
			_newGrid[5, 4] := new Vector2(1641.5, 387.5)
			_newGrid[6, 4] := _newGrid[5, 4]

			; Hands
			_newGrid[5, 3] := new Vector2(1641.5, 318)
			_newGrid[6, 3] := _newGrid[5, 3]

			; Shoulders
			_newGrid[5, 2] := new Vector2(1665, 229)
			_newGrid[6, 2] := _newGrid[5, 2]
			_newGrid[5, 1] := _newGrid[5, 2]
			_newGrid[6, 1] := _newGrid[5, 2]

			; Feet
			_newGrid[7, 5] := new Vector2(1739, 494.5)
			_newGrid[8, 5] := _newGrid[7, 5]

			; Legs
			_newGrid[7, 4] := new Vector2(1739, 412)
			_newGrid[8, 4] := _newGrid[7, 4]

			; Waist
			_newGrid[7, 3] := new Vector2(1739, 353)
			_newGrid[8, 3] := _newGrid[7, 3]

			; Chest
			_newGrid[7, 2] := new Vector2(1739, 282)
			_newGrid[8, 2] := _newGrid[7, 2]

			; Head
			_newGrid[7, 1] := new Vector2(1739, 199)
			_newGrid[8, 1] := _newGrid[7, 1]

			; Off-Hand
			_newGrid[9,  5] := new Vector2(1836, 476)
			_newGrid[10, 5] := _newGrid[9, 5]
			_newGrid[9,  4] := _newGrid[9, 5]
			_newGrid[10, 4] := _newGrid[9, 5]

			; Right Ring
			_newGrid[9,  4] := new Vector2(1836.5, 387.5)
			_newGrid[10, 4] := _newGrid[9, 4]

			; Wrists
			_newGrid[9,  3] := new Vector2(1836, 318)
			_newGrid[10, 3] := _newGrid[9, 3]

			; Amulet
			_newGrid[9,  2] := new Vector2(1808.5, 232.5)
			_newGrid[10, 2] := _newGrid[9,  2]
			_newGrid[9,  1] := _newGrid[9,  2]
			_newGrid[10, 1] := _newGrid[9,  2]
		}

		return _newGrid
	}
}